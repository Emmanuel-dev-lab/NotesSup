package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.ict4d.notessup.models.User;
import org.ict4d.notessup.utils.Constants;
import org.ict4d.notessup.dao.EtudiantDAO;
import org.ict4d.notessup.dao.NoteDAO;
import org.ict4d.notessup.dao.MatiereDAO;
import java.io.IOException;
import java.sql.SQLException;

public class DashboardServlet extends HttpServlet {
    private final EtudiantDAO etudiantDAO = new EtudiantDAO();
    private final NoteDAO noteDAO = new NoteDAO();
    private final MatiereDAO matiereDAO = new MatiereDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute(Constants.SESSION_USER) == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute(Constants.SESSION_USER);
        String role = (String) session.getAttribute(Constants.SESSION_ROLE);

        try {
            // Prepare dashboard data based on role
            if (Constants.ROLE_CHEF.equals(role)) {
                // Chef department - show statistics
                int totalEtudiants = etudiantDAO.count();
                int totalMatieres = matiereDAO.count();
                int totalNotes = noteDAO.count();

                req.setAttribute("totalEtudiants", totalEtudiants);
                req.setAttribute("totalMatieres", totalMatieres);
                req.setAttribute("totalNotes", totalNotes);
                req.setAttribute("filiereStats", noteDAO.getStatsPerFiliere("Normale", "2025-2026"));
                req.setAttribute("userName", user.getNom());
                req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);

            } else if (Constants.ROLE_ENSEIGNANT.equals(role)) {
                // Teacher - show classes and notes
                int totalMatieres = matiereDAO.findByEnseignant(user.getNom()).size();
                int totalNotes = noteDAO.countByEnseignant(user.getNom());
                int totalEtudiants = 0;
                if (user.getFiliere() != null) {
                    totalEtudiants = etudiantDAO.countByFiliere(user.getFiliere());
                }
                
                req.setAttribute("mesMatieres", totalMatieres);
                req.setAttribute("notesASaisir", totalNotes);
                req.setAttribute("mesEtudiants", totalEtudiants);
                req.setAttribute("userName", user.getNom());
                req.setAttribute("filiere", user.getFiliere());
                req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);

            } else if (Constants.ROLE_ETUDIANT.equals(role)) {
                // Student - show personal info
                if (user.getEtudiantId() != null) {
                    var etudiant = etudiantDAO.findById(user.getEtudiantId());
                    req.setAttribute("etudiant", etudiant);
                }
                req.setAttribute("userName", user.getNom());
                req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Erreur lors du chargement du tableau de bord: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
        }
    }
}
