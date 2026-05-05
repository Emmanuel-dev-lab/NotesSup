package org.ict4d.notessup.dao;

import org.ict4d.notessup.models.Deliberation;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DeliberationDAO extends BaseDAO<Deliberation> {

    @Override
    public List<Deliberation> findAll(int limit, int offset) throws SQLException {
        List<Deliberation> deliberations = new ArrayList<>();
        String sql = "SELECT * FROM deliberation ORDER BY created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    deliberations.add(mapDeliberation(rs));
                }
            }
        }
        return deliberations;
    }

    public List<Deliberation> findByFiliere(String filiere, int limit, int offset) throws SQLException {
        List<Deliberation> deliberations = new ArrayList<>();
        String sql = "SELECT * FROM deliberation WHERE filiere = ? ORDER BY created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, filiere);
            pstmt.setInt(2, limit);
            pstmt.setInt(3, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    deliberations.add(mapDeliberation(rs));
                }
            }
        }
        return deliberations;
    }

    public List<Deliberation> findPublished(int limit, int offset) throws SQLException {
        List<Deliberation> deliberations = new ArrayList<>();
        String sql = "SELECT * FROM deliberation WHERE publiee = TRUE ORDER BY created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    deliberations.add(mapDeliberation(rs));
                }
            }
        }
        return deliberations;
    }

    public int count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM deliberation";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int countByFiliere(String filiere) throws SQLException {
        String sql = "SELECT COUNT(*) FROM deliberation WHERE filiere = ?";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, filiere);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int countPublished() throws SQLException {
        String sql = "SELECT COUNT(*) FROM deliberation WHERE publiee = TRUE";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    @Override
    public Deliberation findById(Long id) throws SQLException {
        String sql = "SELECT * FROM deliberation WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapDeliberation(rs);
                }
            }
        }
        return null;
    }

    @Override
    public void insert(Deliberation deliberation) throws SQLException {
        String sql = "INSERT INTO deliberation (filiere, session, annee_academique, publiee, publiee_par) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, deliberation.getFiliere());
            pstmt.setString(2, deliberation.getSession());
            pstmt.setString(3, deliberation.getAnneeAcademique());
            pstmt.setBoolean(4, deliberation.getPubliee() != null ? deliberation.getPubliee() : false);
            pstmt.setString(5, deliberation.getPubliePar());
            pstmt.executeUpdate();
        }
    }

    @Override
    public void update(Deliberation deliberation) throws SQLException {
        String sql = "UPDATE deliberation SET date_publication = ?, publiee = ?, publiee_par = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setObject(1, deliberation.getDatePublication());
            pstmt.setBoolean(2, deliberation.getPubliee() != null ? deliberation.getPubliee() : false);
            pstmt.setString(3, deliberation.getPubliePar());
            pstmt.setLong(4, deliberation.getId());
            pstmt.executeUpdate();
        }
    }

    @Override
    public void delete(Long id) throws SQLException {
        String sql = "DELETE FROM deliberation WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            pstmt.executeUpdate();
        }
    }

    private Deliberation mapDeliberation(ResultSet rs) throws SQLException {
        Deliberation deliberation = new Deliberation();
        deliberation.setId(rs.getLong("id"));
        deliberation.setFiliere(rs.getString("filiere"));
        deliberation.setSession(rs.getString("session"));
        deliberation.setAnneeAcademique(rs.getString("annee_academique"));
        deliberation.setDatePublication(rs.getObject("date_publication") != null ? rs.getDate("date_publication").toLocalDate() : null);
        deliberation.setPubliee(rs.getBoolean("publiee"));
        deliberation.setPubliePar(rs.getString("publiee_par"));
        return deliberation;
    }
}
