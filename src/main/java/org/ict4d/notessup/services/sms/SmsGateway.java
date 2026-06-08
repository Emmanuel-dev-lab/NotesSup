package org.ict4d.notessup.services.sms;

/**
 * Abstraction d'une passerelle d'envoi de SMS.
 * <p>
 * Implémentations disponibles :
 * <ul>
 *   <li>{@link ConsoleSmsGateway} : journalise le SMS (par défaut, fonctionne partout).</li>
 *   <li>{@link SmslibGateway} : envoi réel via un modem GSM avec SMSLib (nécessite du matériel).</li>
 * </ul>
 * La passerelle active est choisie par {@link SmsGatewayFactory} selon la configuration.
 */
public interface SmsGateway {

    /**
     * Envoie un SMS.
     *
     * @param phoneNumber numéro du destinataire (format international recommandé, ex: +237...)
     * @param message     contenu du message
     * @return true si l'envoi a réussi (ou a été journalisé), false sinon
     */
    boolean send(String phoneNumber, String message);

    /**
     * @return nom lisible de la passerelle (pour le logging).
     */
    String name();
}
