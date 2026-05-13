package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.ict4d.notessup.models.Deliberation;
import org.ict4d.notessup.models.DeliberationDTO;
import org.ict4d.notessup.models.Etudiant;
import org.ict4d.notessup.models.Note;
import org.ict4d.notessup.dao.DeliberationDAO;
import org.ict4d.notessup.dao.EtudiantDAO;
import org.ict4d.notessup.dao.NoteDAO;
import org.ict4d.notessup.services.NoteService;
import org.ict4d.notessup.services.SMSService;
import org.ict4d.notessup.utils.Constants;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

public class DeliberationServlet extends HttpServlet {
    private final DeliberationDAO deliberationDAO = new DeliberationDAO();
    private final EtudiantDAO etudiantDAO = new EtudiantDAO();
    private final NoteDAO noteDAO = new NoteDAO();
    private final NoteService noteService = new NoteService();
    private final SMSService smsService = new SMSService();
    private static final int PAGE_SIZE = Constants.DEFAULT_PAGE_SIZE;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String role = (String) session.getAttribute(Constants.SESSION_ROLE);

        // CHEF_DEPT and ENSEIGNANT can view deliberations (see PV)
        if (!Constants.ROLE_CHEF.equals(role) && !Constants.ROLE_ENSEIGNANT.equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
            return;
        }

        String action = req.getParameter("action");
        String page = req.getParameter("page");
        String filiere = req.getParameter("filiere");

