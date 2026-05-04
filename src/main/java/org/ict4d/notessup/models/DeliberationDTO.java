package org.ict4d.notessup.models;

import java.math.BigDecimal;

public class DeliberationDTO {
    private Deliberation deliberation;
    private Integer nbEtudiants;
    private Integer nbAdmis;
    private BigDecimal moyenne;

    public DeliberationDTO(Deliberation deliberation) {
        this.deliberation = deliberation;
    }

    public Deliberation getDeliberation() { return deliberation; }
    public void setDeliberation(Deliberation deliberation) { this.deliberation = deliberation; }

    public Integer getNbEtudiants() { return nbEtudiants; }
    public void setNbEtudiants(Integer nbEtudiants) { this.nbEtudiants = nbEtudiants; }

    public Integer getNbAdmis() { return nbAdmis; }
    public void setNbAdmis(Integer nbAdmis) { this.nbAdmis = nbAdmis; }

    public BigDecimal getMoyenne() { return moyenne; }
    public void setMoyenne(BigDecimal moyenne) { this.moyenne = moyenne; }
}
