package org.ict4d.notessup.services;

import org.ict4d.notessup.models.User;
import org.ict4d.notessup.dao.UserDAO;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.SQLException;

/**
 * Service pour gérer l'authentification des utilisateurs.
 * Utilise BCrypt pour le hash et la validation des mots de passe.
 */
public class AuthService {
    private final UserDAO userDAO;

    public AuthService() {
        this.userDAO = new UserDAO();
    }

    /**
     * Hash un mot de passe en clair avec BCrypt.
     * @param password Le mot de passe en clair
     * @return Le mot de passe hashé
     */
    public String hashPassword(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt());
    }

    /**
     * Valide un mot de passe en clair contre son hash BCrypt.
     * @param password Le mot de passe en clair
     * @param hashedPassword Le mot de passe hashé
     * @return true si le mot de passe est valide, false sinon
     */
    public boolean validatePassword(String password, String hashedPassword) {
        return BCrypt.checkpw(password, hashedPassword);
    }

    /**
     * Authentifie un utilisateur par login et mot de passe.
     * @param login Le login de l'utilisateur
     * @param password Le mot de passe en clair
     * @return L'utilisateur authentifié, ou null si les identifiants sont invalides
     * @throws SQLException Si une erreur de base de données se produit
     */
    public User authenticate(String login, String password) throws SQLException {
        User user = userDAO.findByLogin(login);
        if (user != null && validatePassword(password, user.getPassword())) {
            return user;
        }
        return null;
    }

    /**
     * Crée un nouvel utilisateur avec mot de passe hashé.
     * @param login Le login unique
     * @param password Le mot de passe en clair
     * @param role Le rôle de l'utilisateur (ADMIN, ENSEIGNANT, ETUDIANT)
     * @param nom Le nom complet de l'utilisateur
     * @return L'utilisateur créé
     * @throws SQLException Si une erreur de base de données se produit
     */
    public User createUser(String login, String password, String role, String nom) throws SQLException {
        User user = new User(login, hashPassword(password), role, nom);
        userDAO.insert(user);
        return user;
    }
}
