package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.ict4d.notessup.models.User;
import org.ict4d.notessup.dao.UserDAO;
import org.ict4d.notessup.utils.Constants;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/users")
public class UserServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private static final int PAGE_SIZE = Constants.DEFAULT_PAGE_SIZE;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String role = (String) session.getAttribute(Constants.SESSION_ROLE);

        // Only CHEF_DEPT can view users
        if (!Constants.ROLE_CHEF.equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
            return;
        }

        String action = req.getParameter("action");
        String page = req.getParameter("page");
        String search = req.getParameter("search");

        try {
            if ("add".equals(action)) {
                req.getRequestDispatcher("/WEB-INF/views/users/form.jsp").forward(req, resp);
            } else if ("edit".equals(action)) {
                String id = req.getParameter("id");
                User targetUser = userDAO.findById(Long.parseLong(id));
                req.setAttribute("targetUser", targetUser);
                req.getRequestDispatcher("/WEB-INF/views/users/form.jsp").forward(req, resp);
            } else {
                int pageNum = page != null ? Integer.parseInt(page) : 1;
                int offset = (pageNum - 1) * PAGE_SIZE;

                List<User> users;
                if (search != null && !search.isEmpty()) {
                    users = userDAO.search(search, PAGE_SIZE, offset);
                } else {
                    users = userDAO.findAll(PAGE_SIZE, offset);
                }

                req.setAttribute("users", users);
                req.setAttribute("currentPage", pageNum);
                req.setAttribute("pageSize", PAGE_SIZE);
                req.setAttribute("search", search);
                req.getRequestDispatcher("/WEB-INF/views/users/list.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Erreur: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String currentRole = (String) session.getAttribute(Constants.SESSION_ROLE);

        if (!Constants.ROLE_CHEF.equals(currentRole)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
            return;
        }

        try {
            String action = req.getParameter("action");
            User user = new User();
            user.setLogin(req.getParameter("login"));
            user.setRole(req.getParameter("role"));
            user.setNom(req.getParameter("nom"));
            user.setFiliere(req.getParameter("filiere"));

            String password = req.getParameter("password");

            if ("update".equals(action)) {
                user.setId(Long.parseLong(req.getParameter("id")));
                // If password is provided, re-hash and update, else retain old password
                if (password != null && !password.trim().isEmpty()) {
                    user.setPassword(BCrypt.hashpw(password, BCrypt.gensalt(10)));
                } else {
                    User oldUser = userDAO.findById(user.getId());
                    user.setPassword(oldUser.getPassword());
                }
                userDAO.update(user);
            } else {
                // Creation
                if (password == null || password.trim().isEmpty()) {
                    password = "pass123";
                }
                user.setPassword(BCrypt.hashpw(password, BCrypt.gensalt(10)));
                userDAO.insert(user);
            }
            resp.sendRedirect(req.getContextPath() + "/users");
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
        HttpSession session = req.getSession(false);
        String role = (String) session.getAttribute(Constants.SESSION_ROLE);

        if (!Constants.ROLE_CHEF.equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
            return;
        }

        try {
            Long id = Long.parseLong(req.getParameter("id"));
            userDAO.delete(id);
            resp.sendRedirect(req.getContextPath() + "/users");
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }
}
