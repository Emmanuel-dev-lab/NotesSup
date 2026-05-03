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
            "/api/auth/login",
            "/hello-servlet"
    };

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
            // Valid session exists
            chain.doFilter(request, response);
        } else {
            // No valid session - redirect to login
            httpResponse.sendRedirect(contextPath + "/login");
        }
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
