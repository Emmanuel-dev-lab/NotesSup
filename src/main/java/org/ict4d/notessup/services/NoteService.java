package org.ict4d.notessup.services;

import org.ict4d.notessup.models.Note;
import org.ict4d.notessup.dao.NoteDAO;
import org.ict4d.notessup.models.Matiere;
import org.ict4d.notessup.dao.MatiereDAO;
import org.ict4d.notessup.models.Etudiant;
import org.ict4d.notessup.dao.EtudiantDAO;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.util.List;

/**
 * Service pour les calculs et opérations sur les notes.
 * Gère les calculs de notes finales, moyennes, mentions et taux de réussite.
 */
public class NoteService {
    private final NoteDAO noteDAO;
    private final MatiereDAO matiereDAO;
    private final EtudiantDAO etudiantDAO;

    // Barèmes de notation
    private static final BigDecimal NOTE_MINIMAL = BigDecimal.ZERO;
    private static final BigDecimal NOTE_MAXIMAL = new BigDecimal("20");
    private static final BigDecimal SEUIL_ADMISSION = new BigDecimal("10");

    // Mentions et leurs limites
    private static final BigDecimal LIMITE_TB = new BigDecimal("16");      // Très Bien >= 16
    private static final BigDecimal LIMITE_B = new BigDecimal("14");       // Bien >= 14
    private static final BigDecimal LIMITE_AB = new BigDecimal("12");      // Assez Bien >= 12
    private static final BigDecimal LIMITE_P = new BigDecimal("10");       // Passable >= 10

    public NoteService() {
        this.noteDAO = new NoteDAO();
        this.matiereDAO = new MatiereDAO();
        this.etudiantDAO = new EtudiantDAO();
    }

    /**
     * Calcule la note finale à partir de la note de CC et de l'examen.
     * Formule: (noteCC * 0.4) + (noteExam * 0.6)
     * @param noteCC La note de contrôle continu (0-20)
     * @param noteExam La note d'examen (0-20)
     * @return La note finale
     */
    public BigDecimal calcNoteFinale(BigDecimal noteCC, BigDecimal noteExam) {
        if (noteCC == null || noteExam == null) {
            return BigDecimal.ZERO;
        }
        BigDecimal poidCC = new BigDecimal("0.4");
        BigDecimal poidExam = new BigDecimal("0.6");

        BigDecimal noteFinale = noteCC.multiply(poidCC).add(noteExam.multiply(poidExam));
        return noteFinale.setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Retourne la mention correspondant à une note.
     * @param noteFinale La note finale
     * @return La mention (TB, B, AB, P, ou Insuffisant)
     */
    public String getMention(BigDecimal noteFinale) {
        if (noteFinale == null) {
            return "Insuffisant";
        }

        if (noteFinale.compareTo(LIMITE_TB) >= 0) {
            return "Très Bien";
        } else if (noteFinale.compareTo(LIMITE_B) >= 0) {
            return "Bien";
        } else if (noteFinale.compareTo(LIMITE_AB) >= 0) {
            return "Assez Bien";
        } else if (noteFinale.compareTo(LIMITE_P) >= 0) {
            return "Passable";
        } else {
            return "Insuffisant";
        }
    }

    /**
     * Retourne la couleur HTML correspondant à une mention.
     * @param mention La mention
     * @return Code couleur HTML
     */
    public String getMentionColor(String mention) {
        if (mention == null) {
            return "#95a5a6";
        }
        switch (mention) {
            case "Très Bien":
                return "#2ecc71";      // Vert
            case "Bien":
                return "#3498db";      // Bleu
            case "Assez Bien":
                return "#f39c12";      // Orange
            case "Passable":
                return "#e74c3c";      // Rouge
            case "Insuffisant":
                return "#c0392b";      // Rouge foncé
            default:
                return "#95a5a6";      // Gris
        }
    }

    /**
     * Détermine si un étudiant est admis sur la base de la note finale.
     * @param noteFinale La note finale
     * @return true si noteFinale >= 10, false sinon
     */
    public boolean isAdmis(BigDecimal noteFinale) {
        return noteFinale != null && noteFinale.compareTo(SEUIL_ADMISSION) >= 0;
    }

    /**
     * Calcule la moyenne pondérée pour un étudiant.
     * Moyenne pondérée = Σ(note_i * coefficient_i) / Σ(coefficient_i)
     * @param etudiantId L'ID de l'étudiant
     * @param session La session (JAN, JUIN, AOUT, SEPTEMBRE)
     * @param anneeAcademique L'année académique
     * @return La moyenne pondérée, ou 0 si aucune note
     * @throws SQLException Si une erreur de base de données se produit
     */
    public BigDecimal calcMoyennePonderee(Long etudiantId, String session, String anneeAcademique) throws SQLException {
        List<Note> notes = noteDAO.findByEtudiant(etudiantId, 100, 0);

        BigDecimal totalNotes = BigDecimal.ZERO;
        BigDecimal totalCoefficients = BigDecimal.ZERO;

        for (Note note : notes) {
            if (session.equals(note.getSession()) && anneeAcademique.equals(note.getAnneeAcademique())) {
                Matiere matiere = matiereDAO.findById(note.getMatiereId());
                if (matiere != null && note.getNoteFinale() != null) {
                    BigDecimal coeff = new BigDecimal(matiere.getCoefficient());
                    totalNotes = totalNotes.add(note.getNoteFinale().multiply(coeff));
                    totalCoefficients = totalCoefficients.add(coeff);
                }
            }
        }

        if (totalCoefficients.compareTo(BigDecimal.ZERO) > 0) {
            return totalNotes.divide(totalCoefficients, 2, RoundingMode.HALF_UP);
        }
        return BigDecimal.ZERO;
    }

    /**
     * Calcule le taux de réussite pour un étudiant.
     * Taux de réussite = (nombre de matières admises / nombre total de matières) * 100
     * @param etudiantId L'ID de l'étudiant
     * @param session La session
     * @param anneeAcademique L'année académique
     * @return Le taux de réussite en pourcentage (0-100)
     * @throws SQLException Si une erreur de base de données se produit
     */
    public BigDecimal calcTauxReussite(Long etudiantId, String session, String anneeAcademique) throws SQLException {
        List<Note> notes = noteDAO.findByEtudiant(etudiantId, 100, 0);

        int totalMatieres = 0;
        int matiereAdmises = 0;

        for (Note note : notes) {
            if (session.equals(note.getSession()) && anneeAcademique.equals(note.getAnneeAcademique())) {
                totalMatieres++;
                if (isAdmis(note.getNoteFinale())) {
                    matiereAdmises++;
                }
            }
        }

        if (totalMatieres > 0) {
            return new BigDecimal(matiereAdmises)
                    .divide(new BigDecimal(totalMatieres), 2, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal("100"));
        }
        return BigDecimal.ZERO;
    }

    /**
     * Compose les relations (Etudiant, Matiere) pour une liste de notes.
     * C'est la bonne pratique (DTO/Service mapping) au lieu du DB JOIN.
     */
    public void populateNoteRelations(List<Note> notes) throws SQLException {
        for (Note note : notes) {
            if (note.getEtudiantId() != null) {
                note.setEtudiant(etudiantDAO.findById(note.getEtudiantId()));
            }
            if (note.getMatiereId() != null) {
                note.setMatiere(matiereDAO.findById(note.getMatiereId()));
            }
        }
    }
}
