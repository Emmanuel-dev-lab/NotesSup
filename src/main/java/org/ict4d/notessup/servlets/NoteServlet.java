package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.ict4d.notessup.models.Note;
import org.ict4d.notessup.models.Etudiant;
import org.ict4d.notessup.models.Matiere;
import org.ict4d.notessup.models.User;
import org.ict4d.notessup.dao.NoteDAO;
import org.ict4d.notessup.dao.EtudiantDAO;
import org.ict4d.notessup.dao.MatiereDAO;
import org.ict4d.notessup.services.NoteService;
import org.ict4d.notessup.utils.Constants;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

public class NoteServlet extends HttpServlet {
    private final NoteDAO noteDAO = new NoteDAO();
    private final EtudiantDAO etudiantDAO = new EtudiantDAO();
    private final MatiereDAO matiereDAO = new MatiereDAO();
    private final NoteService noteService = new NoteService();
    private static final int PAGE_SIZE = Constants.DEFAULT_PAGE_SIZE;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String role = (String) session.getAttribute(Constants.SESSION_ROLE);

        // CHEF_DEPT and ENSEIGNANT can view notes
        if (!Constants.ROLE_CHEF.equals(role) && !Constants.ROLE_ENSEIGNANT.equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
            return;
        }

        String action = req.getParameter("action");
        String page = req.getParameter("page");
        String etudiantId = req.getParameter("etudiant");
        String matiereId = req.getParameter("matiere");
        String sessionParam = req.getParameter("session");
        String anneeAcademique = req.getParameter("annee");

