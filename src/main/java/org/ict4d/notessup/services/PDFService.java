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
import com.itextpdf.kernel.pdf.canvas.draw.SolidLine;
import com.itextpdf.layout.element.LineSeparator;
import com.itextpdf.layout.properties.VerticalAlignment;

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
import java.util.Date;
import java.text.SimpleDateFormat;

/**
 * Service pour générer des bulletins au format PDF avec un design premium.
 * Basé sur iText 8.
 */
public class PDFService {
    private final EtudiantDAO etudiantDAO = new EtudiantDAO();
    private final NoteDAO noteDAO = new NoteDAO();
    private final MatiereDAO matiereDAO = new MatiereDAO();
    private final NoteService noteService = new NoteService();

    // Couleurs du thème
    private static final DeviceRgb NAVY = new DeviceRgb(44, 62, 80);
    private static final DeviceRgb GRAY_LIGHT = new DeviceRgb(248, 250, 252);
    private static final DeviceRgb BORDER_COLOR = new DeviceRgb(226, 232, 240);
    private static final DeviceRgb SUCCESS = new DeviceRgb(5, 150, 105);
    private static final DeviceRgb INFO = new DeviceRgb(8, 145, 178);
    private static final DeviceRgb WARNING = new DeviceRgb(217, 119, 6);
    private static final DeviceRgb DANGER = new DeviceRgb(220, 38, 38);

    public byte[] generateBulletinPDF(Long etudiantId, String session, String anneeAcademique) throws SQLException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PdfWriter writer = new PdfWriter(baos);
        PdfDocument pdf = new PdfDocument(writer);
        pdf.setDefaultPageSize(PageSize.A4);
        Document document = new Document(pdf);
        document.setMargins(40, 40, 40, 40);

        Etudiant etudiant = etudiantDAO.findById(etudiantId);
        if (etudiant == null) {
            document.close();
            throw new RuntimeException("Étudiant non trouvé");
        }

        List<Note> notes = noteDAO.findByEtudiantSessionAnnee(etudiantId, session, anneeAcademique);

        // 1. En-tête (Logos + Titre)
        addStyledHeader(document, session, anneeAcademique);

        // 2. Grille d'infos étudiant
        addStudentInfoGrid(document, etudiant);

        // 3. Tableau des notes
        addStyledNotesTable(document, notes);

        // 4. Bannière de résultat
        addResultBanner(document, etudiantId, session, anneeAcademique);

        // 5. Zone de signatures
        addSignatures(document);

        // 6. Pied de page
        addFooter(document);

