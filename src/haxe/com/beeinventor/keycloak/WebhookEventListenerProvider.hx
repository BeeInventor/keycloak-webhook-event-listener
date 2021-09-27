package com.beeinventor.keycloak;

import haxe.io.BytesBuffer;
import haxe.io.Bytes;
import haxe.Json;
import java.net.HttpURLConnection;
import java.net.URL;
import org.keycloak.models.KeycloakSession;
import org.keycloak.events.Event;
import org.keycloak.events.admin.AdminEvent;
import org.keycloak.events.EventListenerProvider;

class WebhookEventListenerProvider implements EventListenerProvider {
	final session:KeycloakSession;
	
	final eventConfig:WebhookConfig;
	final adminEventConfig:WebhookConfig;
	
	public function new(session, eventConfig, adminEventConfig) {
		this.session = session;
		this.eventConfig = eventConfig;
		this.adminEventConfig = adminEventConfig;
	}
	
	public function close() {}

	public overload function onEvent(event:AdminEvent, includeRepresentation:Bool) {
		invokeWebhook(adminEventConfig, {
			authDetails: {
				final details = event.getAuthDetails();
				{
					clientId: details.getClientId(),
					ipAddress: details.getIpAddress(),
					realmId: details.getRealmId(),
					userId: details.getUserId(),
				}
			},
			error: event.getError(),
			id: event.getId(),
			operationType: event.getOperationType().getName(),
			realmId: event.getRealmId(),
			representation: try Json.parse(event.getRepresentation()) catch(_) null,
			resourcePath: event.getResourcePath(),
			resourceType: event.getResourceType().getName(),
			// resourceTypeAsString: event.getResourceTypeAsString(),
			time: event.getTime(),
			includeRepresentation: includeRepresentation,
		});
	}

	public overload function onEvent(event:Event) {
		invokeWebhook(eventConfig, {
			clientId: event.getClientId(),
			details: {
				final obj = new haxe.DynamicAccess<String>();
				for(entry in event.getDetails().entrySet()) obj[entry.getKey()] = entry.getValue();
				obj;
			},
			error: event.getError(),
			id: event.getId(),
			ipAddress: event.getIpAddress(),
			realmId: event.getRealmId(),
			sessionId: event.getSessionId(),
			time: event.getTime(),
			type: event.getType().getName(),
			userId: event.getUserId(),
		});
	}
	
	function invokeWebhook(config:WebhookConfig, payload:Any) {
		final url = new URL(config.url);
		final cnx:HttpURLConnection = cast url.openConnection();
		final data = Bytes.ofString(Json.stringify(payload));

		cnx.setRequestMethod('POST');
		cnx.setRequestProperty('Content-Type', 'application/json');
		switch config.auth {
			case null | '': // skip
			case auth: cnx.setRequestProperty('Authorization', auth);
		}
		cnx.setDoOutput(true);

		final out = cnx.getOutputStream();
		out.write(data.getData());
		out.flush();
		out.close();

		return {
			status: cnx.getResponseCode(),
		}
	}
}
