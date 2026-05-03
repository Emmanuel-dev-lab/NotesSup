package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
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

@WebServlet("/dashboard")
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
                int totalEtudiants = (int) etudiantDAO.findAll(1000, 0).size();
                int totalMatieres = (int) matiereDAO.findAll(1000, 0).size();
                int totalNotes = (int) noteDAO.findAll(1000, 0).size();

                req.setAttribute("totalEtudiants", totalEtudiants);
                req.setAttribute("totalMatieres", totalMatieres);
                req.setAttribute("totalNotes", totalNotes);
                req.setAttribute("userName", user.getNom());
                req.getRequestDispatcher("/WEB-INF/views/dashboard-chef.jsp").forward(req, resp);

            } else if (Constants.ROLE_ENSEIGNANT.equals(role)) {
                // Teacher - show classes and notes
                String filiere = user.getFiliere();
                req.setAttribute("userName", user.getNom());
                req.setAttribute("filiere", filiere);
                req.getRequestDispatcher("/WEB-INF/views/dashboard-enseignant.jsp").forward(req, resp);

            } else if (Constants.ROLE_ETUDIANT.equals(role)) {
                // Student - show personal info
                if (user.getEtudiantId() != null) {
                    var etudiant = etudiantDAO.findById(user.getEtudiantId());
                    req.setAttribute("etudiant", etudiant);
                }
                req.setAttribute("userName", user.getNom());
                req.getRequestDispatcher("/WEB-INF/views/dashboard-etudiant.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Erreur lors du chargement du tableau de bord: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
        }
    }
}
