package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.ict4d.notessup.models.Matiere;
import org.ict4d.notessup.dao.MatiereDAO;
import org.ict4d.notessup.utils.Constants;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class MatiereServlet extends HttpServlet {
    private final MatiereDAO matiereDAO = new MatiereDAO();
    private static final int PAGE_SIZE = Constants.DEFAULT_PAGE_SIZE;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String role = (String) session.getAttribute(Constants.SESSION_ROLE);

        // CHEF_DEPT and ENSEIGNANT can view matieres (read-only for ENSEIGNANT)
        if (!Constants.ROLE_CHEF.equals(role) && !Constants.ROLE_ENSEIGNANT.equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
            return;
        }

        // ENSEIGNANT cannot see add/edit forms
        if (Constants.ROLE_ENSEIGNANT.equals(role)) {
            String action = req.getParameter("action");
            if ("add".equals(action) || "edit".equals(action)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                return;
            }
        }

        String action = req.getParameter("action");
        String page = req.getParameter("page");
        String search = req.getParameter("search");
        String filiere = req.getParameter("filiere");

        try {
            if ("add".equals(action)) {
                // Show add form
                req.getRequestDispatcher("/WEB-INF/views/matieres/form.jsp").forward(req, resp);

            } else if ("edit".equals(action)) {
                // Show edit form
                String id = req.getParameter("id");
                Matiere matiere = matiereDAO.findById(Long.parseLong(id));
                req.setAttribute("matiere", matiere);
                req.getRequestDispatcher("/WEB-INF/views/matieres/form.jsp").forward(req, resp);

            } else {
                // List all matieres with pagination
                int pageNum = page != null ? Integer.parseInt(page) : 1;
                int offset = (pageNum - 1) * PAGE_SIZE;

                List<Matiere> matieres;
                int totalCount = 0;
                if (search != null && !search.isEmpty()) {
                    matieres = matiereDAO.search(search, PAGE_SIZE, offset);
                    totalCount = matiereDAO.countSearch(search);
                } else if (filiere != null && !filiere.isEmpty()) {
                    matieres = matiereDAO.findByFiliere(filiere, PAGE_SIZE, offset);
                    totalCount = matiereDAO.countByFiliere(filiere);
                } else {
                    matieres = matiereDAO.findAll(PAGE_SIZE, offset);
                    totalCount = matiereDAO.count();
                }

                int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);

                req.setAttribute("matieres", matieres);
                req.setAttribute("currentPage", pageNum);
                req.setAttribute("totalPages", totalPages);
                req.setAttribute("pageSize", PAGE_SIZE);
                req.setAttribute("totalCount", totalCount);
                req.setAttribute("search", search);
                req.setAttribute("selectedFiliere", filiere);
                req.setAttribute("filieres", Constants.FILIERES);
                req.getRequestDispatcher("/WEB-INF/views/matieres/list.jsp").forward(req, resp);
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

        // Only CHEF_DEPT can create/update matieres
        if (!Constants.ROLE_CHEF.equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
            return;
        }

        try {
            String action = req.getParameter("action");

            if ("update".equals(action)) {
                // Update existing matiere
                Matiere matiere = new Matiere();
                matiere.setId(Long.parseLong(req.getParameter("id")));
                matiere.setCode(req.getParameter("code"));
                matiere.setIntitule(req.getParameter("intitule"));
                matiere.setCoefficient(Integer.parseInt(req.getParameter("coefficient")));
                matiere.setEnseignant(req.getParameter("enseignant"));
                matiere.setSemestre(Integer.parseInt(req.getParameter("semestre")));
                matiere.setFiliere(req.getParameter("filiere"));

                matiereDAO.update(matiere);
                resp.sendRedirect(req.getContextPath() + "/matieres");

            } else {
                // Create new matiere
                Matiere matiere = new Matiere();
                matiere.setCode(req.getParameter("code"));
                matiere.setIntitule(req.getParameter("intitule"));
                matiere.setCoefficient(Integer.parseInt(req.getParameter("coefficient")));
                matiere.setEnseignant(req.getParameter("enseignant"));
                matiere.setSemestre(Integer.parseInt(req.getParameter("semestre")));
                matiere.setFiliere(req.getParameter("filiere"));

                matiereDAO.insert(matiere);
                resp.sendRedirect(req.getContextPath() + "/matieres");
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
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String role = (String) session.getAttribute(Constants.SESSION_ROLE);

        // Only CHEF_DEPT can delete matieres
        if (!Constants.ROLE_CHEF.equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
            return;
        }

        try {
            String id = req.getParameter("id");
            matiereDAO.delete(Long.parseLong(id));
            resp.sendRedirect(req.getContextPath() + "/matieres");
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
