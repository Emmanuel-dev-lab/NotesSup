package org.ict4d.notessup.filters;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Security Header Filter
 * Adds security headers to every HTTP response to protect against common web vulnerabilities.
 * Headers:
 * - X-Frame-Options: DENY (prevent clickjacking)
 * - X-Content-Type-Options: nosniff (prevent MIME-sniffing)
 * - X-XSS-Protection: 1; mode=block (XSS protection)
 * - Strict-Transport-Security: enforce HTTPS (HSTS)
 * - Content-Security-Policy: restrict resource loading
 */
@WebFilter(filterName = "SecurityHeaderFilter", urlPatterns = {"/*"})
public class SecurityHeaderFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialize filter
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Prevent clickjacking attacks
        httpResponse.setHeader("X-Frame-Options", "DENY");

        // Prevent MIME-type sniffing
        httpResponse.setHeader("X-Content-Type-Options", "nosniff");

        // Enable XSS protection in browsers
        httpResponse.setHeader("X-XSS-Protection", "1; mode=block");

        // Enforce HTTPS (HSTS - HTTP Strict-Transport-Security)
        // max-age=31536000 (1 year), includeSubDomains, preload
        httpResponse.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains; preload");

        // Content Security Policy
        // restrict resource loading to same origin, prevent inline scripts
        httpResponse.setHeader("Content-Security-Policy",
                "default-src 'self'; " +
                "script-src 'self' 'unsafe-inline'; " +
                "style-src 'self' 'unsafe-inline'; " +
                "img-src 'self' data:; " +
                "font-src 'self'; " +
                "connect-src 'self'");

        // Disable referrer information leaking
        httpResponse.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");

        // Disable browser feature detection
        httpResponse.setHeader("Permissions-Policy", "geolocation=(), microphone=(), camera=()");

        // Continue with the filter chain
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Clean up filter resources
    }
}
