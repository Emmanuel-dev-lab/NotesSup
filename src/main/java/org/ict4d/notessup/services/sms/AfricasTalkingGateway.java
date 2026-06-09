package org.ict4d.notessup.services.sms;

import org.ict4d.notessup.utils.Constants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

/**
 * Passerelle SMS via l'API REST Africa's Talking.
 * Fonctionne en mode sandbox (test) ou production selon AT_SANDBOX.
 * Aucune dépendance Maven supplémentaire — utilise java.net.http.HttpClient (Java 11+).
 *
 * Variables d'environnement requises :
 *   AT_API_KEY  — clé API copiée depuis le dashboard Africa's Talking
 *   AT_USERNAME — "sandbox" (défaut) ou votre username de production
 *   AT_SANDBOX  — "true" (défaut) pour la sandbox, "false" pour la production
 *   SMS_GATEWAY — mettre "africastalking" pour activer cette passerelle
 */
public class AfricasTalkingGateway implements SmsGateway {

    private static final Logger logger = LoggerFactory.getLogger(AfricasTalkingGateway.class);

    private static final String SANDBOX_URL = "https://api.sandbox.africastalking.com/version1/messaging";
    private static final String PROD_URL    = "https://api.africastalking.com/version1/messaging";

    private final HttpClient httpClient;
    private final String endpoint;

    public AfricasTalkingGateway() {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
        this.endpoint = Constants.AT_SANDBOX ? SANDBOX_URL : PROD_URL;

        if (Constants.AT_API_KEY.isBlank()) {
            logger.warn("[SMS africastalking] AT_API_KEY non configurée — les envois échoueront.");
        }
        logger.info("[SMS africastalking] Passerelle initialisée (mode={})", Constants.AT_SANDBOX ? "sandbox" : "production");
    }

    @Override
    public boolean send(String phoneNumber, String message) {
        if (Constants.AT_API_KEY.isBlank()) {
            logger.error("[SMS africastalking] Envoi annulé : AT_API_KEY est vide.");
            return false;
        }

        // Normaliser le numéro : supprimer les espaces (ex: "+237 670112233" → "+237670112233")
        String normalizedPhone = phoneNumber.replaceAll("\\s+", "");

        try {
            String body = "username=" + encode(Constants.AT_USERNAME)
                    + "&to=" + encode(normalizedPhone)
                    + "&message=" + encode(message);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .timeout(Duration.ofSeconds(15))
                    .header("apiKey", Constants.AT_API_KEY)
                    .header("Accept", "application/json")
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            boolean success = response.statusCode() == 201;
            if (success) {
                logger.info("[SMS africastalking] Envoyé -> {} (statut={})", normalizedPhone, response.statusCode());
            } else {
                logger.warn("[SMS africastalking] Échec -> {} (statut={}) : {}", normalizedPhone, response.statusCode(), response.body());
            }
            return success;

        } catch (Exception e) {
            logger.error("[SMS africastalking] Erreur lors de l'envoi vers {}", normalizedPhone, e);
            return false;
        }
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    @Override
    public String name() {
        return "africastalking";
    }
}
