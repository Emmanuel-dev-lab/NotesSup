package org.ict4d.notessup.dao;

import org.ict4d.notessup.models.Matiere;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class MatiereDAO extends BaseDAO<Matiere> {

    @Override
    public List<Matiere> findAll(int limit, int offset) throws SQLException {
        List<Matiere> matieres = new ArrayList<>();
        String sql = "SELECT * FROM matiere ORDER BY code LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    matieres.add(mapMatiere(rs));
                }
            }
        }
        return matieres;
    }

    public List<Matiere> findByFiliere(String filiere, int limit, int offset) throws SQLException {
        List<Matiere> matieres = new ArrayList<>();
        String sql = "SELECT * FROM matiere WHERE filiere = ? ORDER BY code LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, filiere);
            pstmt.setInt(2, limit);
            pstmt.setInt(3, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    matieres.add(mapMatiere(rs));
                }
            }
        }
        return matieres;
    }

    public List<Matiere> search(String query, int limit, int offset) throws SQLException {
        List<Matiere> matieres = new ArrayList<>();
        String sql = "SELECT * FROM matiere WHERE code LIKE ? OR intitule LIKE ? ORDER BY code LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String searchTerm = "%" + query + "%";
            pstmt.setString(1, searchTerm);
            pstmt.setString(2, searchTerm);
            pstmt.setInt(3, limit);
            pstmt.setInt(4, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    matieres.add(mapMatiere(rs));
                }
            }
        }
        return matieres;
    }

    public int count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM matiere";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int countByFiliere(String filiere) throws SQLException {
        String sql = "SELECT COUNT(*) FROM matiere WHERE filiere = ?";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, filiere);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int countSearch(String query) throws SQLException {
        String sql = "SELECT COUNT(*) FROM matiere WHERE code LIKE ? OR intitule LIKE ? OR enseignant LIKE ?";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String searchTerm = "%" + query + "%";
            pstmt.setString(1, searchTerm);
            pstmt.setString(2, searchTerm);
            pstmt.setString(3, searchTerm);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    @Override
    public Matiere findById(Long id) throws SQLException {
        String sql = "SELECT * FROM matiere WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapMatiere(rs);
                }
            }
        }
        return null;
    }

    public Matiere findByCode(String code) throws SQLException {
        String sql = "SELECT * FROM matiere WHERE code = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, code);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapMatiere(rs);
                }
            }
        }
        return null;
    }

    @Override
    public void insert(Matiere matiere) throws SQLException {
        String sql = "INSERT INTO matiere (code, intitule, coefficient, enseignant, semestre, filiere) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, matiere.getCode());
            pstmt.setString(2, matiere.getIntitule());
            pstmt.setInt(3, matiere.getCoefficient());
            pstmt.setString(4, matiere.getEnseignant());
            pstmt.setInt(5, matiere.getSemestre());
            pstmt.setString(6, matiere.getFiliere());
            pstmt.executeUpdate();
        }
    }

    @Override
    public void update(Matiere matiere) throws SQLException {
        String sql = "UPDATE matiere SET intitule = ?, coefficient = ?, enseignant = ?, semestre = ?, filiere = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, matiere.getIntitule());
            pstmt.setInt(2, matiere.getCoefficient());
            pstmt.setString(3, matiere.getEnseignant());
            pstmt.setInt(4, matiere.getSemestre());
            pstmt.setString(5, matiere.getFiliere());
            pstmt.setLong(6, matiere.getId());
            pstmt.executeUpdate();
        }
    }

    @Override
    public void delete(Long id) throws SQLException {
        String sql = "DELETE FROM matiere WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            pstmt.executeUpdate();
        }
    }

    private Matiere mapMatiere(ResultSet rs) throws SQLException {
        Matiere matiere = new Matiere();
        matiere.setId(rs.getLong("id"));
        matiere.setCode(rs.getString("code"));
        matiere.setIntitule(rs.getString("intitule"));
        matiere.setCoefficient(rs.getInt("coefficient"));
        matiere.setEnseignant(rs.getString("enseignant"));
        matiere.setSemestre(rs.getInt("semestre"));
        matiere.setFiliere(rs.getString("filiere"));
        return matiere;
    }
}
