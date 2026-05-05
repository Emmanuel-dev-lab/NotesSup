package org.ict4d.notessup.models;

import java.math.BigDecimal;

public class FiliereStat {
    private String filiere;
    private int nbEtudiants;
    private BigDecimal moyenne;
    private BigDecimal tauxReussite;

    public String getFiliere() { return filiere; }
    public void setFiliere(String filiere) { this.filiere = filiere; }

    public int getNbEtudiants() { return nbEtudiants; }
    public void setNbEtudiants(int nbEtudiants) { this.nbEtudiants = nbEtudiants; }

    public BigDecimal getMoyenne() { return moyenne; }
    public void setMoyenne(BigDecimal moyenne) { this.moyenne = moyenne; }

    public BigDecimal getTauxReussite() { return tauxReussite; }
    public void setTauxReussite(BigDecimal tauxReussite) { this.tauxReussite = tauxReussite; }
}
