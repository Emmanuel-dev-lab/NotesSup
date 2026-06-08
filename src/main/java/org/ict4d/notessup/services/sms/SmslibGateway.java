package org.ict4d.notessup.services.sms;

import org.ict4d.notessup.utils.Constants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Passerelle SMS réelle basée sur SMSLib 3.x, via un modem GSM série.
 * <p>
 * <b>Désactivée par défaut</b> : le code SMSLib est en commentaire car il nécessite :
 * <ol>
 *   <li>La dépendance SMSLib 3.x (absente de Maven Central : à ajouter manuellement
 *       au repo local ou en {@code system} scope dans le pom.xml).</li>
 *   <li>Une librairie série native : RXTX ({@code rxtxcomm}) ou jSerialComm,
 *       avec ses fichiers natifs ({@code .so}/{@code .dll}) installés.</li>
 *   <li>Un modem GSM (clé USB type Huawei/Wavecom) avec une carte SIM créditée,
 *       branché sur le port série configuré ({@link Constants#SMS_MODEM_PORT}).</li>
 * </ol>
 * Pour activer : ajouter SMSLib + la lib série au classpath, dé-commenter le bloc
 * {@code doSend(...)} ci-dessous, puis lancer avec {@code SMS_GATEWAY=smslib}.
 *
 * @see <a href="http://smslib.org">smslib.org</a>
 */
public class SmslibGateway implements SmsGateway {

    private static final Logger logger = LoggerFactory.getLogger(SmslibGateway.class);

    @Override
    public boolean send(String phoneNumber, String message) {
        // Tant que SMSLib n'est pas branché, on refuse explicitement l'envoi
        // pour ne pas faire croire qu'un SMS réel est parti.
        logger.warn("[SMS smslib] Passerelle SMSLib non configurée (dépendance + modem requis). "
                + "SMS NON envoyé -> {} : {}", phoneNumber, message);
        return false;

        // ----------------------------------------------------------------------
        // Implémentation SMSLib réelle (à dé-commenter une fois les dépendances
        // et le modem en place). API SMSLib 3.5.x :
        // ----------------------------------------------------------------------
        // return doSend(phoneNumber, message);
    }

    /*
    private static volatile Service service;

    private synchronized Service service() throws Exception {
        if (service == null) {
            SerialModemGateway gateway = new SerialModemGateway(
                    "modem1",
                    Constants.SMS_MODEM_PORT,
                    Constants.SMS_MODEM_BAUD,
                    Constants.SMS_MODEM_MANUFACTURER,
                    Constants.SMS_MODEM_MODEL);
            gateway.setInbound(false);
            gateway.setOutbound(true);
            if (Constants.SMS_MODEM_PIN != null && !Constants.SMS_MODEM_PIN.isBlank()) {
                gateway.setSimPin(Constants.SMS_MODEM_PIN);
            }
            Service.getInstance().addGateway(gateway);
            Service.getInstance().startService();
            service = Service.getInstance();
        }
        return service;
    }

    private boolean doSend(String phoneNumber, String message) {
        try {
            OutboundMessage msg = new OutboundMessage(phoneNumber, message);
            service().sendMessage(msg);
            boolean sent = msg.getMessageStatus() == OutboundMessage.MessageStatuses.SENT;
            logger.info("[SMS smslib] -> {} : statut={}", phoneNumber, msg.getMessageStatus());
            return sent;
        } catch (Exception e) {
            logger.error("[SMS smslib] Échec d'envoi vers {}", phoneNumber, e);
            return false;
        }
    }
    */

    @Override
    public String name() {
        return "smslib";
    }
}
