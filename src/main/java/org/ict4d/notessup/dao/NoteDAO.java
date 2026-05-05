package org.ict4d.notessup.dao;

import org.ict4d.notessup.models.Note;
import org.ict4d.notessup.models.FiliereStat;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class NoteDAO extends BaseDAO<Note> {

    @Override
    public List<Note> findAll(int limit, int offset) throws SQLException {
        List<Note> notes = new ArrayList<>();
        String sql = "SELECT n.* FROM note n JOIN matiere m ON n.matiere_id = m.id ORDER BY m.intitule ASC, n.created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    notes.add(mapNote(rs));
                }
            }
        }
        return notes;
    }

    public List<Note> findByEtudiant(Long etudiantId, int limit, int offset) throws SQLException {
        List<Note> notes = new ArrayList<>();
        String sql = "SELECT n.* FROM note n JOIN matiere m ON n.matiere_id = m.id WHERE n.etudiant_id = ? ORDER BY m.intitule ASC, n.created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, etudiantId);
            pstmt.setInt(2, limit);
            pstmt.setInt(3, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    notes.add(mapNote(rs));
                }
            }
        }
        return notes;
    }

    public List<Note> findByMatiere(Long matiereId, int limit, int offset) throws SQLException {
        List<Note> notes = new ArrayList<>();
        String sql = "SELECT * FROM note WHERE matiere_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, matiereId);
            pstmt.setInt(2, limit);
            pstmt.setInt(3, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    notes.add(mapNote(rs));
                }
            }
        }
        return notes;
    }

    public List<Note> findByEnseignant(String enseignantNom, int limit, int offset) throws SQLException {
        List<Note> notes = new ArrayList<>();
        String sql = "SELECT n.* FROM note n JOIN matiere m ON n.matiere_id = m.id WHERE m.enseignant = ? ORDER BY m.intitule ASC, n.created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, enseignantNom);
            pstmt.setInt(2, limit);
            pstmt.setInt(3, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    notes.add(mapNote(rs));
                }
            }
        }
        return notes;
    }

    public int count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM note";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int countByEtudiant(Long etudiantId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM note WHERE etudiant_id = ?";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, etudiantId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int countByMatiere(Long matiereId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM note WHERE matiere_id = ?";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, matiereId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int countByEnseignant(String enseignantNom) throws SQLException {
        String sql = "SELECT COUNT(*) FROM note n JOIN matiere m ON n.matiere_id = m.id WHERE m.enseignant = ?";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, enseignantNom);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public Note findByEtudiantAndMatiere(Long etudiantId, Long matiereId, String session, String anneeAcademique) throws SQLException {
        String sql = "SELECT * FROM note WHERE etudiant_id = ? AND matiere_id = ? AND session = ? AND annee_academique = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, etudiantId);
            pstmt.setLong(2, matiereId);
            pstmt.setString(3, session);
            pstmt.setString(4, anneeAcademique);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapNote(rs);
                }
            }
        }
        return null;
    }

    @Override
    public Note findById(Long id) throws SQLException {
        String sql = "SELECT * FROM note WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapNote(rs);
                }
            }
        }
        return null;
    }

    @Override
    public void insert(Note note) throws SQLException {
        String sql = "INSERT INTO note (etudiant_id, matiere_id, note_cc, note_exam, note_finale, session, annee_academique, saisie_par) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, note.getEtudiantId());
            pstmt.setLong(2, note.getMatiereId());
            pstmt.setBigDecimal(3, note.getNoteCC());
            pstmt.setBigDecimal(4, note.getNoteExam());
            pstmt.setBigDecimal(5, note.getNoteFinale());
            pstmt.setString(6, note.getSession());
            pstmt.setString(7, note.getAnneeAcademique());
            pstmt.setString(8, note.getSaisiePar());
            pstmt.executeUpdate();
        }
    }

    @Override
    public void update(Note note) throws SQLException {
        String sql = "UPDATE note SET note_cc = ?, note_exam = ?, note_finale = ?, saisie_par = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setBigDecimal(1, note.getNoteCC());
            pstmt.setBigDecimal(2, note.getNoteExam());
            pstmt.setBigDecimal(3, note.getNoteFinale());
            pstmt.setString(4, note.getSaisiePar());
            pstmt.setLong(5, note.getId());
            pstmt.executeUpdate();
        }
    }

    @Override
    public void delete(Long id) throws SQLException {
        String sql = "DELETE FROM note WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            pstmt.executeUpdate();
        }
    }

    public List<Note> findByFiliereSessionAnnee(String filiere, String session, String annee) throws SQLException {
        List<Note> notes = new ArrayList<>();
        String sql = "SELECT n.* FROM note n " +
                     "JOIN etudiant e ON n.etudiant_id = e.id " +
                     "WHERE e.filiere = ? AND n.session = ? AND n.annee_academique = ? " +
                     "ORDER BY e.nom, e.prenom";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, filiere);
            pstmt.setString(2, session);
            pstmt.setString(3, annee);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    notes.add(mapNote(rs));
                }
            }
        }
        return notes;
    }

    public List<Note> findByEtudiantSessionAnnee(Long etudiantId, String session, String annee) throws SQLException {
        List<Note> notes = new ArrayList<>();
        String sql = "SELECT n.* FROM note n " +
                     "JOIN matiere m ON n.matiere_id = m.id " +
                     "WHERE n.etudiant_id = ? AND n.session = ? AND n.annee_academique = ? " +
                     "ORDER BY m.intitule ASC";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, etudiantId);
            pstmt.setString(2, session);
            pstmt.setString(3, annee);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    notes.add(mapNote(rs));
                }
            }
        }
        return notes;
    }

    public List<FiliereStat> getStatsPerFiliere(String session, String annee) throws SQLException {
        List<FiliereStat> stats = new ArrayList<>();
        String sql = "SELECT e.filiere, COUNT(DISTINCT e.id) as nb_etudiants, AVG(n.note_finale) as moyenne_gl, " +
                     "SUM(CASE WHEN n.note_finale >= 10 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as taux_reussite " +
                     "FROM note n " +
                     "JOIN etudiant e ON n.etudiant_id = e.id " +
                     "WHERE n.session = ? AND n.annee_academique = ? " +
                     "GROUP BY e.filiere";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, session);
            pstmt.setString(2, annee);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    FiliereStat stat = new FiliereStat();
                    stat.setFiliere(rs.getString("filiere"));
                    stat.setNbEtudiants(rs.getInt("nb_etudiants"));
                    stat.setMoyenne(rs.getBigDecimal("moyenne_gl"));
                    stat.setTauxReussite(rs.getBigDecimal("taux_reussite"));
                    stats.add(stat);
                }
            }
        }
        return stats;
    }

    private Note mapNote(ResultSet rs) throws SQLException {
        Note note = new Note();
        note.setId(rs.getLong("id"));
        note.setEtudiantId(rs.getLong("etudiant_id"));
        note.setMatiereId(rs.getLong("matiere_id"));
        note.setNoteCC(rs.getBigDecimal("note_cc"));
        note.setNoteExam(rs.getBigDecimal("note_exam"));
        note.setNoteFinale(rs.getBigDecimal("note_finale"));
        note.setSession(rs.getString("session"));
        note.setAnneeAcademique(rs.getString("annee_academique"));
        note.setSaisiePar(rs.getString("saisie_par"));
        return note;
    }
}
