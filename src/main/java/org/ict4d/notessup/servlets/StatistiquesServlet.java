package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.ict4d.notessup.dao.EtudiantDAO;
import org.ict4d.notessup.dao.NoteDAO;
import org.ict4d.notessup.dao.MatiereDAO;
import org.ict4d.notessup.models.Note;
import org.ict4d.notessup.models.Etudiant;
import org.ict4d.notessup.models.Matiere;
import org.ict4d.notessup.models.User;
import org.ict4d.notessup.services.NoteService;
import org.ict4d.notessup.utils.Constants;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class StatistiquesServlet extends HttpServlet {
    private final EtudiantDAO etudiantDAO = new EtudiantDAO();
    private final NoteDAO noteDAO = new NoteDAO();
    private final MatiereDAO matiereDAO = new MatiereDAO();
    private final NoteService noteService = new NoteService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String role = (String) session.getAttribute(Constants.SESSION_ROLE);
        User user = (User) session.getAttribute(Constants.SESSION_USER);

        String sessionParam = req.getParameter("session");
        String anneeAcademique = req.getParameter("annee");
        String filiere = req.getParameter("filiere");

        try {
            if (Constants.ROLE_ETUDIANT.equals(role) && user.getEtudiantId() != null) {
                handleEtudiantStats(req, resp, user.getEtudiantId(), sessionParam, anneeAcademique);
                return;
            }

            String forcedFiliere = filiere;
            req.setAttribute("filieres", Constants.FILIERES);

            // Get all notes for the session
            List<Note> allNotes = noteDAO.findAll(1000, 0);
            String finalForcedFiliere1 = forcedFiliere;
            List<Note> sessionNotes = allNotes.stream()
                    .filter(n -> (sessionParam == null || sessionParam.equals(n.getSession())) &&
                            (anneeAcademique == null || anneeAcademique.equals(n.getAnneeAcademique())))
                    .filter(n -> {
                        try {
                            if (finalForcedFiliere1 == null) return true;
                            Etudiant e = etudiantDAO.findById(n.getEtudiantId());
                            return e != null && finalForcedFiliere1.equals(e.getFiliere());
                        } catch (Exception e) { return false; }
                    })
                    .collect(Collectors.toList());

            // Calculate global statistics
            BigDecimal avgNote = BigDecimal.ZERO;
            BigDecimal maxNote = BigDecimal.ZERO;
            BigDecimal minNote = new BigDecimal("20");
            int admisCount = 0;
            int nonAdmisCount = 0;
            int notesWithValue = 0;

            if (!sessionNotes.isEmpty()) {
                BigDecimal totalNotes = BigDecimal.ZERO;
                for (Note note : sessionNotes) {
                    if (note.getNoteFinale() != null) {
                        notesWithValue++;
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
                if (notesWithValue > 0) {
                    avgNote = totalNotes.divide(new BigDecimal(notesWithValue), 2, RoundingMode.HALF_UP);
                }
            }

            // Calculate per-student statistics and rankings
            List<Etudiant> etudiants = etudiantDAO.findAll(1000, 0);
            Map<Long, BigDecimal> etudiantMoyennes = new HashMap<>();
            Map<Long, Integer> etudiantAdmis = new HashMap<>();

            for (Etudiant etudiant : etudiants) {
                if (forcedFiliere != null && !forcedFiliere.isEmpty() && !forcedFiliere.equals(etudiant.getFiliere())) {
                    continue;
                }

                BigDecimal moyenne = noteService.calcMoyennePonderee(etudiant.getId(),
                        sessionParam != null ? sessionParam : "NORMALE",
                        anneeAcademique != null ? anneeAcademique : "2025-2026");
                BigDecimal safeMoyenne = moyenne != null ? moyenne : BigDecimal.ZERO;
                etudiantMoyennes.put(etudiant.getId(), safeMoyenne);
                etudiantAdmis.put(etudiant.getId(), noteService.isAdmis(safeMoyenne) ? 1 : 0);
            }

            // Sort students by average (ranking) — complete list with rank number
            List<Map.Entry<Long, BigDecimal>> allStudentsRanked = etudiantMoyennes.entrySet()
                    .stream()
                    .filter(e -> e.getValue() != null && e.getValue().compareTo(BigDecimal.ZERO) > 0)
                    .sorted(Map.Entry.<Long, BigDecimal>comparingByValue().reversed())
                    .collect(Collectors.toList());

            // Build ranking map with rank number and student info
            Map<Long, Map<String, Object>> rankingData = new java.util.LinkedHashMap<>();
            int rank = 1;
            for (Map.Entry<Long, BigDecimal> entry : allStudentsRanked) {
                Map<String, Object> rankInfo = new java.util.HashMap<>();
                rankInfo.put("rank", rank);
                rankInfo.put("moyenne", entry.getValue());
                rankInfo.put("mention", noteService.getMention(entry.getValue()));
                rankInfo.put("admis", noteService.isAdmis(entry.getValue()));
                rankingData.put(entry.getKey(), rankInfo);
                rank++;
            }

            // Keep top 10 for dashboard widget
            List<Map.Entry<Long, BigDecimal>> topStudents = allStudentsRanked.stream()
                    .limit(10)
                    .collect(Collectors.toList());

            // Calculate mention distribution
            int tresBienCount = 0, bienCount = 0, assezBienCount = 0, passableCount = 0, ajourneCount = 0;
            int totalStudentsWithMoyenne = 0;

            for (BigDecimal moy : etudiantMoyennes.values()) {
                if (moy != null && moy.compareTo(BigDecimal.ZERO) > 0) {
                    totalStudentsWithMoyenne++;
                    if (moy.compareTo(new BigDecimal("16")) >= 0) {
                        tresBienCount++;
                    } else if (moy.compareTo(new BigDecimal("14")) >= 0) {
                        bienCount++;
                    } else if (moy.compareTo(new BigDecimal("12")) >= 0) {
                        assezBienCount++;
                    } else if (moy.compareTo(new BigDecimal("10")) >= 0) {
                        passableCount++;
                    } else {
                        ajourneCount++;
                    }
                }
            }

            // Calculate percentages
            double tresBienPct = totalStudentsWithMoyenne > 0 ? (double) tresBienCount / totalStudentsWithMoyenne * 100 : 0;
            double bienPct = totalStudentsWithMoyenne > 0 ? (double) bienCount / totalStudentsWithMoyenne * 100 : 0;
            double assezBienPct = totalStudentsWithMoyenne > 0 ? (double) assezBienCount / totalStudentsWithMoyenne * 100 : 0;
            double passablePct = totalStudentsWithMoyenne > 0 ? (double) passableCount / totalStudentsWithMoyenne * 100 : 0;
            double ajournePct = totalStudentsWithMoyenne > 0 ? (double) ajourneCount / totalStudentsWithMoyenne * 100 : 0;

            // Calculate pass rate and stats per matiere
            Map<Long, Double> matierePassRates = new HashMap<>();
            Map<Long, Map<String, BigDecimal>> matiereStats = new HashMap<>();
            java.util.Map<Long, Matiere> matieresMap = new java.util.HashMap<>();
            int totalMatieres = 0;
            try {
                var matieres = (forcedFiliere != null && !forcedFiliere.isEmpty()) ? 
                               matiereDAO.findByFiliere(forcedFiliere, 1000, 0) : 
                               matiereDAO.findAll(1000, 0);
                totalMatieres = matieres.size();
                for (var matiere : matieres) {
                    matieresMap.put(matiere.getId(), matiere);
                    List<Note> matiereNotes = noteDAO.findByMatiere(matiere.getId(), 1000, 0);
                    
                    if (!matiereNotes.isEmpty()) {
                        long passCount = 0;
                        BigDecimal sum = BigDecimal.ZERO;
                        BigDecimal max = BigDecimal.ZERO;
                        BigDecimal min = new BigDecimal("20");
                        int notesCount = 0;
                        
                        for (Note n : matiereNotes) {
                            if (n.getNoteFinale() != null) {
                                if (noteService.isAdmis(n.getNoteFinale())) passCount++;
                                notesCount++;
                                sum = sum.add(n.getNoteFinale());
                                if (n.getNoteFinale().compareTo(max) > 0) max = n.getNoteFinale();
                                if (n.getNoteFinale().compareTo(min) < 0) min = n.getNoteFinale();
                            }
                        }
                        
                        if (notesCount > 0) {
                            double passRate = (double) passCount / notesCount * 100;
                            matierePassRates.put(matiere.getId(), passRate);
                            
                            Map<String, BigDecimal> stats = new HashMap<>();
                            stats.put("max", max);
                            stats.put("min", min);
                            stats.put("moy", sum.divide(new BigDecimal(notesCount), 2, RoundingMode.HALF_UP));
                            matiereStats.put(matiere.getId(), stats);
                        }
                    }
                }
            } catch (SQLException e) {
                // Continue without matiere stats
            }

            // Calculate global statistics for JSP
            int totalEtudiants = etudiantMoyennes.size();
            BigDecimal moyenneGenerale = BigDecimal.ZERO;
            if (totalStudentsWithMoyenne > 0) {
                BigDecimal sumMoy = BigDecimal.ZERO;
                for (BigDecimal moy : etudiantMoyennes.values()) {
                    if (moy != null) {
                        sumMoy = sumMoy.add(moy);
                    }
                }
                moyenneGenerale = sumMoy.divide(new BigDecimal(totalStudentsWithMoyenne), 2, RoundingMode.HALF_UP);
            }

            int studentsAdmis = (int) etudiantAdmis.values().stream().filter(v -> v == 1).count();
            int pourcentageAdmis = totalEtudiants > 0 ? (int) Math.round((double) studentsAdmis / totalEtudiants * 100) : 0;

            // Prepare attributes for JSP
            req.setAttribute("avgNote", avgNote);
            req.setAttribute("maxNote", maxNote);
            req.setAttribute("minNote", minNote);
            req.setAttribute("admisCount", admisCount);
            req.setAttribute("nonAdmisCount", nonAdmisCount);
            req.setAttribute("totalNotes", sessionNotes.size());
            req.setAttribute("topStudents", topStudents);
            req.setAttribute("rankingData", rankingData);  // complete ranking with rank numbers
            req.setAttribute("allStudentsRanked", allStudentsRanked);
            req.setAttribute("etudiantMoyennes", etudiantMoyennes);
            req.setAttribute("etudiantAdmis", etudiantAdmis);
            
            java.util.Map<Long, Etudiant> etudiantsMap = new java.util.HashMap<>();
            for (Etudiant e : etudiants) etudiantsMap.put(e.getId(), e);
            req.setAttribute("etudiantsMap", etudiantsMap);
            
            req.setAttribute("matierePassRates", matierePassRates);
            req.setAttribute("matiereStats", matiereStats);
            req.setAttribute("matieresMap", matieresMap);
            req.setAttribute("session", sessionParam != null ? sessionParam : "NORMALE");
            req.setAttribute("anneeAcademique", anneeAcademique != null ? anneeAcademique : "2025-2026");
            req.setAttribute("filiere", forcedFiliere);

            // Additional attributes expected by JSP
            req.setAttribute("totalEtudiants", totalEtudiants);
            req.setAttribute("moyenneGenerale", moyenneGenerale);
            req.setAttribute("pourcentageAdmis", pourcentageAdmis);
            req.setAttribute("totalMatieres", totalMatieres);
            req.setAttribute("selectedFiliere", forcedFiliere);

            // Mention distribution
            req.setAttribute("tresBienCount", tresBienCount);
            req.setAttribute("bienCount", bienCount);
            req.setAttribute("assezBienCount", assezBienCount);
            req.setAttribute("passableCount", passableCount);
            req.setAttribute("ajourneCount", ajourneCount);
            req.setAttribute("tresBienPct", tresBienPct);
            req.setAttribute("bienPct", bienPct);
            req.setAttribute("assezBienPct", assezBienPct);
            req.setAttribute("passablePct", passablePct);
            req.setAttribute("ajournePct", ajournePct);

            req.getRequestDispatcher("/WEB-INF/views/statistiques/index.jsp").forward(req, resp);

        } catch (SQLException e) {
            req.setAttribute("error", "Erreur: " + e.getMessage());
            try {
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            } catch (ServletException se) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        }
    }

    private void handleEtudiantStats(HttpServletRequest req, HttpServletResponse resp, Long etudiantId, String sessionParam, String anneeAcademique) throws ServletException, IOException, SQLException {
        Etudiant etudiant = etudiantDAO.findById(etudiantId);
        String s = sessionParam != null ? sessionParam : "NORMALE";
        String a = anneeAcademique != null ? anneeAcademique : "2025-2026";
        
        List<Note> mesNotes = noteDAO.findByEtudiantSessionAnnee(etudiantId, s, a);
        
        BigDecimal maMoyenne = noteService.calcMoyennePonderee(etudiantId, s, a);
        String maMention = maMoyenne != null ? noteService.getMention(maMoyenne) : null;
        
        int matieresValidees = 0;
        int credits = 0;
        
        // Subject stats
        Map<Long, Map<String, BigDecimal>> subjectStats = new HashMap<>();
        Map<Long, Matiere> matieresMap = new HashMap<>();
        
        for (Note n : mesNotes) {
            Matiere m = matiereDAO.findById(n.getMatiereId());
            matieresMap.put(m.getId(), m);
            if (n.getNoteFinale() != null && n.getNoteFinale().compareTo(new BigDecimal("10")) >= 0) {
                matieresValidees++;
                credits += m.getCoefficient();
            }
            
            // Calculate class stats for this subject
            List<Note> allSubjectNotes = noteDAO.findByMatiere(m.getId(), 1000, 0);
            BigDecimal sum = BigDecimal.ZERO;
            BigDecimal max = BigDecimal.ZERO;
            BigDecimal min = new BigDecimal("20");
            int count = 0;
            for (Note sn : allSubjectNotes) {
                if (sn.getNoteFinale() != null) {
                    count++;
                    sum = sum.add(sn.getNoteFinale());
                    if (sn.getNoteFinale().compareTo(max) > 0) max = sn.getNoteFinale();
                    if (sn.getNoteFinale().compareTo(min) < 0) min = sn.getNoteFinale();
                }
            }
            Map<String, BigDecimal> stats = new HashMap<>();
            stats.put("max", max);
            stats.put("min", count > 0 ? min : BigDecimal.ZERO);
            stats.put("moy", count > 0 ? sum.divide(new BigDecimal(count), 2, RoundingMode.HALF_UP) : BigDecimal.ZERO);
            subjectStats.put(m.getId(), stats);
        }
        
        req.setAttribute("etudiant", etudiant);
        req.setAttribute("mesNotes", mesNotes);
        req.setAttribute("matieresMap", matieresMap);
        req.setAttribute("subjectStats", subjectStats);
        req.setAttribute("maMoyenne", maMoyenne);
        req.setAttribute("maMention", maMention);
        req.setAttribute("matieresValidees", matieresValidees);
        req.setAttribute("totalMatieres", mesNotes.size());
        req.setAttribute("creditsTotal", credits);
        req.setAttribute("session", s);
        req.setAttribute("anneeAcademique", a);
        
        req.getRequestDispatcher("/WEB-INF/views/statistiques/etudiant.jsp").forward(req, resp);
    }
}
