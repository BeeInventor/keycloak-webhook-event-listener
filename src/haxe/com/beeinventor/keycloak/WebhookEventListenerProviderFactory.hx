package com.beeinventor.keycloak;

import org.keycloak.models.KeycloakSession;
import org.keycloak.events.EventListenerProvider;
import org.keycloak.Config.Config_Scope;
import org.keycloak.models.KeycloakSessionFactory;
import org.keycloak.events.EventListenerProviderFactory;


class WebhookEventListenerProviderFactory implements EventListenerProviderFactory {
	
	final eventConfig:WebhookConfig;
	final adminEventConfig:WebhookConfig;

	public function new() {
		eventConfig = {
			url: Sys.getEnv('KEYCLOAK_EVENT_WEBHOOK_URL'),
			auth: Sys.getEnv('KEYCLOAK_EVENT_WEBHOOK_AUTH'),
		}
		adminEventConfig = {
			url: Sys.getEnv('KEYCLOAK_ADMIN_EVENT_WEBHOOK_URL'),
			auth: Sys.getEnv('KEYCLOAK_ADMIN_EVENT_WEBHOOK_AUTH'),
		}
	}

	public function close() {}

	public function create(session:KeycloakSession):EventListenerProvider {
		return new WebhookEventListenerProvider(session, eventConfig, adminEventConfig);
	}

	public function getId():String {
		return 'webhook';
	}

	public function init(config:Config_Scope) {}

	public function order():Int {
		return 0;
	}

	public function postInit(sessionFactory:KeycloakSessionFactory) {}
}
