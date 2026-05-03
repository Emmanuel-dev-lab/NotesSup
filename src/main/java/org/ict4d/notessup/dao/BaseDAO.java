package org.ict4d.notessup.dao;

import org.ict4d.notessup.utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public abstract class BaseDAO<T> {
    public abstract List<T> findAll(int limit, int offset) throws SQLException;
    public abstract T findById(Long id) throws SQLException;
    public abstract void insert(T entity) throws SQLException;
    public abstract void update(T entity) throws SQLException;
    public abstract void delete(Long id) throws SQLException;

    protected Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    protected void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    protected void close(Connection conn, PreparedStatement pstmt) {
        close(conn, pstmt, null);
    }
}
