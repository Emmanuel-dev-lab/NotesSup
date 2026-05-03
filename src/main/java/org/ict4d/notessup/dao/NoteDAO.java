package org.ict4d.notessup.dao;

import org.ict4d.notessup.models.Note;
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
        String sql = "SELECT * FROM note ORDER BY created_at DESC LIMIT ? OFFSET ?";
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
        String sql = "SELECT * FROM note WHERE etudiant_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?";
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
