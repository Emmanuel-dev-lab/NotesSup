package org.ict4d.notessup.services;

import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.colors.ColorConstants;
import com.itextpdf.kernel.colors.DeviceRgb;

import org.ict4d.notessup.dao.EtudiantDAO;
import org.ict4d.notessup.dao.NoteDAO;
import org.ict4d.notessup.dao.MatiereDAO;
import org.ict4d.notessup.models.Etudiant;
import org.ict4d.notessup.models.Note;
import org.ict4d.notessup.models.Matiere;
import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.util.List;

/**
 * Service pour générer des bulletins au format PDF.
 * Utilise iText 8 pour créer les documents PDF.
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
     */
    public byte[] generateBulletinPDF(Long etudiantId, String session, String anneeAcademique)
            throws SQLException {

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PdfWriter writer = new PdfWriter(baos);
        PdfDocument pdf = new PdfDocument(writer);
        pdf.setDefaultPageSize(PageSize.A4);
        Document document = new Document(pdf);
        document.setMargins(20, 20, 20, 20);

        // Récupérer les informations de l'étudiant
        Etudiant etudiant = etudiantDAO.findById(etudiantId);
        if (etudiant == null) {
            document.close();
            throw new RuntimeException("Étudiant non trouvé");
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
    private void addHeader(Document document, Etudiant etudiant, String session, String anneeAcademique) {

        // Titre
        Paragraph title = new Paragraph("BULLETIN DE NOTES")
                .setFontSize(16)
                .setBold()
                .setTextAlignment(TextAlignment.CENTER);
        document.add(title);

        document.add(new Paragraph(" "));

        // Infos étudiant
        document.add(new Paragraph("Matricule: " + etudiant.getMatricule()).setFontSize(11));
        document.add(new Paragraph("Nom: " + etudiant.getNom() + " " + etudiant.getPrenom()).setFontSize(11));
        document.add(new Paragraph("Filière: " + etudiant.getFiliere()).setFontSize(11));
        document.add(new Paragraph("Année d'étude: " + etudiant.getAnnee()).setFontSize(11));
        document.add(new Paragraph("Session: " + session + " - Année académique: " + anneeAcademique).setFontSize(11));

        document.add(new Paragraph(" "));
    }

    /**
     * Ajoute le tableau des notes.
     */
    private void addNotesTable(Document document, Long etudiantId, String session, String anneeAcademique)
            throws SQLException {

        float[] columnWidths = {20, 25, 12, 12, 12, 19};
        Table table = new Table(UnitValue.createPercentArray(columnWidths));
        table.setWidth(UnitValue.createPercentValue(100));

        // En-têtes du tableau
        addTableHeader(table, "Matière");
        addTableHeader(table, "Code");
        addTableHeader(table, "CC");
        addTableHeader(table, "Examen");
        addTableHeader(table, "Finale");
        addTableHeader(table, "Mention");

        // Données des notes
        List<Note> notes = noteDAO.findByEtudiantSessionAnnee(etudiantId, session, anneeAcademique);

        for (Note note : notes) {
            Matiere matiere = matiereDAO.findById(note.getMatiereId());
            if (matiere != null) {
                addTableCell(table, matiere.getIntitule());
                addTableCell(table, matiere.getCode());
                addTableCell(table, formatNote(note.getNoteCC()));
                addTableCell(table, formatNote(note.getNoteExam()));
                addTableCell(table, formatNote(note.getNoteFinale()));

                String mention = noteService.getMention(note.getNoteFinale());
                addTableCell(table, mention);
            }
        }

        document.add(table);
        document.add(new Paragraph(" "));
    }

    /**
     * Ajoute le résumé académique (moyenne, taux de réussite, situation).
     */
    private void addSummary(Document document, Long etudiantId, String session, String anneeAcademique)
            throws SQLException {

        document.add(new Paragraph("RÉSUMÉ ACADÉMIQUE").setFontSize(12).setBold());

        BigDecimal moyennePonderee = noteService.calcMoyennePonderee(etudiantId, session, anneeAcademique);
        BigDecimal tauxReussite = noteService.calcTauxReussite(etudiantId, session, anneeAcademique);

        document.add(new Paragraph("Moyenne générale: " + moyennePonderee.toString()).setFontSize(11));
        document.add(new Paragraph("Taux de réussite: " + tauxReussite.toString() + "%").setFontSize(11));

        String situation = (moyennePonderee.compareTo(new BigDecimal("10")) >= 0) ? "ADMIS" : "NON ADMIS";
        Paragraph situationPara = new Paragraph("Situation: " + situation).setFontSize(12).setBold();
        
        if ("ADMIS".equals(situation)) {
            situationPara.setFontColor(ColorConstants.GREEN);
        } else {
            situationPara.setFontColor(ColorConstants.RED);
        }
        document.add(situationPara);
    }

    /**
     * Ajoute une cellule d'en-tête au tableau.
     */
    private void addTableHeader(Table table, String text) {
        Cell cell = new Cell()
                .add(new Paragraph(text).setBold().setFontColor(ColorConstants.WHITE))
                .setBackgroundColor(new DeviceRgb(44, 62, 80))
                .setPadding(8);
        table.addHeaderCell(cell);
    }

    /**
     * Ajoute une cellule de données au tableau.
     */
    private void addTableCell(Table table, String text) {
        Cell cell = new Cell()
                .add(new Paragraph(text != null ? text : "-").setFontSize(10))
                .setPadding(5);
        table.addCell(cell);
    }

    /**
     * Formate une note en chaîne de caractères.
     */
    private String formatNote(BigDecimal note) {
        if (note == null) {
            return "-";
        }
        return note.setScale(2, RoundingMode.HALF_UP).toString();
    }
}
