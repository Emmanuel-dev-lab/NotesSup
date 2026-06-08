package org.ict4d.notessup.services.sms;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Passerelle SMS par défaut : n'envoie rien réellement, journalise le message.
 * Permet de faire fonctionner et démontrer l'application sans modem GSM.
 */
public class ConsoleSmsGateway implements SmsGateway {

    private static final Logger logger = LoggerFactory.getLogger(ConsoleSmsGateway.class);

    @Override
    public boolean send(String phoneNumber, String message) {
        logger.info("[SMS console] -> {} : {}", phoneNumber, message);
        return true;
    }

    @Override
    public String name() {
        return "console";
    }
}
