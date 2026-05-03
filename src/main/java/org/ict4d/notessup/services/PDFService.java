package org.ict4d.notessup.services;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import org.ict4d.notessup.dao.EtudiantDAO;
import org.ict4d.notessup.dao.NoteDAO;
import org.ict4d.notessup.dao.MatiereDAO;
import org.ict4d.notessup.models.Etudiant;
import org.ict4d.notessup.models.Note;
import org.ict4d.notessup.models.Matiere;
import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

/**
 * Service pour générer des bulletins au format PDF.
 * Utilise iText 5 pour créer les documents PDF.
 */
public class PDFService {
    private final EtudiantDAO etudiantDAO;
    private final NoteDAO noteDAO;
    private final MatiereDAO matiereDAO;
    private final NoteService noteService;

    public PDFService() {
        this.etudiantDAO = new EtudiantDAO();
        this.noteDAO = new NoteDAO();
        this.matiereDAO = new MatiereDAO();
        this.noteService = new NoteService();
    }

    /**
     * Génère un bulletin PDF pour un étudiant pour une session donnée.
     * @param etudiantId L'ID de l'étudiant
     * @param session La session (JAN, JUIN, AOUT, SEPTEMBRE)
     * @param anneeAcademique L'année académique (ex: 2023/2024)
     * @return Un tableau de bytes contenant le PDF
     * @throws SQLException Si une erreur de base de données se produit
     * @throws DocumentException Si une erreur lors de la création du PDF se produit
     */
    public byte[] generateBulletinPDF(Long etudiantId, String session, String anneeAcademique)
            throws SQLException, DocumentException {

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4, 20, 20, 20, 20);
        PdfWriter.getInstance(document, baos);
        document.open();

        // Récupérer les informations de l'étudiant
        Etudiant etudiant = etudiantDAO.findById(etudiantId);
        if (etudiant == null) {
            document.close();
            throw new DocumentException("Étudiant non trouvé");
        }

        // En-tête du document
        addHeader(document, etudiant, session, anneeAcademique);

        // Tableau des notes
        addNotesTable(document, etudiantId, session, anneeAcademique);

        // Résumé académique
        addSummary(document, etudiantId, session, anneeAcademique);

        document.close();
        return baos.toByteArray();
    }

    /**
     * Ajoute l'en-tête du bulletin (titre, infos étudiant, session).
     */
    private void addHeader(Document document, Etudiant etudiant, String session, String anneeAcademique)
            throws DocumentException {

        // Titre
        Font titleFont = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD);
        Paragraph title = new Paragraph("BULLETIN DE NOTES", titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        document.add(title);

        document.add(new Paragraph(" "));

        // Infos étudiant
        Font normalFont = new Font(Font.FontFamily.HELVETICA, 11);
        document.add(new Paragraph("Matricule: " + etudiant.getMatricule(), normalFont));
        document.add(new Paragraph("Nom: " + etudiant.getNom() + " " + etudiant.getPrenom(), normalFont));
        document.add(new Paragraph("Filière: " + etudiant.getFiliere(), normalFont));
        document.add(new Paragraph("Année d'étude: " + etudiant.getAnnee(), normalFont));
        document.add(new Paragraph("Session: " + session + " - Année académique: " + anneeAcademique, normalFont));

        document.add(new Paragraph(" "));
    }

    /**
     * Ajoute le tableau des notes.
     */
    private void addNotesTable(Document document, Long etudiantId, String session, String anneeAcademique)
            throws SQLException, DocumentException {

        PdfPTable table = new PdfPTable(6);
        table.setWidthPercentage(100);
        float[] columnWidths = {20, 25, 12, 12, 12, 19};
        table.setWidths(columnWidths);

        // En-têtes du tableau
        Font headerFont = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD);
        headerFont.setColor(BaseColor.WHITE);

        addTableHeader(table, "Matière", headerFont);
        addTableHeader(table, "Code", headerFont);
        addTableHeader(table, "CC", headerFont);
        addTableHeader(table, "Examen", headerFont);
        addTableHeader(table, "Finale", headerFont);
        addTableHeader(table, "Mention", headerFont);

        // Données des notes
        List<Note> notes = noteDAO.findByEtudiant(etudiantId, 100, 0);

        Font dataFont = new Font(Font.FontFamily.HELVETICA, 10);

        for (Note note : notes) {
            if (session.equals(note.getSession()) && anneeAcademique.equals(note.getAnneeAcademique())) {
                Matiere matiere = matiereDAO.findById(note.getMatiereId());
                if (matiere != null) {
                    addTableCell(table, matiere.getIntitule(), dataFont);
                    addTableCell(table, matiere.getCode(), dataFont);
                    addTableCell(table, formatNote(note.getNoteCC()), dataFont);
                    addTableCell(table, formatNote(note.getNoteExam()), dataFont);
                    addTableCell(table, formatNote(note.getNoteFinale()), dataFont);

                    String mention = noteService.getMention(note.getNoteFinale());
                    addTableCell(table, mention, dataFont);
                }
            }
        }

        document.add(table);
        document.add(new Paragraph(" "));
    }

    /**
     * Ajoute le résumé académique (moyenne, taux de réussite, situation).
     */
    private void addSummary(Document document, Long etudiantId, String session, String anneeAcademique)
            throws SQLException, DocumentException {

        Font summaryTitleFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
        Font summaryFont = new Font(Font.FontFamily.HELVETICA, 11);

        document.add(new Paragraph("RÉSUMÉ ACADÉMIQUE", summaryTitleFont));

        BigDecimal moyennePonderee = noteService.calcMoyennePonderee(etudiantId, session, anneeAcademique);
        BigDecimal tauxReussite = noteService.calcTauxReussite(etudiantId, session, anneeAcademique);

        document.add(new Paragraph("Moyenne générale: " + moyennePonderee.toString(), summaryFont));
        document.add(new Paragraph("Taux de réussite: " + tauxReussite.toString() + "%", summaryFont));

        String situation = (moyennePonderee.compareTo(new BigDecimal("10")) >= 0) ? "ADMIS" : "NON ADMIS";
        Font situationFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
        if ("ADMIS".equals(situation)) {
            situationFont.setColor(BaseColor.GREEN);
        } else {
            situationFont.setColor(BaseColor.RED);
        }
        document.add(new Paragraph("Situation: " + situation, situationFont));
    }

    /**
     * Ajoute une cellule d'en-tête au tableau.
     */
    private void addTableHeader(PdfPTable table, String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(new BaseColor(44, 62, 80));
        cell.setPadding(8);
        table.addCell(cell);
    }

    /**
     * Ajoute une cellule de données au tableau.
     */
    private void addTableCell(PdfPTable table, String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text != null ? text : "-", font));
        cell.setPadding(5);
        table.addCell(cell);
    }

    /**
     * Formate une note en chaîne de caractères.
     */
    private String formatNote(BigDecimal note) {
        if (note == null) {
            return "-";
        }
        return note.setScale(2, BigDecimal.ROUND_HALF_UP).toString();
    }
}
