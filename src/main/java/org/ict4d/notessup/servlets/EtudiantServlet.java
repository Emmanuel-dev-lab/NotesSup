package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.ict4d.notessup.models.Etudiant;
import org.ict4d.notessup.dao.EtudiantDAO;
import org.ict4d.notessup.utils.Constants;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/etudiants")
public class EtudiantServlet extends HttpServlet {
    private final EtudiantDAO etudiantDAO = new EtudiantDAO();
    private static final int PAGE_SIZE = Constants.DEFAULT_PAGE_SIZE;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String page = req.getParameter("page");
        String search = req.getParameter("search");

        try {
            if ("add".equals(action)) {
                // Show add form
                req.getRequestDispatcher("/WEB-INF/views/etudiants/form.jsp").forward(req, resp);

            } else if ("edit".equals(action)) {
                // Show edit form
                String id = req.getParameter("id");
                Etudiant etudiant = etudiantDAO.findById(Long.parseLong(id));
                req.setAttribute("etudiant", etudiant);
                req.getRequestDispatcher("/WEB-INF/views/etudiants/form.jsp").forward(req, resp);

            } else {
                // List all etudiants with pagination
                int pageNum = page != null ? Integer.parseInt(page) : 1;
                int offset = (pageNum - 1) * PAGE_SIZE;

                List<Etudiant> etudiants;
                if (search != null && !search.isEmpty()) {
                    etudiants = etudiantDAO.search(search, PAGE_SIZE, offset);
                } else {
                    etudiants = etudiantDAO.findAll(PAGE_SIZE, offset);
                }

                req.setAttribute("etudiants", etudiants);
                req.setAttribute("currentPage", pageNum);
                req.setAttribute("pageSize", PAGE_SIZE);
                req.setAttribute("search", search);
                req.getRequestDispatcher("/WEB-INF/views/etudiants/list.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Erreur: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String action = req.getParameter("action");

            if ("update".equals(action)) {
                // Update existing etudiant
                Etudiant etudiant = new Etudiant();
                etudiant.setId(Long.parseLong(req.getParameter("id")));
                etudiant.setMatricule(req.getParameter("matricule"));
                etudiant.setNom(req.getParameter("nom"));
                etudiant.setPrenom(req.getParameter("prenom"));
                etudiant.setFiliere(req.getParameter("filiere"));
                etudiant.setAnnee(Integer.parseInt(req.getParameter("annee")));
                etudiant.setTelephone(req.getParameter("telephone"));

                etudiantDAO.update(etudiant);
                resp.sendRedirect(req.getContextPath() + "/etudiants");

            } else {
                // Create new etudiant
                Etudiant etudiant = new Etudiant();
                etudiant.setMatricule(req.getParameter("matricule"));
                etudiant.setNom(req.getParameter("nom"));
                etudiant.setPrenom(req.getParameter("prenom"));
                etudiant.setFiliere(req.getParameter("filiere"));
                etudiant.setAnnee(Integer.parseInt(req.getParameter("annee")));
                etudiant.setTelephone(req.getParameter("telephone"));

                etudiantDAO.insert(etudiant);
                resp.sendRedirect(req.getContextPath() + "/etudiants");
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Erreur: " + e.getMessage());
            try {
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            } catch (ServletException se) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
            }
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String id = req.getParameter("id");
            etudiantDAO.delete(Long.parseLong(id));
            resp.sendRedirect(req.getContextPath() + "/etudiants");
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }
}