        try {
            if ("grille".equals(action)) {
                // Show grille de saisie des notes (CHEF only)
                if (!Constants.ROLE_CHEF.equals(role)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                    return;
                }
                List<Etudiant> etudiants = etudiantDAO.findAll(100, 0);
                List<Matiere> matieres = matiereDAO.findAll(100, 0);

                req.setAttribute("etudiants", etudiants);
                req.setAttribute("matieres", matieres);
                req.setAttribute("session", sessionParam);
                req.setAttribute("anneeAcademique", anneeAcademique);
                req.getRequestDispatcher("/WEB-INF/views/notes/grille.jsp").forward(req, resp);

            } else if ("add".equals(action)) {
                // Show add form (CHEF only)
                if (!Constants.ROLE_CHEF.equals(role)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                    return;
                }
                List<Etudiant> etudiants = etudiantDAO.findAll(100, 0);
                List<Matiere> matieres = matiereDAO.findAll(100, 0);

                req.setAttribute("etudiants", etudiants);
                req.setAttribute("matieres", matieres);
                req.getRequestDispatcher("/WEB-INF/views/notes/form.jsp").forward(req, resp);

            } else if ("edit".equals(action)) {
                // Show edit form (CHEF only)
                if (!Constants.ROLE_CHEF.equals(role)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                    return;
                }
                String id = req.getParameter("id");
                Note note = noteDAO.findById(Long.parseLong(id));
                List<Etudiant> etudiants = etudiantDAO.findAll(100, 0);
                List<Matiere> matieres = matiereDAO.findAll(100, 0);

                req.setAttribute("note", note);
                req.setAttribute("etudiants", etudiants);
                req.setAttribute("matieres", matieres);
                req.getRequestDispatcher("/WEB-INF/views/notes/form.jsp").forward(req, resp);

            } else {
                // List all notes with pagination
                int pageNum = page != null ? Integer.parseInt(page) : 1;
                int offset = (pageNum - 1) * PAGE_SIZE;

                List<Note> notes;
                int totalCount = 0;
                if (etudiantId != null && !etudiantId.isEmpty()) {
                    notes = noteDAO.findByEtudiant(Long.parseLong(etudiantId), PAGE_SIZE, offset);
                    totalCount = noteDAO.countByEtudiant(Long.parseLong(etudiantId));
                } else if (matiereId != null && !matiereId.isEmpty()) {
                    notes = noteDAO.findByMatiere(Long.parseLong(matiereId), PAGE_SIZE, offset);
                    totalCount = noteDAO.countByMatiere(Long.parseLong(matiereId));
                } else {
                    notes = noteDAO.findAll(PAGE_SIZE, offset);
                    totalCount = noteDAO.count();
                }
                
                int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
                
                noteService.populateNoteRelations(notes);

                req.setAttribute("notes", notes);
                req.setAttribute("currentPage", pageNum);
                req.setAttribute("totalPages", totalPages);
                req.setAttribute("pageSize", PAGE_SIZE);
                req.setAttribute("etudiant", etudiantId);
                req.setAttribute("matiere", matiereId);

                req.getRequestDispatcher("/WEB-INF/views/notes/list.jsp").forward(req, resp);
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
        User user = (User) session.getAttribute(Constants.SESSION_USER);

        try {
            String action = req.getParameter("action");

            if ("update".equals(action)) {
                // Update existing note
                // CHEF can always update, ENSEIGNANT can update only for their matieres
                long matiereId = Long.parseLong(req.getParameter("matiere"));
                if (Constants.ROLE_ENSEIGNANT.equals(role)) {
                    Matiere matiere = matiereDAO.findById(matiereId);
                    if (matiere == null || !matiere.getEnseignant().equals(user.getNom())) {
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                        return;
                    }
                } else if (!Constants.ROLE_CHEF.equals(role)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                    return;
                }

                Note note = new Note();
                note.setId(Long.parseLong(req.getParameter("id")));
                note.setEtudiantId(Long.parseLong(req.getParameter("etudiant")));
                note.setMatiereId(matiereId);
                note.setNoteCC(new BigDecimal(req.getParameter("noteCC")));
                note.setNoteExam(new BigDecimal(req.getParameter("noteExam")));
                note.setSession(req.getParameter("session"));
                note.setAnneeAcademique(req.getParameter("annee"));
                note.setSaisiePar(user != null ? user.getLogin() : "system");

                // Calculate noteFinale
                BigDecimal noteFinale = noteService.calcNoteFinale(note.getNoteCC(), note.getNoteExam());
                note.setNoteFinale(noteFinale);

                noteDAO.update(note);
                resp.sendRedirect(req.getContextPath() + "/notes");

            } else {
                // Create new note
                // CHEF can always create, ENSEIGNANT can create only for their matieres
                long matiereId = Long.parseLong(req.getParameter("matiere"));
                if (Constants.ROLE_ENSEIGNANT.equals(role)) {
                    Matiere matiere = matiereDAO.findById(matiereId);
                    if (matiere == null || !matiere.getEnseignant().equals(user.getNom())) {
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                        return;
                    }
                } else if (!Constants.ROLE_CHEF.equals(role)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
                    return;
                }

                Note note = new Note();
                note.setEtudiantId(Long.parseLong(req.getParameter("etudiant")));
                note.setMatiereId(matiereId);
                note.setNoteCC(new BigDecimal(req.getParameter("noteCC")));
                note.setNoteExam(new BigDecimal(req.getParameter("noteExam")));
                note.setSession(req.getParameter("session"));
                note.setAnneeAcademique(req.getParameter("annee"));
                note.setSaisiePar(user != null ? user.getLogin() : "system");

                // Calculate noteFinale
                BigDecimal noteFinale = noteService.calcNoteFinale(note.getNoteCC(), note.getNoteExam());
                note.setNoteFinale(noteFinale);

                noteDAO.insert(note);
                resp.sendRedirect(req.getContextPath() + "/notes");
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

        // Only CHEF_DEPT can delete notes
        if (!Constants.ROLE_CHEF.equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Non autorisé");
            return;
        }

        try {
            String id = req.getParameter("id");
            noteDAO.delete(Long.parseLong(id));
            resp.sendRedirect(req.getContextPath() + "/notes");
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
