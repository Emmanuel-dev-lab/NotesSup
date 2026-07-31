package org.ict4d.notessup.utils;

public class Constants {
    // Database — surchargeable par variables d'environnement, valeurs de
    // developpement local par defaut (voir README pour la configuration).
    public static final String DB_HOST = envOr("NOTESSUP_DB_HOST", "localhost");
    public static final String DB_PORT = envOr("NOTESSUP_DB_PORT", "3306");
    public static final String DB_NAME = envOr("NOTESSUP_DB_NAME", "notessup_db");
    public static final String DB_USER = envOr("NOTESSUP_DB_USER", "notessup_user");
    public static final String DB_PASSWORD = envOr("NOTESSUP_DB_PASSWORD", "notessup_pass");
    public static final String DB_URL = "jdbc:mysql://" + DB_HOST + ":" + DB_PORT + "/" + DB_NAME
        + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";

    // Roles
    public static final String ROLE_CHEF = "CHEF_DEPT";
    public static final String ROLE_ENSEIGNANT = "ENSEIGNANT";
    public static final String ROLE_ETUDIANT = "ETUDIANT";

    // Sessions
    public static final String SESSION_USER = "user";
    public static final String SESSION_ROLE = "role";

    // File paths
    public static final String UPLOAD_DIR = "/tmp/notessup/uploads";

    // Pagination
    public static final int DEFAULT_PAGE_SIZE = 6;

    // Branches/Filières
    // IMPORTANT : ces valeurs doivent correspondre EXACTEMENT aux chaînes stockées en base
    // (colonne `filiere` de etudiant/matiere/user/deliberation), car le filtrage se fait
    // par égalité exacte (WHERE filiere = ?). Le seed (schema.sql) utilise "Informatique" et "Réseaux".
    public static final String[] FILIERES = {"Informatique", "Réseaux"};

    // ===== SMS gateway =====
    // Passerelle SMS active : "console" (log, défaut), "africastalking" ou "smslib".
    // Surchargée par la variable d'environnement SMS_GATEWAY si présente.
    public static final String SMS_GATEWAY = envOr("SMS_GATEWAY", "africastalking");

    // Africa's Talking credentials
    // Secrets fournis par variables d'environnement (voir .env, NON versionné).
    // Aucune clé en dur : défaut vide pour ne jamais committer de secret.
    public static final String AT_USERNAME = envOr("AT_USERNAME", "sandbox");
    public static final String AT_API_KEY  = envOr("AT_API_KEY", "");
    public static final boolean AT_SANDBOX = Boolean.parseBoolean(envOr("AT_SANDBOX", "true"));

    // Configuration modem GSM (utilisée uniquement par SmslibGateway).
    public static final String SMS_MODEM_PORT = envOr("SMS_MODEM_PORT", "/dev/ttyUSB0");
    public static final int SMS_MODEM_BAUD = Integer.parseInt(envOr("SMS_MODEM_BAUD", "115200"));
    public static final String SMS_MODEM_MANUFACTURER = envOr("SMS_MODEM_MANUFACTURER", "");
    public static final String SMS_MODEM_MODEL = envOr("SMS_MODEM_MODEL", "");
    public static final String SMS_MODEM_PIN = envOr("SMS_MODEM_PIN", "");

    private static String envOr(String key, String def) {
        String v = System.getenv(key);
        return (v != null && !v.isBlank()) ? v : def;
    }
}
