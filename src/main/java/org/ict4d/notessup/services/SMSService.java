package org.ict4d.notessup.services;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.ict4d.notessup.dao.EtudiantDAO;
import org.ict4d.notessup.models.Etudiant;
import org.ict4d.notessup.services.sms.SmsGateway;
import org.ict4d.notessup.services.sms.SmsGatewayFactory;
import java.math.BigDecimal;
import java.sql.SQLException;

/**
 * Service métier pour les notifications SMS aux étudiants.
 * L'envoi réel est délégué à une {@link SmsGateway} (console par défaut,
 * SMSLib si un modem GSM est configuré).
 */
public class SMSService {
    private static final Logger logger = LoggerFactory.getLogger(SMSService.class);
    private final EtudiantDAO etudiantDAO;
    private final SmsGateway gateway;

    // Modèles de messages
    private static final String PUBLICATION_TEMPLATE = "Vos notes sont disponibles. Moyenne : %.2f/20. Mention : %s";
    private static final String ALERT_TEMPLATE = "Attention : votre moyenne est de %.2f/20. Presentez-vous a la scolarite";

    public SMSService() {
        this.etudiantDAO = new EtudiantDAO();
        this.gateway = SmsGatewayFactory.get();
    }

    /**
     * Envoie une notification SMS simulée pour la publication des notes.
     * Intègre le concept de passerelle SMS pluggable requis par SMSLib.
     */
    public boolean sendSMSNotification(Long etudiantId, BigDecimal moyenne, String mention) throws SQLException {
        Etudiant etudiant = etudiantDAO.findById(etudiantId);
        if (etudiant == null || etudiant.getTelephone() == null || etudiant.getTelephone().isEmpty()) {
            logger.warn("SMS non envoyé: Étudiant {} non trouvé ou sans numéro de téléphone", etudiantId);
            return false;
        }

        String message;
        if (moyenne != null && moyenne.compareTo(new BigDecimal("10")) >= 0) {
            message = getPublicationMessage(moyenne, mention);
        } else {
            message = getAlertMessage(moyenne != null ? moyenne : BigDecimal.ZERO);
        }

        return gateway.send(etudiant.getTelephone(), message);
    }

    /**
     * Envoie des notifications en masse lors de la délibération.
     */
    public void sendBulkPublicationAlert(java.util.List<Etudiant> etudiants, java.util.Map<Long, BigDecimal> moyennes, java.util.Map<Long, String> mentions) {
        logger.info("Démarrage de l'envoi groupé de SMS");
        for (Etudiant e : etudiants) {
            if (e.getTelephone() != null && !e.getTelephone().isEmpty()) {
                BigDecimal moy = moyennes.get(e.getId());
                String ment = mentions.get(e.getId());

                String msg;
                if (moy != null && moy.compareTo(new BigDecimal("10")) >= 0) {
                    msg = getPublicationMessage(moy, ment);
                } else {
                    msg = getAlertMessage(moy != null ? moy : BigDecimal.ZERO);
                }

                gateway.send(e.getTelephone(), msg);
            }
        }
    }

    /**
     * Envoie une notification d'alerte SMS en cas de non-admission.
     * @param etudiantId L'ID de l'étudiant
     * @param moyenne La moyenne générale
     * @return true si l'envoi est réussi (simulé)
     * @throws SQLException Si une erreur de base de données se produit
     */
    public boolean sendAlertSMS(Long etudiantId, BigDecimal moyenne) throws SQLException {
        Etudiant etudiant = etudiantDAO.findById(etudiantId);
        if (etudiant == null || etudiant.getTelephone() == null) {
            logger.warn("SMS d'alerte non envoyé: Étudiant {} non trouvé ou sans numéro de téléphone", etudiantId);
            return false;
        }

        String message = getAlertMessage(moyenne);
        return gateway.send(etudiant.getTelephone(), message);
    }

    /**
     * Génère le message de publication des notes.
     * @param moyenne La moyenne générale
     * @param mention La mention obtenue
     * @return Le message formaté
     */
    public String getPublicationMessage(BigDecimal moyenne, String mention) {
        return String.format(java.util.Locale.US, PUBLICATION_TEMPLATE, moyenne, mention);
    }

    /**
     * Génère le message d'alerte en cas de non-admission.
     * @param moyenne La moyenne générale
     * @return Le message formaté
     */
    public String getAlertMessage(BigDecimal moyenne) {
        return String.format(java.util.Locale.US, ALERT_TEMPLATE, moyenne);
    }
}
