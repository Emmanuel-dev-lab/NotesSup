package org.ict4d.notessup.models;

public class Matiere {
    private Long id;
    private String code;
    private String intitule;
    private Integer coefficient;
    private String enseignant;
    private Integer semestre;
    private String filiere;

    public Matiere() {}

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getIntitule() { return intitule; }
    public void setIntitule(String intitule) { this.intitule = intitule; }

    public Integer getCoefficient() { return coefficient; }
    public void setCoefficient(Integer coefficient) { this.coefficient = coefficient; }

    public String getEnseignant() { return enseignant; }
    public void setEnseignant(String enseignant) { this.enseignant = enseignant; }

    public Integer getSemestre() { return semestre; }
    public void setSemestre(Integer semestre) { this.semestre = semestre; }

    public String getFiliere() { return filiere; }
    public void setFiliere(String filiere) { this.filiere = filiere; }
}
