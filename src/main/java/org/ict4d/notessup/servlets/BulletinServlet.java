package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.ict4d.notessup.dao.DeliberationDAO;
import org.ict4d.notessup.dao.EtudiantDAO;
import org.ict4d.notessup.models.User;
import org.ict4d.notessup.models.Etudiant;
import org.ict4d.notessup.services.PDFService;
import org.ict4d.notessup.utils.Constants;
import com.itextpdf.text.DocumentException;
import java.io.IOException;
import java.sql.SQLException;

public class BulletinServlet extends HttpServlet {
    private final PDFService pdfService = new PDFService();
    private final DeliberationDAO deliberationDAO = new DeliberationDAO();
    private final EtudiantDAO etudiantDAO = new EtudiantDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String role = (String) session.getAttribute(Constants.SESSION_ROLE);
        User user = (User) session.getAttribute(Constants.SESSION_USER);

        String etudiantId = req.getParameter("etudiant");
        String sessionParam = req.getParameter("session");
        String anneeAcademique = req.getParameter("annee");
        String format = req.getParameter("format");

        try {
            // Verify access rights based on role
            if (Constants.ROLE_CHEF.equals(role)) {
                // CHEF can view all etudiants bulletins
            } else if (Constants.ROLE_ENSEIGNANT.equals(role)) {
                // ENSEIGNANT can view bulletins for etudiants in their filiere
                Etudiant etudiant = etudiantDAO.findById(Long.parseLong(etudiantId));
                if (etudiant == null || !etudiant.getFiliere().equals(user.getFiliere())) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                    return;
                }
            } else if (Constants.ROLE_ETUDIANT.equals(role)) {
                // ETUDIANT can only view their own bulletin
                if (!etudiantId.equals(user.getEtudiantId().toString())) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                    return;
                }
            } else {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                return;
            }

            // Check if deliberation is published for ETUDIANT
            var deliberation = deliberationDAO.findAll(1, 0).stream()
                    .filter(d -> sessionParam.equals(d.getSession()) && anneeAcademique.equals(d.getAnneeAcademique()))
                    .findFirst();

            if (deliberation.isEmpty() || !deliberation.get().getPubliee()) {
                // For ETUDIANT, return 403 if not published; for others, just show unavailable
                if (Constants.ROLE_ETUDIANT.equals(role)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bulletin not published");
                    return;
                } else {
                    req.setAttribute("error", "Les resultats de cette session ne sont pas encore publies");
                    req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
                    return;
                }
            }

            if ("pdf".equals(format)) {
                // Generate and download PDF bulletin
                byte[] pdfBytes = pdfService.generateBulletinPDF(Long.parseLong(etudiantId), sessionParam, anneeAcademique);

                resp.setContentType("application/pdf");
                resp.setHeader("Content-Disposition", "attachment; filename=bulletin_" + etudiantId + "_" + sessionParam + ".pdf");
                resp.setContentLength(pdfBytes.length);

                resp.getOutputStream().write(pdfBytes);
                resp.getOutputStream().flush();

            } else {
                // Display bulletin in HTML
                req.setAttribute("etudiantId", etudiantId);
                req.setAttribute("session", sessionParam);
                req.setAttribute("anneeAcademique", anneeAcademique);
                req.getRequestDispatcher("/WEB-INF/views/bulletin.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Erreur base de donnees: " + e.getMessage());
            try {
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            } catch (ServletException se) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        } catch (DocumentException e) {
            req.setAttribute("error", "Erreur lors de la generation du PDF: " + e.getMessage());
            try {
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            } catch (ServletException se) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        }
    }
}
