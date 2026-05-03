package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.ict4d.notessup.dao.EtudiantDAO;
import org.ict4d.notessup.dao.NoteDAO;
import org.ict4d.notessup.dao.MatiereDAO;
import org.ict4d.notessup.models.Note;
import org.ict4d.notessup.models.Etudiant;
import org.ict4d.notessup.services.NoteService;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/statistiques")
public class StatistiquesServlet extends HttpServlet {
    private final EtudiantDAO etudiantDAO = new EtudiantDAO();
    private final NoteDAO noteDAO = new NoteDAO();
    private final MatiereDAO matiereDAO = new MatiereDAO();
    private final NoteService noteService = new NoteService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String session = req.getParameter("session");
        String anneeAcademique = req.getParameter("annee");
        String filiere = req.getParameter("filiere");

        try {
            // Get all notes for the session
            List<Note> allNotes = noteDAO.findAll(1000, 0);
            List<Note> sessionNotes = allNotes.stream()
                    .filter(n -> (session == null || session.equals(n.getSession())) &&
                            (anneeAcademique == null || anneeAcademique.equals(n.getAnneeAcademique())))
                    .collect(Collectors.toList());

            // Calculate global statistics
            BigDecimal avgNote = BigDecimal.ZERO;
            BigDecimal maxNote = BigDecimal.ZERO;
            BigDecimal minNote = new BigDecimal("20");
            int admisCount = 0;
            int nonAdmisCount = 0;

            if (!sessionNotes.isEmpty()) {
                BigDecimal totalNotes = BigDecimal.ZERO;
                for (Note note : sessionNotes) {
                    if (note.getNoteFinale() != null) {
                        totalNotes = totalNotes.add(note.getNoteFinale());
                        if (note.getNoteFinale().compareTo(maxNote) > 0) {
                            maxNote = note.getNoteFinale();
                        }
                        if (note.getNoteFinale().compareTo(minNote) < 0) {
                            minNote = note.getNoteFinale();
                        }
                        if (noteService.isAdmis(note.getNoteFinale())) {
                            admisCount++;
                        } else {
                            nonAdmisCount++;
                        }
                    }
                }
                avgNote = totalNotes.divide(new BigDecimal(sessionNotes.size()), 2, BigDecimal.ROUND_HALF_UP);
            }

            // Calculate per-student statistics and rankings
            List<Etudiant> etudiants = etudiantDAO.findAll(1000, 0);
            Map<Long, BigDecimal> etudiantMoyennes = new HashMap<>();
            Map<Long, Integer> etudiantAdmis = new HashMap<>();

            for (Etudiant etudiant : etudiants) {
                if (filiere != null && !filiere.isEmpty() && !filiere.equals(etudiant.getFiliere())) {
                    continue;
                }

                BigDecimal moyenne = noteService.calcMoyennePonderee(etudiant.getId(),
                        session != null ? session : "JUIN",
                        anneeAcademique != null ? anneeAcademique : "2024/2025");
                etudiantMoyennes.put(etudiant.getId(), moyenne);
                etudiantAdmis.put(etudiant.getId(), noteService.isAdmis(moyenne) ? 1 : 0);
            }

            // Sort students by average (ranking)
            List<Map.Entry<Long, BigDecimal>> topStudents = etudiantMoyennes.entrySet()
                    .stream()
                    .sorted(Map.Entry.<Long, BigDecimal>comparingByValue().reversed())
                    .limit(10)
                    .collect(Collectors.toList());

            // Calculate pass rate per matiere
            Map<Long, Double> matierePassRates = new HashMap<>();
            try {
                var matieres = matiereDAO.findAll(1000, 0);
                for (var matiere : matieres) {
                    List<Note> matiereNotes = noteDAO.findByMatiere(matiere.getId(), 1000, 0);
                    if (!matiereNotes.isEmpty()) {
                        long passCount = matiereNotes.stream()
                                .filter(n -> n.getNoteFinale() != null && noteService.isAdmis(n.getNoteFinale()))
                                .count();
                        double passRate = (double) passCount / matiereNotes.size() * 100;
                        matierePassRates.put(matiere.getId(), passRate);
                    }
                }
            } catch (SQLException e) {
                // Continue without matiere stats
            }

            // Prepare attributes for JSP
            req.setAttribute("avgNote", avgNote);
            req.setAttribute("maxNote", maxNote);
            req.setAttribute("minNote", minNote);
            req.setAttribute("admisCount", admisCount);
            req.setAttribute("nonAdmisCount", nonAdmisCount);
            req.setAttribute("totalNotes", sessionNotes.size());
            req.setAttribute("topStudents", topStudents);
            req.setAttribute("etudiantMoyennes", etudiantMoyennes);
            req.setAttribute("etudiantAdmis", etudiantAdmis);
            req.setAttribute("matierePassRates", matierePassRates);
            req.setAttribute("session", session != null ? session : "JUIN");
            req.setAttribute("anneeAcademique", anneeAcademique != null ? anneeAcademique : "2024/2025");
            req.setAttribute("filiere", filiere);

            req.getRequestDispatcher("/WEB-INF/views/statistiques.jsp").forward(req, resp);

        } catch (SQLException e) {
            req.setAttribute("error", "Erreur: " + e.getMessage());
            try {
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            } catch (ServletException se) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        }
    }
}
