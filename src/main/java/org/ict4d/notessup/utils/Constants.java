package org.ict4d.notessup.utils;

public class Constants {
    // Database
    public static final String DB_HOST = "localhost";
    public static final String DB_PORT = "3306";
    public static final String DB_NAME = "notessup_db";
    public static final String DB_USER = "notessup_user";
    public static final String DB_PASSWORD = "notessup_pass";
    public static final String DB_URL = "jdbc:mysql://" + DB_HOST + ":" + DB_PORT + "/" + DB_NAME
        + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";

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
}
