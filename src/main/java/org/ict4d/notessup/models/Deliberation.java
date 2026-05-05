package org.ict4d.notessup.models;

import java.time.LocalDate;

public class Deliberation {
    private Long id;
    private String filiere;
    private String session;
    private String anneeAcademique;
    private LocalDate datePublication;
    private Boolean publiee;
    private String publiePar;

    public Deliberation() {}

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getFiliere() { return filiere; }
    public void setFiliere(String filiere) { this.filiere = filiere; }

    public String getSession() { return session; }
    public void setSession(String session) { this.session = session; }

    public String getAnneeAcademique() { return anneeAcademique; }
    public void setAnneeAcademique(String anneeAcademique) { this.anneeAcademique = anneeAcademique; }

    public LocalDate getDatePublication() { return datePublication; }
    public void setDatePublication(LocalDate datePublication) { this.datePublication = datePublication; }

    public Boolean getPubliee() { return publiee; }
    public void setPubliee(Boolean publiee) { this.publiee = publiee; }

    public String getPubliePar() { return publiePar; }
    public void setPubliePar(String publiePar) { this.publiePar = publiePar; }

    public java.util.Date getLegacyDatePublication() {
        if (datePublication == null) return null;
        return java.sql.Date.valueOf(datePublication);
    }
}
