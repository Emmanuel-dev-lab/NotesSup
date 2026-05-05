package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.ict4d.notessup.dao.DeliberationDAO;
import org.ict4d.notessup.dao.EtudiantDAO;
import org.ict4d.notessup.dao.NoteDAO;
import org.ict4d.notessup.models.User;
import org.ict4d.notessup.models.Etudiant;
import org.ict4d.notessup.models.Note;
import org.ict4d.notessup.models.Deliberation;
import org.ict4d.notessup.services.PDFService;
import org.ict4d.notessup.services.NoteService;
import org.ict4d.notessup.utils.Constants;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

public class BulletinServlet extends HttpServlet {
    private final PDFService pdfService = new PDFService();
    private final DeliberationDAO deliberationDAO = new DeliberationDAO();
    private final EtudiantDAO etudiantDAO = new EtudiantDAO();
    private final NoteDAO noteDAO = new NoteDAO();
    private final NoteService noteService = new NoteService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute(Constants.SESSION_USER) == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        String role = (String) session.getAttribute(Constants.SESSION_ROLE);
        User user = (User) session.getAttribute(Constants.SESSION_USER);

        String etudiantId = req.getParameter("etudiantId") != null ? req.getParameter("etudiantId") : req.getParameter("etudiant");
        String sessionParam = req.getParameter("session");
        String anneeAcademique = req.getParameter("annee");
        String format = req.getParameter("format");

        try {
            // When accessed without parameters (e.g. from sidebar), show the select form
            if (etudiantId == null || etudiantId.trim().isEmpty() || sessionParam == null || anneeAcademique == null) {
                if (Constants.ROLE_CHEF.equals(role) || Constants.ROLE_ENSEIGNANT.equals(role)) {
                    req.setAttribute("etudiants", etudiantDAO.findAll(1000, 0));
                } else if (Constants.ROLE_ETUDIANT.equals(role)) {
                    req.setAttribute("etudiants", List.of(etudiantDAO.findById(user.getEtudiantId())));
                    req.setAttribute("selectedEtudiantId", user.getEtudiantId().toString());
                }
                req.getRequestDispatcher("/WEB-INF/views/bulletins/index.jsp").forward(req, resp);
                return;
            }

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
            Optional<Deliberation> deliberation = deliberationDAO.findAll(100, 0).stream()
                    .filter(d -> sessionParam.equals(d.getSession()) && anneeAcademique.equals(d.getAnneeAcademique()))
                    .findFirst();

            if (deliberation.isEmpty() || !deliberation.get().getPubliee()) {
                if (Constants.ROLE_ETUDIANT.equals(role)) {
                    req.setAttribute("locked", true);
                    req.getRequestDispatcher("/WEB-INF/views/bulletins/index.jsp").forward(req, resp);
                    return;
                } else {
                    req.setAttribute("error", "Les résultats de cette session ne sont pas encore publiés ou la délibération n'existe pas.");
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
                // Prepare HTML view data
                Etudiant etudiant = etudiantDAO.findById(Long.parseLong(etudiantId));
                List<Note> etudiantNotes = noteDAO.findByEtudiantSessionAnnee(etudiant.getId(), sessionParam, anneeAcademique);
                
                noteService.populateNoteRelations(etudiantNotes);

                BigDecimal moyenneGenerale = noteService.calcMoyennePonderee(etudiantNotes);
                BigDecimal totalPoints = BigDecimal.ZERO;
                BigDecimal totalCoeff = BigDecimal.ZERO;
                
                for (Note n : etudiantNotes) {
                    if (n.getNoteFinale() != null && n.getMatiere() != null) {
                        BigDecimal coeff = new BigDecimal(n.getMatiere().getCoefficient());
                        totalPoints = totalPoints.add(n.getNoteFinale().multiply(coeff));
                        totalCoeff = totalCoeff.add(coeff);
                    }
                }

                req.setAttribute("etudiants", etudiantDAO.findAll(1000, 0));
                req.setAttribute("selectedEtudiantId", etudiantId);
                req.setAttribute("selectedSession", sessionParam);
                req.setAttribute("anneeAcademique", anneeAcademique);
                req.setAttribute("etudiant", etudiant);
                req.setAttribute("notes", etudiantNotes);
                req.setAttribute("totalCoefficients", totalCoeff);
                req.setAttribute("totalPoints", totalPoints);
                req.setAttribute("moyenneGenerale", moyenneGenerale);

                req.getRequestDispatcher("/WEB-INF/views/bulletins/index.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Erreur base de données: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Erreur lors de la génération du bulletin: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
        }
    }
}
