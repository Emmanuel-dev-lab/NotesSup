package org.ict4d.notessup.models;

import java.math.BigDecimal;

public class StatMatiere {
    private String matiereNom;
    private BigDecimal moyenne;
    private BigDecimal max;
    private BigDecimal min;
    private Double tauxReussite;

    public StatMatiere() {}

    public String getMatiereNom() { return matiereNom; }
    public void setMatiereNom(String matiereNom) { this.matiereNom = matiereNom; }

    public BigDecimal getMoyenne() { return moyenne; }
    public void setMoyenne(BigDecimal moyenne) { this.moyenne = moyenne; }

    public BigDecimal getMax() { return max; }
    public void setMax(BigDecimal max) { this.max = max; }

    public BigDecimal getMin() { return min; }
    public void setMin(BigDecimal min) { this.min = min; }

    public Double getTauxReussite() { return tauxReussite; }
    public void setTauxReussite(Double tauxReussite) { this.tauxReussite = tauxReussite; }
}
