<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!-- Navigation Sidebar -->
<aside class="sidebar">
    <div class="sidebar-logo">NotesSup</div>

    <nav>
        <ul class="sidebar-nav">
            <li><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>

            <c:choose>
                <c:when test="${sessionScope.user.role == 'CHEF_DEPT'}">
                    <!-- Chef Dept Menu -->
                    <li><a href="${pageContext.request.contextPath}/etudiants">Étudiants</a></li>
                    <li><a href="${pageContext.request.contextPath}/matieres">Matières</a></li>
                    <li><a href="${pageContext.request.contextPath}/notes">Notes</a></li>
                    <li><a href="${pageContext.request.contextPath}/deliberations">Délibérations</a></li>
                    <li><a href="${pageContext.request.contextPath}/statistiques">Statistiques</a></li>
                </c:when>

                <c:when test="${sessionScope.user.role == 'ENSEIGNANT'}">
                    <!-- Enseignant Menu -->
                    <li><a href="${pageContext.request.contextPath}/notes">Mes Notes</a></li>
                    <li><a href="${pageContext.request.contextPath}/etudiants">Étudiants</a></li>
                </c:when>

                <c:when test="${sessionScope.user.role == 'ETUDIANT'}">
                    <!-- Étudiant Menu -->
                    <li><a href="${pageContext.request.contextPath}/bulletins">Mon Bulletin</a></li>
                </c:when>
            </c:choose>
        </ul>
    </nav>

    <div class="sidebar-divider"></div>

    <div style="font-size: var(--text-xs); color: var(--color-text-muted); margin-bottom: var(--space-4);">
        <strong>${sessionScope.user.nom}</strong><br>
        ${sessionScope.user.role}
    </div>

    <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary btn-sm" style="width: 100%;">
        Déconnexion
    </a>
</aside>
