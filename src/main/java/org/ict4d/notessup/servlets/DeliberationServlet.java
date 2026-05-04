package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.ict4d.notessup.models.Deliberation;
import org.ict4d.notessup.models.Etudiant;
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
            if ("published".equals(action)) {
                // Show only published deliberations
                int pageNum = page != null ? Integer.parseInt(page) : 1;
                int offset = (pageNum - 1) * PAGE_SIZE;

                List<Deliberation> deliberations = deliberationDAO.findPublished(PAGE_SIZE, offset);
                req.setAttribute("deliberations", deliberations);
                req.setAttribute("currentPage", pageNum);
                req.setAttribute("pageSize", PAGE_SIZE);
                req.getRequestDispatcher("/WEB-INF/views/deliberations/published.jsp").forward(req, resp);

            } else {
                // List all deliberations with pagination
                int pageNum = page != null ? Integer.parseInt(page) : 1;
                int offset = (pageNum - 1) * PAGE_SIZE;

                List<Deliberation> deliberations;
                if (filiere != null && !filiere.isEmpty()) {
                    deliberations = deliberationDAO.findByFiliere(filiere, PAGE_SIZE, offset);
                } else {
                    deliberations = deliberationDAO.findAll(PAGE_SIZE, offset);
                }

                req.setAttribute("deliberations", deliberations);
                req.setAttribute("currentPage", pageNum);
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
                            smsService.sendSMSNotification(etudiant.getId(), deliberation.getSession(), deliberation.getAnneeAcademique());
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
}
