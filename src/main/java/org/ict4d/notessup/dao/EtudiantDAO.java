package org.ict4d.notessup.dao;

import org.ict4d.notessup.models.Etudiant;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class EtudiantDAO extends BaseDAO<Etudiant> {

    @Override
    public List<Etudiant> findAll(int limit, int offset) throws SQLException {
        List<Etudiant> etudiants = new ArrayList<>();
        String sql = "SELECT * FROM etudiant ORDER BY nom LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    etudiants.add(mapEtudiant(rs));
                }
            }
        }
        return etudiants;
    }

    public int count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM etudiant";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public List<Etudiant> findByFiliere(String filiere, int limit, int offset) throws SQLException {
        List<Etudiant> etudiants = new ArrayList<>();
        String sql = "SELECT * FROM etudiant WHERE filiere = ? ORDER BY nom LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, filiere);
            pstmt.setInt(2, limit);
            pstmt.setInt(3, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    etudiants.add(mapEtudiant(rs));
                }
            }
        }
        return etudiants;
    }

    public int countByFiliere(String filiere) throws SQLException {
        String sql = "SELECT COUNT(*) FROM etudiant WHERE filiere = ?";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, filiere);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<Etudiant> search(String query, int limit, int offset) throws SQLException {
        List<Etudiant> etudiants = new ArrayList<>();
        String sql = "SELECT * FROM etudiant WHERE matricule LIKE ? OR nom LIKE ? OR prenom LIKE ? ORDER BY nom LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String searchTerm = "%" + query + "%";
            pstmt.setString(1, searchTerm);
            pstmt.setString(2, searchTerm);
            pstmt.setString(3, searchTerm);
            pstmt.setInt(4, limit);
            pstmt.setInt(5, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    etudiants.add(mapEtudiant(rs));
                }
            }
        }
        return etudiants;
    }

    public int countSearch(String query) throws SQLException {
        String sql = "SELECT COUNT(*) FROM etudiant WHERE matricule LIKE ? OR nom LIKE ? OR prenom LIKE ?";
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
    public Etudiant findById(Long id) throws SQLException {
        String sql = "SELECT * FROM etudiant WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapEtudiant(rs);
                }
            }
        }
        return null;
    }

    public Etudiant findByMatricule(String matricule) throws SQLException {
        String sql = "SELECT * FROM etudiant WHERE matricule = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, matricule);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapEtudiant(rs);
                }
            }
        }
        return null;
    }

    @Override
    public void insert(Etudiant etudiant) throws SQLException {
        String sql = "INSERT INTO etudiant (matricule, nom, prenom, filiere, annee, telephone) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, etudiant.getMatricule());
            pstmt.setString(2, etudiant.getNom());
            pstmt.setString(3, etudiant.getPrenom());
            pstmt.setString(4, etudiant.getFiliere());
            pstmt.setInt(5, etudiant.getAnnee());
            pstmt.setString(6, etudiant.getTelephone());
            pstmt.executeUpdate();
            
            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    etudiant.setId(generatedKeys.getLong(1));
                }
            }
        }
    }

    @Override
    public void update(Etudiant etudiant) throws SQLException {
        String sql = "UPDATE etudiant SET nom = ?, prenom = ?, filiere = ?, annee = ?, telephone = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, etudiant.getNom());
            pstmt.setString(2, etudiant.getPrenom());
            pstmt.setString(3, etudiant.getFiliere());
            pstmt.setInt(4, etudiant.getAnnee());
            pstmt.setString(5, etudiant.getTelephone());
            pstmt.setLong(6, etudiant.getId());
            pstmt.executeUpdate();
        }
    }

    @Override
    public void delete(Long id) throws SQLException {
        String sql = "DELETE FROM etudiant WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            pstmt.executeUpdate();
        }
    }

    private Etudiant mapEtudiant(ResultSet rs) throws SQLException {
        Etudiant etudiant = new Etudiant();
        etudiant.setId(rs.getLong("id"));
        etudiant.setMatricule(rs.getString("matricule"));
        etudiant.setNom(rs.getString("nom"));
        etudiant.setPrenom(rs.getString("prenom"));
        etudiant.setFiliere(rs.getString("filiere"));
        etudiant.setAnnee(rs.getInt("annee"));
        etudiant.setTelephone(rs.getString("telephone"));
        return etudiant;
    }
}
