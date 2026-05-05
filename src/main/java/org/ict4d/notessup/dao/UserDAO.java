package org.ict4d.notessup.dao;

import org.ict4d.notessup.models.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAO extends BaseDAO<User> {

    @Override
    public List<User> findAll(int limit, int offset) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM user LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    users.add(mapUser(rs));
                }
            }
        }
        return users;
    }

    @Override
    public User findById(Long id) throws SQLException {
        String sql = "SELECT * FROM user WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }

    public int count() throws SQLException {
        String sql = "SELECT COUNT(*) FROM user";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public List<User> search(String query, int limit, int offset) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM user WHERE login LIKE ? OR nom LIKE ? OR role LIKE ? LIMIT ? OFFSET ?";
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
                    users.add(mapUser(rs));
                }
            }
        }
        return users;
    }

    public int countSearch(String query) throws SQLException {
        String sql = "SELECT COUNT(*) FROM user WHERE login LIKE ? OR nom LIKE ? OR role LIKE ?";
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

    public User findByLogin(String login) throws SQLException {
        String sql = "SELECT * FROM user WHERE login = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, login);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }

    @Override
    public void insert(User user) throws SQLException {
        String sql = "INSERT INTO user (login, password, role, nom, filiere) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, user.getLogin());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getRole());
            pstmt.setString(4, user.getNom());
            pstmt.setString(5, user.getFiliere());
            pstmt.executeUpdate();
        }
    }

    @Override
    public void update(User user) throws SQLException {
        String sql = "UPDATE user SET password = ?, role = ?, nom = ?, filiere = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, user.getPassword());
            pstmt.setString(2, user.getRole());
            pstmt.setString(3, user.getNom());
            pstmt.setString(4, user.getFiliere());
            pstmt.setLong(5, user.getId());
            pstmt.executeUpdate();
        }
    }

    @Override
    public void delete(Long id) throws SQLException {
        String sql = "DELETE FROM user WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            pstmt.executeUpdate();
        }
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getLong("id"));
        user.setLogin(rs.getString("login"));
        user.setPassword(rs.getString("password"));
        user.setRole(rs.getString("role"));
        user.setNom(rs.getString("nom"));
        user.setFiliere(rs.getString("filiere"));
        user.setEtudiantId(rs.getObject("etudiant_id") != null ? rs.getLong("etudiant_id") : null);
        return user;
    }
}
