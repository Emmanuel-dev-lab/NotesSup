package org.ict4d.notessup.filters;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Authentication Filter
 * Checks if user has a valid session before accessing protected resources.
 * Public URLs: /login, /assets/*, /api/auth/login
 * Protected: All other URLs require valid session
 */
@WebFilter(filterName = "AuthenticationFilter", urlPatterns = {"/*"})
public class AuthenticationFilter implements Filter {

    private static final String[] PUBLIC_PATHS = {
            "/login",
            "/assets/",
            "/css/",
            "/js/",
            "/api/auth/login",
            "/hello-servlet"
    };

    // Public paths matching

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialize filter
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());

        // Check if the path is public
        if (isPublicPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Check session for protected paths
        HttpSession session = httpRequest.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            // Valid session exists, now check role permissions
            String role = (String) session.getAttribute("role");
            
            if (hasPermission(path, role, httpRequest.getQueryString())) {
                chain.doFilter(request, response);
            } else {
                // Not authorized - redirect to 403 or home
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Accès refusé pour votre rôle");
            }
        } else {
            // No valid session - redirect to login
            httpResponse.sendRedirect(contextPath + "/login");
        }
    }

    /**
     * Role-based authorization check
     */
    private boolean hasPermission(String path, String role, String queryString) {
        // CHEF_DEPT has access to everything
        if ("CHEF_DEPT".equals(role)) {
            return true;
        }

        // ENSEIGNANT access
        if ("ENSEIGNANT".equals(role)) {
            // Cannot access sensitive actions like adding/deleting students or publishing deliberations
            if (path.startsWith("/etudiants") && queryString != null && 
                (queryString.contains("action=add") || queryString.contains("action=edit") || queryString.contains("action=delete"))) {
                return false;
            }
            if (path.startsWith("/deliberations") && queryString != null && 
                (queryString.contains("action=add") || queryString.contains("action=publish"))) {
                return false;
            }
            return true;
        }

        // ETUDIANT access
        if ("ETUDIANT".equals(role)) {
            // Restricted to their basic view pages
            return path.equals("/dashboard") || 
                   path.equals("/bulletins") || 
                   path.equals("/statistiques") || 
                   path.startsWith("/assets/") ||
                   path.startsWith("/css/") ||
                   path.startsWith("/js/");
        }

        return false;
    }

    @Override
    public void destroy() {
        // Clean up filter resources
    }

    /**
     * Check if the given path is public (doesn't require authentication)
     */
    private boolean isPublicPath(String path) {
        if (path == null || path.isEmpty() || path.equals("/")) {
            return true; // Root is public
        }

        for (String publicPath : PUBLIC_PATHS) {
            if (publicPath.endsWith("/")) {
                // Prefix matching for paths like "/assets/"
                if (path.startsWith(publicPath)) {
                    return true;
                }
            } else {
                // Exact matching for paths like "/login"
                if (path.equals(publicPath)) {
                    return true;
                }
            }
        }
        return false;
    }
}
