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
    private static final String PUBLICATION_TEMPLATE = "Bonjour %s, les notes de la session %s (%s) ont été publiées. Consultez votre bulletin sur la plateforme.";
    private static final String ALERT_TEMPLATE = "Alerte %s: Vous n'êtes pas admis à la session %s (%s). Moyenne: %.2f. Contactez votre coordinateur.";

    public SMSService() {
        this.etudiantDAO = new EtudiantDAO();
        this.gateway = SmsGatewayFactory.get();
    }

    /**
     * Envoie une notification SMS simulée pour la publication des notes.
     * Intègre le concept de passerelle SMS pluggable requis par SMSLib.
     */
    public boolean sendSMSNotification(Long etudiantId, String session, String anneeAcademique) throws SQLException {
        Etudiant etudiant = etudiantDAO.findById(etudiantId);
        if (etudiant == null || etudiant.getTelephone() == null || etudiant.getTelephone().isEmpty()) {
            logger.warn("SMS non envoyé: Étudiant {} non trouvé ou sans numéro de téléphone", etudiantId);
            return false;
        }

        String message = getPublicationMessage(etudiant, session, anneeAcademique);
        return gateway.send(etudiant.getTelephone(), message);
    }

    /**
     * Envoie des notifications en masse lors de la délibération.
     */
    public void sendBulkPublicationAlert(java.util.List<Etudiant> etudiants, String session, String annee) {
        logger.info("Démarrage de l'envoi groupé de SMS pour la session {} {}", session, annee);
        for (Etudiant e : etudiants) {
            if (e.getTelephone() != null && !e.getTelephone().isEmpty()) {
                String msg = getPublicationMessage(e, session, annee);
                gateway.send(e.getTelephone(), msg);
            }
        }
    }

    /**
     * Envoie une notification d'alerte SMS en cas de non-admission.
     * @param etudiantId L'ID de l'étudiant
     * @param session La session
     * @param anneeAcademique L'année académique
     * @param moyennes La moyenne générale
     * @return true si l'envoi est réussi (simulé)
     * @throws SQLException Si une erreur de base de données se produit
     */
    public boolean sendAlertSMS(Long etudiantId, String session, String anneeAcademique, BigDecimal moyennes) throws SQLException {
        Etudiant etudiant = etudiantDAO.findById(etudiantId);
        if (etudiant == null || etudiant.getTelephone() == null) {
            logger.warn("SMS d'alerte non envoyé: Étudiant {} non trouvé ou sans numéro de téléphone", etudiantId);
            return false;
        }

        String message = getAlertMessage(etudiant, session, anneeAcademique, moyennes);
        return gateway.send(etudiant.getTelephone(), message);
    }

    /**
     * Génère le message de publication des notes.
     * @param etudiant L'objet Etudiant
     * @param session La session
     * @param anneeAcademique L'année académique
     * @return Le message formaté
     */
    public String getPublicationMessage(Etudiant etudiant, String session, String anneeAcademique) {
        String prenom = etudiant.getPrenom() != null ? etudiant.getPrenom() : "";
        return String.format(PUBLICATION_TEMPLATE, prenom, session, anneeAcademique);
    }

    /**
     * Génère le message d'alerte en cas de non-admission.
     * @param etudiant L'objet Etudiant
     * @param session La session
     * @param anneeAcademique L'année académique
     * @param moyenne La moyenne générale
     * @return Le message formaté
     */
    public String getAlertMessage(Etudiant etudiant, String session, String anneeAcademique, BigDecimal moyenne) {
        String prenom = etudiant.getPrenom() != null ? etudiant.getPrenom() : "";
        return String.format(ALERT_TEMPLATE, prenom, session, anneeAcademique, moyenne);
    }
}
