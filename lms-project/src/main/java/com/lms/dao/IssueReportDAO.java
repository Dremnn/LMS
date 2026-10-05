package com.lms.dao;

import com.lms.model.IssueReport;
import com.lms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class IssueReportDAO {

    public IssueReportDAO() {
        ensureTableExists();
    }

    public void ensureTableExists() {
        String sql = "CREATE TABLE IF NOT EXISTS issue_reports (" +
                     "id SERIAL PRIMARY KEY, " +
                     "reference_code VARCHAR(50) UNIQUE NOT NULL, " +
                     "email VARCHAR(150) NOT NULL, " +
                     "role VARCHAR(50) NOT NULL, " +
                     "issue_type VARCHAR(50) NOT NULL, " +
                     "description TEXT NOT NULL, " +
                     "page_url VARCHAR(500), " +
                     "screenshots TEXT, " +
                     "status VARCHAR(30) NOT NULL DEFAULT 'pending', " +
                     "admin_note TEXT, " +
                     "resolved_by INT REFERENCES users(id) ON DELETE SET NULL, " +
                     "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                     "updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP" +
                     ");";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public boolean insert(IssueReport report) {
        String sql = "INSERT INTO issue_reports (reference_code, email, role, issue_type, description, page_url, screenshots, status, created_at, updated_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, report.getReferenceCode());
            ps.setString(2, report.getEmail());
            ps.setString(3, report.getRole());
            ps.setString(4, report.getIssueType());
            ps.setString(5, report.getDescription());
            ps.setString(6, report.getPageUrl());
            ps.setString(7, report.getScreenshots());
            ps.setString(8, report.getStatus() != null ? report.getStatus() : "pending");

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        report.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public IssueReport findById(int id) {
        String sql = "SELECT ir.*, u.full_name AS resolved_by_name " +
                     "FROM issue_reports ir " +
                     "LEFT JOIN users u ON ir.resolved_by = u.id " +
                     "WHERE ir.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToIssueReport(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public IssueReport findByReferenceCode(String refCode) {
        String sql = "SELECT ir.*, u.full_name AS resolved_by_name " +
                     "FROM issue_reports ir " +
                     "LEFT JOIN users u ON ir.resolved_by = u.id " +
                     "WHERE ir.reference_code = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, refCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToIssueReport(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<IssueReport> findAll(String status, String role, String keyword) {
        List<IssueReport> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT ir.*, u.full_name AS resolved_by_name " +
                "FROM issue_reports ir " +
                "LEFT JOIN users u ON ir.resolved_by = u.id " +
                "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status.trim())) {
            sql.append("AND ir.status = ? ");
            params.add(status.trim().toLowerCase());
        }

        if (role != null && !role.trim().isEmpty() && !"all".equalsIgnoreCase(role.trim())) {
            sql.append("AND ir.role = ? ");
            params.add(role.trim().toLowerCase());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (ir.reference_code ILIKE ? OR ir.email ILIKE ? OR ir.description ILIKE ?) ");
            String searchPattern = "%" + keyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        sql.append("ORDER BY ir.created_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToIssueReport(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateStatus(int id, String status, String adminNote, Integer resolvedBy) {
        String sql = "UPDATE issue_reports " +
                     "SET status = ?, admin_note = ?, resolved_by = ?, updated_at = CURRENT_TIMESTAMP " +
                     "WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, adminNote);
            if (resolvedBy != null) {
                ps.setInt(3, resolvedBy);
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setInt(4, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM issue_reports";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM issue_reports WHERE status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private IssueReport mapResultSetToIssueReport(ResultSet rs) throws SQLException {
        IssueReport r = new IssueReport();
        r.setId(rs.getInt("id"));
        r.setReferenceCode(rs.getString("reference_code"));
        r.setEmail(rs.getString("email"));
        r.setRole(rs.getString("role"));
        r.setIssueType(rs.getString("issue_type"));
        r.setDescription(rs.getString("description"));
        r.setPageUrl(rs.getString("page_url"));
        r.setScreenshots(rs.getString("screenshots"));
        r.setStatus(rs.getString("status"));
        r.setAdminNote(rs.getString("admin_note"));
        int resolvedBy = rs.getInt("resolved_by");
        if (!rs.wasNull()) {
            r.setResolvedBy(resolvedBy);
        }
        r.setResolvedByName(rs.getString("resolved_by_name"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));
        return r;
    }
}
