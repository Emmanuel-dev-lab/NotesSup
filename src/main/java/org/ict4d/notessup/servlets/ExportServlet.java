package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.ict4d.notessup.dao.EtudiantDAO;
import org.ict4d.notessup.dao.NoteDAO;
import org.ict4d.notessup.dao.MatiereDAO;
import org.ict4d.notessup.models.Etudiant;
import org.ict4d.notessup.models.Note;
import org.ict4d.notessup.models.Matiere;
import org.ict4d.notessup.services.NoteService;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

public class ExportServlet extends HttpServlet {
    private final EtudiantDAO etudiantDAO = new EtudiantDAO();
    private final NoteDAO noteDAO = new NoteDAO();
    private final MatiereDAO matiereDAO = new MatiereDAO();
    private final NoteService noteService = new NoteService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String type = req.getParameter("type");
        String session = req.getParameter("session");
        String anneeAcademique = req.getParameter("annee");

        try {
            if ("csv".equals(type)) {
                exportNotesCSV(resp, session, anneeAcademique);
            } else if ("stats".equals(type)) {
                exportStatsCSV(resp, session, anneeAcademique);
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Type export inconnu");
            }
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erreur: " + e.getMessage());
        }
    }

    private void exportNotesCSV(HttpServletResponse resp, String session, String anneeAcademique) throws SQLException, IOException {
        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=export_notes.csv");

        PrintWriter writer = resp.getWriter();

        // CSV Header
        writer.println("MATRICULE,NOM,PRENOM,MATIERE,CODE,NOTE_CC,NOTE_EXAMEN,NOTE_FINALE,MENTION,ADMIS");

        // Get data
        List<Note> notes = noteDAO.findAll(10000, 0);
        List<Etudiant> etudiants = etudiantDAO.findAll(10000, 0);
        List<Matiere> matieres = matiereDAO.findAll(10000, 0);

        for (Note note : notes) {
            if ((session == null || session.equals(note.getSession())) &&
                    (anneeAcademique == null || anneeAcademique.equals(note.getAnneeAcademique()))) {

                Etudiant etudiant = etudiants.stream()
                        .filter(e -> e.getId().equals(note.getEtudiantId()))
                        .findFirst()
                        .orElse(null);

                Matiere matiere = matieres.stream()
                        .filter(m -> m.getId().equals(note.getMatiereId()))
                        .findFirst()
                        .orElse(null);

                if (etudiant != null && matiere != null) {
                    String mention = noteService.getMention(note.getNoteFinale());
                    boolean admis = noteService.isAdmis(note.getNoteFinale());

                    writer.print(escapeCsv(etudiant.getMatricule()) + ",");
                    writer.print(escapeCsv(etudiant.getNom()) + ",");
                    writer.print(escapeCsv(etudiant.getPrenom()) + ",");
                    writer.print(escapeCsv(matiere.getIntitule()) + ",");
                    writer.print(escapeCsv(matiere.getCode()) + ",");
                    writer.print((note.getNoteCC() != null ? note.getNoteCC() : "-") + ",");
                    writer.print((note.getNoteExam() != null ? note.getNoteExam() : "-") + ",");
                    writer.print((note.getNoteFinale() != null ? note.getNoteFinale() : "-") + ",");
                    writer.print(escapeCsv(mention) + ",");
                    writer.println(admis ? "OUI" : "NON");
                }
            }
        }

        writer.flush();
        writer.close();
    }

    private void exportStatsCSV(HttpServletResponse resp, String session, String anneeAcademique) throws SQLException, IOException {
        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=export_stats.csv");

        PrintWriter writer = resp.getWriter();

        // CSV Header
        writer.println("MATRICULE,NOM,PRENOM,FILIERE,MOYENNE_GENERALE,TAUX_REUSSITE,STATUT");

        // Get data
        List<Etudiant> etudiants = etudiantDAO.findAll(10000, 0);

        for (Etudiant etudiant : etudiants) {
            var moyenne = noteService.calcMoyennePonderee(etudiant.getId(),
                    session != null ? session : "JUIN",
                    anneeAcademique != null ? anneeAcademique : "2024/2025");

            var tauxReussite = noteService.calcTauxReussite(etudiant.getId(),
                    session != null ? session : "JUIN",
                    anneeAcademique != null ? anneeAcademique : "2024/2025");

            String statut = noteService.isAdmis(moyenne) ? "ADMIS" : "NON ADMIS";

            writer.print(escapeCsv(etudiant.getMatricule()) + ",");
            writer.print(escapeCsv(etudiant.getNom()) + ",");
            writer.print(escapeCsv(etudiant.getPrenom()) + ",");
            writer.print(escapeCsv(etudiant.getFiliere()) + ",");
            writer.print(moyenne + ",");
            writer.print(tauxReussite + ",");
            writer.println(escapeCsv(statut));
        }

        writer.flush();
        writer.close();
    }

    private String escapeCsv(String value) {
        if (value == null) {
            return "";
        }
        if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }
}
