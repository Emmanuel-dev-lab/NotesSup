package org.ict4d.notessup.utils;

public class ValidationUtils {
    public static boolean isValidEmail(String email) {
        return email != null && email.matches("^[A-Za-z0-9+_.-]+@(.+)$");
    }

    public static boolean isValidPhone(String phone) {
        return phone != null && phone.matches("^\\+?[0-9\\s\\-()]{10,}$");
    }

    public static boolean isValidAnnee(int annee) {
        return annee >= 1 && annee <= 5;
    }

    public static boolean isValidCoeff(int coeff) {
        return coeff >= 1 && coeff <= 6;
    }

    public static boolean isValidNote(double note) {
        return note >= 0 && note <= 20;
    }

    public static String sanitize(String input) {
        if (input == null) return "";
        return input.replaceAll("[<>\"']", "");
    }
}
