package org.ict4d.notessup.utils;

public class Constants {
    // Database
    public static final String DB_HOST = "localhost";
    public static final String DB_PORT = "3306";
    public static final String DB_NAME = "notessup_db";
    public static final String DB_USER = "notessup_user";
    public static final String DB_PASSWORD = "notessup_pass";
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
    public static final String[] FILIERES = {"Informatique", "Génie Logiciel", "Réseaux et Télécoms", "Sécurité Informatique", "Data Science"};

    // ===== SMS gateway =====
    // Passerelle SMS active : "console" (log, défaut), "africastalking" ou "smslib".
    // Surchargée par la variable d'environnement SMS_GATEWAY si présente.
    public static final String SMS_GATEWAY = envOr("SMS_GATEWAY", "console");

    // Africa's Talking credentials
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