        try {
            if ("add".equals(action)) {
                // Show creation form (CHEF only)
                if (!Constants.ROLE_CHEF.equals(role)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                    return;
                }
                req.setAttribute("filieres", Constants.FILIERES);
                req.getRequestDispatcher("/WEB-INF/views/deliberations/form.jsp").forward(req, resp);

            } else if ("pv".equals(action) || "pdf".equals(action)) {
                // Show PV (Procès-Verbal)
                String id = req.getParameter("id");
                Deliberation delib = deliberationDAO.findById(Long.parseLong(id));
                if (delib == null) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                
                // Fetch all notes for this context
                List<Note> notes = noteDAO.findByFiliereSessionAnnee(delib.getFiliere(), delib.getSession(), delib.getAnneeAcademique());
                noteService.populateNoteRelations(notes);
                
                // Group results by student
                java.util.Map<Long, java.util.List<Note>> notesByStudent = notes.stream()
                        .collect(java.util.stream.Collectors.groupingBy(Note::getEtudiantId));
                
                java.util.List<java.util.Map<String, Object>> results = new java.util.ArrayList<>();
                for (java.util.Map.Entry<Long, java.util.List<Note>> entry : notesByStudent.entrySet()) {
                    java.util.Map<String, Object> result = new java.util.HashMap<>();
                    Etudiant e = entry.getValue().get(0).getEtudiant();
                    result.put("etudiant", e);
                    java.math.BigDecimal moy = noteService.calcMoyennePonderee(e.getId(), delib.getSession(), delib.getAnneeAcademique());
                    result.put("moyenne", moy);
                    result.put("admis", noteService.isAdmis(moy));
                    result.put("mention", noteService.getMention(moy));
                    results.add(result);
                }
                
                req.setAttribute("deliberation", delib);
                req.setAttribute("results", results);
                
                if ("pdf".equals(action)) {
                   // For now, redirect to PV as a placeholder or show a message
                   req.setAttribute("success", "Génération PDF en cours d'implémentation...");
                }
                
                req.getRequestDispatcher("/WEB-INF/views/deliberations/pv.jsp").forward(req, resp);

            } else if ("sms".equals(action)) {
                if (!Constants.ROLE_CHEF.equals(role)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                    return;
                }
                String id = req.getParameter("id");
                Deliberation deliberation = deliberationDAO.findById(Long.parseLong(id));
                if (deliberation != null && deliberation.getPubliee()) {
                    try {
                        List<Etudiant> etudiants = etudiantDAO.findByFiliere(deliberation.getFiliere(), 1000, 0);
                        for (Etudiant etudiant : etudiants) {
                            java.math.BigDecimal moy = noteService.calcMoyennePonderee(etudiant.getId(), deliberation.getSession(), deliberation.getAnneeAcademique());
                            if (moy != null) {
                                String mention = noteService.getMention(moy);
                                smsService.sendSMSNotification(etudiant.getId(), moy, mention);
                            }
                        }
                        req.setAttribute("success", "SMS de notification envoyés avec succès");
                    } catch (Exception e) {
                        req.setAttribute("error", "Erreur lors de l'envoi des SMS: " + e.getMessage());
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/deliberations");

            } else if ("published".equals(action)) {
                // Show only published deliberations
                int pageNum = page != null ? Integer.parseInt(page) : 1;
                int offset = (pageNum - 1) * PAGE_SIZE;

                List<Deliberation> deliberations = deliberationDAO.findPublished(PAGE_SIZE, offset);
                int totalCount = deliberationDAO.countPublished();
                int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);

                List<DeliberationDTO> deliberationDTOs = enrichDeliberations(deliberations);
                req.setAttribute("deliberations", deliberationDTOs);
                req.setAttribute("currentPage", pageNum);
                req.setAttribute("totalPages", totalPages);
                req.setAttribute("pageSize", PAGE_SIZE);
                req.getRequestDispatcher("/WEB-INF/views/deliberations/published.jsp").forward(req, resp);

            } else {
                // List all deliberations with pagination
                int pageNum = page != null ? Integer.parseInt(page) : 1;
                int offset = (pageNum - 1) * PAGE_SIZE;

                List<Deliberation> deliberations;
                int totalCount = 0;
                if (filiere != null && !filiere.isEmpty()) {
                    deliberations = deliberationDAO.findByFiliere(filiere, PAGE_SIZE, offset);
                    totalCount = deliberationDAO.countByFiliere(filiere);
                } else {
                    deliberations = deliberationDAO.findAll(PAGE_SIZE, offset);
                    totalCount = deliberationDAO.count();
                }
                
                int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
                
                List<DeliberationDTO> deliberationDTOs = enrichDeliberations(deliberations);

                req.setAttribute("deliberations", deliberationDTOs);
                req.setAttribute("currentPage", pageNum);
                req.setAttribute("totalPages", totalPages);
                req.setAttribute("pageSize", PAGE_SIZE);
                req.setAttribute("filiere", filiere);
                req.getRequestDispatcher("/WEB-INF/views/deliberations/list.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Erreur: " + e.getMessage());
            try {
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            } catch (ServletException se) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String role = (String) session.getAttribute(Constants.SESSION_ROLE);

        try {
            String action = req.getParameter("action");

            if ("publish".equals(action)) {
                // Publish deliberation (CHEF_DEPT only)
                if (!Constants.ROLE_CHEF.equals(role)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                    return;
                }
                String id = req.getParameter("id");
                Deliberation deliberation = deliberationDAO.findById(Long.parseLong(id));

                if (deliberation != null && !deliberation.getPubliee()) {
                    deliberation.setPubliee(true);
                    deliberation.setDatePublication(LocalDate.now());
                    deliberation.setPubliePar(req.getUserPrincipal() != null ? req.getUserPrincipal().getName() : "system");

                    deliberationDAO.update(deliberation);

                    // Send SMS notifications to all students
                    try {
                        List<Etudiant> etudiants = etudiantDAO.findByFiliere(deliberation.getFiliere(), 1000, 0);
                        for (Etudiant etudiant : etudiants) {
                            java.math.BigDecimal moy = noteService.calcMoyennePonderee(etudiant.getId(), deliberation.getSession(), deliberation.getAnneeAcademique());
                            if (moy != null) {
                                String mention = noteService.getMention(moy);
                                smsService.sendSMSNotification(etudiant.getId(), moy, mention);
                            }
                        }
                    } catch (Exception e) {
                        // SMS errors should not stop the publication
                        System.err.println("Erreur lors de l'envoi des SMS: " + e.getMessage());
                    }

                    req.setAttribute("success", "Deliberation publiee avec SMS notifies");
                }
                resp.sendRedirect(req.getContextPath() + "/deliberations");

            } else {
                // Create new deliberation (CHEF_DEPT only)
                if (!Constants.ROLE_CHEF.equals(role)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                    return;
                }
                Deliberation deliberation = new Deliberation();
                deliberation.setFiliere(req.getParameter("filiere"));
                deliberation.setSession(req.getParameter("session"));
                deliberation.setAnneeAcademique(req.getParameter("anneeAcademique"));
                deliberation.setPubliee(false);

                deliberationDAO.insert(deliberation);
                resp.sendRedirect(req.getContextPath() + "/deliberations");
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Erreur: " + e.getMessage());
            try {
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            } catch (ServletException se) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String role = (String) session.getAttribute(Constants.SESSION_ROLE);

        // Only CHEF_DEPT can modify/toggle deliberations
        if (!Constants.ROLE_CHEF.equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
            return;
        }

        try {
            String id = req.getParameter("id");
            Deliberation deliberation = deliberationDAO.findById(Long.parseLong(id));

            if (deliberation != null) {
                // Toggle publication status
                deliberation.setPubliee(!deliberation.getPubliee());
                if (deliberation.getPubliee()) {
                    deliberation.setDatePublication(LocalDate.now());
                    deliberation.setPubliePar(req.getUserPrincipal() != null ? req.getUserPrincipal().getName() : "system");
                }
                deliberationDAO.update(deliberation);
            }

            resp.sendRedirect(req.getContextPath() + "/deliberations");
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private List<DeliberationDTO> enrichDeliberations(List<Deliberation> deliberations) throws SQLException {
        List<DeliberationDTO> dtos = new java.util.ArrayList<>();
        for (Deliberation d : deliberations) {
            DeliberationDTO dto = new DeliberationDTO(d);
            
            // Mode optimisé : une seule requête pour toutes les notes de la session
            List<Note> sessionNotes = noteDAO.findByFiliereSessionAnnee(d.getFiliere(), d.getSession(), d.getAnneeAcademique());
            noteService.populateNoteRelations(sessionNotes);
            
            java.util.Map<Long, List<Note>> notesByStudent = sessionNotes.stream()
                .collect(java.util.stream.Collectors.groupingBy(Note::getEtudiantId));
            
            int admis = 0;
            java.math.BigDecimal totalMoy = java.math.BigDecimal.ZERO;
            
            for (List<Note> studentNotes : notesByStudent.values()) {
                java.math.BigDecimal moy = noteService.calcMoyennePonderee(studentNotes);
                if (noteService.isAdmis(moy)) {
                    admis++;
                }
                totalMoy = totalMoy.add(moy);
            }
            
            dto.setNbEtudiants(notesByStudent.size());
            dto.setNbAdmis(admis);
            if (!notesByStudent.isEmpty()) {
                dto.setMoyenne(totalMoy.divide(new java.math.BigDecimal(notesByStudent.size()), 2, java.math.RoundingMode.HALF_UP));
            } else {
                dto.setMoyenne(java.math.BigDecimal.ZERO);
            }
            
            dtos.add(dto);
        }
        return dtos;
    }
}
