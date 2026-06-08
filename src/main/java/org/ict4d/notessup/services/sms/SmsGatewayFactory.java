package org.ict4d.notessup.services.sms;

import org.ict4d.notessup.utils.Constants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Sélectionne la passerelle SMS active selon {@link Constants#SMS_GATEWAY}.
 * Instance unique partagée par l'application.
 */
public final class SmsGatewayFactory {

    private static final Logger logger = LoggerFactory.getLogger(SmsGatewayFactory.class);

    private static volatile SmsGateway instance;

    private SmsGatewayFactory() {
    }

    public static SmsGateway get() {
        if (instance == null) {
            synchronized (SmsGatewayFactory.class) {
                if (instance == null) {
                    instance = build(Constants.SMS_GATEWAY);
                }
            }
        }
        return instance;
    }

    private static SmsGateway build(String name) {
        SmsGateway gateway;
        if ("smslib".equalsIgnoreCase(name)) {
            gateway = new SmslibGateway();
        } else {
            gateway = new ConsoleSmsGateway();
        }
        logger.info("Passerelle SMS active : {}", gateway.name());
        return gateway;
    }
}