        document.close();
        return baos.toByteArray();
    }

    private void addStyledHeader(Document document, String session, String anneeAcademique) {
        Table headerTable = new Table(UnitValue.createPercentArray(new float[]{1, 4, 1}));
        headerTable.setWidth(UnitValue.createPercentValue(100));
        headerTable.setMarginBottom(20);

        // Logo Gauche (Placeholder)
        headerTable.addCell(new Cell().add(new Paragraph("Logo\nUniv.").setFontSize(8).setTextAlignment(TextAlignment.CENTER))
                .setVerticalAlignment(VerticalAlignment.MIDDLE).setBorder(null));

        // Info Centrale
        Cell centerCell = new Cell().add(new Paragraph("Université de l'ICT").setBold().setFontSize(12).setTextAlignment(TextAlignment.CENTER))
                .add(new Paragraph("UFR Sciences & Technologies · Département Informatique").setFontSize(9).setFontColor(ColorConstants.GRAY).setTextAlignment(TextAlignment.CENTER))
                .add(new Paragraph("BULLETIN DE NOTES").setBold().setFontSize(18).setFontColor(NAVY).setMarginTop(5).setTextAlignment(TextAlignment.CENTER))
                .add(new Paragraph("Session " + session + " — " + anneeAcademique).setFontSize(10).setTextAlignment(TextAlignment.CENTER))
                .setBorder(null);
        headerTable.addCell(centerCell);

        // Logo Droite (Placeholder)
        headerTable.addCell(new Cell().add(new Paragraph("Logo\nDépt.").setFontSize(8).setTextAlignment(TextAlignment.CENTER))
                .setVerticalAlignment(VerticalAlignment.MIDDLE).setBorder(null));

        document.add(headerTable);
    }

    private void addStudentInfoGrid(Document document, Etudiant etudiant) {
        Table infoTable = new Table(UnitValue.createPercentArray(new float[]{1, 1, 1}));
        infoTable.setWidth(UnitValue.createPercentValue(100));
        infoTable.setMarginBottom(20);

        infoTable.addCell(createInfoCell("NOM", etudiant.getNom()));
        infoTable.addCell(createInfoCell("PRÉNOM", etudiant.getPrenom()));
        infoTable.addCell(createInfoCell("MATRICULE", etudiant.getMatricule()));
        infoTable.addCell(createInfoCell("FILIÈRE", etudiant.getFiliere()));
        infoTable.addCell(createInfoCell("ANNÉE", "Licence " + etudiant.getAnnee()));
        infoTable.addCell(createInfoCell("TÉLÉPHONE", etudiant.getTelephone() != null ? etudiant.getTelephone() : "—"));

        document.add(infoTable);
    }

    private Cell createInfoCell(String label, String value) {
        Cell cell = new Cell().setPadding(8).setBorder(new com.itextpdf.layout.borders.SolidBorder(BORDER_COLOR, 0.5f));
        cell.add(new Paragraph(label).setFontSize(8).setBold().setFontColor(ColorConstants.GRAY));
        cell.add(new Paragraph(value != null ? value : "—").setFontSize(10).setBold().setFontColor(NAVY));
        return cell;
    }

    private void addStyledNotesTable(Document document, List<Note> notes) throws SQLException {
        Table table = new Table(UnitValue.createPercentArray(new float[]{12, 28, 10, 10, 10, 12, 18}));
        table.setWidth(UnitValue.createPercentValue(100));

        // Header
        String[] headers = {"CODE", "MATIÈRE", "COEFF", "CC", "EXAM", "MOY", "MENTION"};
        for (String h : headers) {
            table.addHeaderCell(new Cell().add(new Paragraph(h).setBold().setFontColor(ColorConstants.WHITE).setFontSize(9))
                    .setBackgroundColor(NAVY).setPadding(8).setTextAlignment(TextAlignment.CENTER));
        }

        BigDecimal totalPoints = BigDecimal.ZERO;
        int totalCoeff = 0;

        if (notes.isEmpty()) {
            table.addCell(new Cell(1, 7).add(new Paragraph("Aucune note enregistrée").setTextAlignment(TextAlignment.CENTER).setPadding(20)));
        } else {
            for (Note note : notes) {
                Matiere matiere = matiereDAO.findById(note.getMatiereId());
                if (matiere != null) {
                    table.addCell(createDataCell(matiere.getCode(), TextAlignment.CENTER).setFontColor(INFO));
                    table.addCell(createDataCell(matiere.getIntitule(), TextAlignment.LEFT));
                    table.addCell(createDataCell(String.valueOf(matiere.getCoefficient()), TextAlignment.CENTER));
                    table.addCell(createDataCell(formatNote(note.getNoteCC()), TextAlignment.RIGHT));
                    table.addCell(createDataCell(formatNote(note.getNoteExam()), TextAlignment.RIGHT));

                    BigDecimal finale = note.getNoteFinale();
                    DeviceRgb noteColor = getNoteColor(finale);
                    table.addCell(createDataCell(formatNote(finale), TextAlignment.RIGHT).setBold().setFontColor(noteColor));
                    table.addCell(createDataCell(noteService.getMention(finale), TextAlignment.LEFT));

                    if (finale != null) {
                        totalPoints = totalPoints.add(finale.multiply(new BigDecimal(matiere.getCoefficient())));
                        totalCoeff += matiere.getCoefficient();
                    }
                }
            }
        }

        // Total Row
        table.addCell(new Cell(1, 2).add(new Paragraph("TOTAL / MOYENNE").setBold().setFontColor(ColorConstants.WHITE))
                .setBackgroundColor(NAVY).setPadding(8));
        table.addCell(createTotalCell(totalCoeff > 0 ? String.valueOf(totalCoeff) : ""));
        table.addCell(new Cell().setBackgroundColor(NAVY).setBorder(null));
        table.addCell(new Cell().setBackgroundColor(NAVY).setBorder(null));
        
        BigDecimal moyenne = totalCoeff > 0 ? totalPoints.divide(new BigDecimal(totalCoeff), 2, RoundingMode.HALF_UP) : null;
        table.addCell(createTotalCell(moyenne != null ? formatNote(moyenne) : ""));
        table.addCell(createTotalCell(totalPoints.compareTo(BigDecimal.ZERO) > 0 ? totalPoints.setScale(2, RoundingMode.HALF_UP).toString() : ""));

        document.add(table);
    }

    private Cell createDataCell(String text, TextAlignment align) {
        return new Cell().add(new Paragraph(text != null ? text : "-").setFontSize(9))
                .setPadding(5).setTextAlignment(align).setVerticalAlignment(VerticalAlignment.MIDDLE);
    }

    private Cell createTotalCell(String text) {
        return new Cell().add(new Paragraph(text).setBold().setFontColor(ColorConstants.WHITE).setFontSize(10))
                .setBackgroundColor(NAVY).setPadding(8).setTextAlignment(TextAlignment.RIGHT);
    }

    private void addResultBanner(Document document, Long etudiantId, String session, String anneeAcademique) throws SQLException {
        BigDecimal moyenne = noteService.calcMoyennePonderee(etudiantId, session, anneeAcademique);
        if (moyenne == null) return;
        
        boolean admis = moyenne.compareTo(new BigDecimal("10")) >= 0;
        DeviceRgb bannerColor = admis ? SUCCESS : DANGER;

        Table bannerTable = new Table(UnitValue.createPercentArray(new float[]{1, 1}));
        bannerTable.setWidth(UnitValue.createPercentValue(100));
        bannerTable.setMarginTop(20);
        bannerTable.setBackgroundColor(GRAY_LIGHT).setBorder(new com.itextpdf.layout.borders.SolidBorder(bannerColor, 1f));

        Cell leftCell = new Cell().add(new Paragraph("MOYENNE GÉNÉRALE").setFontSize(9).setFontColor(NAVY))
                .add(new Paragraph(formatNote(moyenne) + "/20").setBold().setFontSize(22).setFontColor(bannerColor))
                .setBorder(null).setPadding(15);
        
        Cell rightCell = new Cell().add(new Paragraph(admis ? "✓ ADMIS(E)" : "✗ AJOURNÉ(E)")
                .setBold().setFontSize(16).setFontColor(bannerColor).setTextAlignment(TextAlignment.RIGHT))
                .add(new Paragraph(noteService.getMention(moyenne)).setFontSize(12).setTextAlignment(TextAlignment.RIGHT))
                .setBorder(null).setPadding(15).setVerticalAlignment(VerticalAlignment.MIDDLE);

        bannerTable.addCell(leftCell);
        bannerTable.addCell(rightCell);
        document.add(bannerTable);
    }

    private void addSignatures(Document document) {
        Table sigTable = new Table(UnitValue.createPercentArray(new float[]{1, 1, 1}));
        sigTable.setWidth(UnitValue.createPercentValue(100));
        sigTable.setMarginTop(40);

        String[] titles = {"Directeur de Filière", "Chef de Département", "Directeur des Études"};
        for (String title : titles) {
            sigTable.addCell(new Cell().add(new Paragraph(title).setFontSize(9).setBold().setMarginBottom(50))
                    .add(new LineSeparator(new SolidLine(0.5f)))
                    .setBorder(null).setPaddingRight(10).setPaddingLeft(10).setTextAlignment(TextAlignment.CENTER));
        }
        document.add(sigTable);
    }

    private void addFooter(Document document) {
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        Paragraph footer = new Paragraph("Généré par NotesSup · ICT 423 · " + sdf.format(new Date()))
                .setFontSize(8).setFontColor(ColorConstants.GRAY).setMarginTop(20).setTextAlignment(TextAlignment.CENTER);
        document.add(footer);
    }

    private DeviceRgb getNoteColor(BigDecimal note) {
        if (note == null) return NAVY;
        if (note.compareTo(new BigDecimal("16")) >= 0) return SUCCESS;
        if (note.compareTo(new BigDecimal("14")) >= 0) return INFO;
        if (note.compareTo(new BigDecimal("12")) >= 0) return NAVY;
        if (note.compareTo(new BigDecimal("10")) >= 0) return WARNING;
        return DANGER;
    }

    private String formatNote(BigDecimal note) {
        if (note == null) return "-";
        return note.setScale(2, RoundingMode.HALF_UP).toString();
    }
}
