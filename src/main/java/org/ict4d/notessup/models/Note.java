package org.ict4d.notessup.models;

import java.math.BigDecimal;

public class Note {
    private Long id;
    private Long etudiantId;
    private Long matiereId;
    private BigDecimal noteCC;
    private BigDecimal noteExam;
    private BigDecimal noteFinale;
    private String session;
    private String anneeAcademique;
    private String saisiePar;
    
    // O-O Relations
    private Etudiant etudiant;
    private Matiere matiere;

    public Note() {}

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getEtudiantId() { return etudiantId; }
    public void setEtudiantId(Long etudiantId) { this.etudiantId = etudiantId; }

    public Long getMatiereId() { return matiereId; }
    public void setMatiereId(Long matiereId) { this.matiereId = matiereId; }

    public BigDecimal getNoteCC() { return noteCC; }
    public void setNoteCC(BigDecimal noteCC) { this.noteCC = noteCC; }

    public BigDecimal getNoteExam() { return noteExam; }
    public void setNoteExam(BigDecimal noteExam) { this.noteExam = noteExam; }

    public BigDecimal getNoteFinale() { return noteFinale; }
    public void setNoteFinale(BigDecimal noteFinale) { this.noteFinale = noteFinale; }

    public String getSession() { return session; }
    public void setSession(String session) { this.session = session; }

    public String getAnneeAcademique() { return anneeAcademique; }
    public void setAnneeAcademique(String anneeAcademique) { this.anneeAcademique = anneeAcademique; }

    public String getSaisiePar() { return saisiePar; }
    public void setSaisiePar(String saisiePar) { this.saisiePar = saisiePar; }

    public Etudiant getEtudiant() { return etudiant; }
    public void setEtudiant(Etudiant etudiant) { this.etudiant = etudiant; }

    public Matiere getMatiere() { return matiere; }
    public void setMatiere(Matiere matiere) { this.matiere = matiere; }
}
