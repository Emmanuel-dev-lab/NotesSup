package org.ict4d.notessup.models;

public class User {
    private Long id;
    private String login;
    private String password;
    private String role;
    private String nom;
    private String filiere;
    private Long etudiantId;

    public User() {}

    public User(String login, String password, String role, String nom) {
        this.login = login;
        this.password = password;
        this.role = role;
        this.nom = nom;
    }

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getLogin() { return login; }
    public void setLogin(String login) { this.login = login; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getFiliere() { return filiere; }
    public void setFiliere(String filiere) { this.filiere = filiere; }

    public Long getEtudiantId() { return etudiantId; }
    public void setEtudiantId(Long etudiantId) { this.etudiantId = etudiantId; }
}
