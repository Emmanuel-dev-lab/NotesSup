package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.ict4d.notessup.dao.DeliberationDAO;
import org.ict4d.notessup.services.PDFService;
import com.itextpdf.text.DocumentException;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/bulletin")
public class BulletinServlet extends HttpServlet {
    private final PDFService pdfService = new PDFService();
    private final DeliberationDAO deliberationDAO = new DeliberationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String etudiantId = req.getParameter("etudiant");
        String session = req.getParameter("session");
        String anneeAcademique = req.getParameter("annee");
        String format = req.getParameter("format");

        try {
            // Check if deliberation is published
            var deliberation = deliberationDAO.findAll(1, 0).stream()
                    .filter(d -> session.equals(d.getSession()) && anneeAcademique.equals(d.getAnneeAcademique()))
                    .findFirst();

            if (deliberation.isEmpty() || !deliberation.get().getPubliee()) {
                req.setAttribute("error", "Les resultats de cette session ne sont pas encore publies");
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
                return;
            }

            if ("pdf".equals(format)) {
                // Generate and download PDF bulletin
                byte[] pdfBytes = pdfService.generateBulletinPDF(Long.parseLong(etudiantId), session, anneeAcademique);

                resp.setContentType("application/pdf");
                resp.setHeader("Content-Disposition", "attachment; filename=bulletin_" + etudiantId + "_" + session + ".pdf");
                resp.setContentLength(pdfBytes.length);

                resp.getOutputStream().write(pdfBytes);
                resp.getOutputStream().flush();

            } else {
                // Display bulletin in HTML
                req.setAttribute("etudiantId", etudiantId);
                req.setAttribute("session", session);
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
