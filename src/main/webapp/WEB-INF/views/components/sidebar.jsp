<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%-- Compute initials and role color --%>
<c:set var="userName" value="${sessionScope.user.nom}" />
<c:set var="userRole" value="${sessionScope.user.role}" />

<c:choose>
    <c:when test="${userRole == 'CHEF_DEPT'}">
        <c:set var="roleColor" value="oklch(0.56 0.18 22)" />
        <c:set var="roleLabel" value="Chef de département" />
    </c:when>
    <c:when test="${userRole == 'ENSEIGNANT'}">
        <c:set var="roleColor" value="oklch(0.56 0.16 252)" />
        <c:set var="roleLabel" value="Enseignant" />
    </c:when>
    <c:otherwise>
        <c:set var="roleColor" value="oklch(0.58 0.14 160)" />
        <c:set var="roleLabel" value="Étudiant" />
    </c:otherwise>
</c:choose>

<%-- Active page detection --%>
<c:set var="uri" value="${pageContext.request.requestURI}" />
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<aside class="sidebar">
    <%-- Brand --%>
    <div class="sidebar-brand">
        <div class="sidebar-brand-icon">
            <svg width="22" height="22" viewBox="0 0 28 28" fill="none">
                <rect x="2" y="2" width="11" height="11" rx="2" fill="white" fill-opacity="0.9"/>
                <rect x="15" y="2" width="11" height="11" rx="2" fill="white" fill-opacity="0.5"/>
                <rect x="2" y="15" width="11" height="11" rx="2" fill="white" fill-opacity="0.5"/>
                <rect x="15" y="15" width="11" height="11" rx="2" fill="white" fill-opacity="0.2"/>
            </svg>
        </div>
        <div>
            <div class="sidebar-brand-name">NotesSup</div>
            <div class="sidebar-brand-sub">ICT 423 · L3</div>
        </div>
    </div>

    <%-- Navigation --%>
    <nav class="sidebar-nav">
        <div class="sidebar-nav-label">Navigation</div>

        <%-- Dashboard always visible --%>
        <a href="${ctx}/dashboard"
           class="${uri.endsWith('/dashboard') ? 'active' : ''}">
            <span class="sidebar-nav-icon">▦</span>
            <span>Tableau de bord</span>
            <c:if test="${uri.endsWith('/dashboard')}">
                <span class="sidebar-active-dot"></span>
            </c:if>
        </a>

        <c:choose>
            <c:when test="${userRole == 'CHEF_DEPT'}">
                <a href="${ctx}/etudiants"
                   class="${uri.contains('/etudiants') ? 'active' : ''}">
                    <span class="sidebar-nav-icon">◉</span>
                    <span>Étudiants</span>
                    <c:if test="${uri.contains('/etudiants')}">
                        <span class="sidebar-active-dot"></span>
                    </c:if>
                </a>
                <a href="${ctx}/matieres"
                   class="${uri.contains('/matieres') ? 'active' : ''}">
                    <span class="sidebar-nav-icon">◈</span>
                    <span>Matières</span>
                    <c:if test="${uri.contains('/matieres')}">
                        <span class="sidebar-active-dot"></span>
                    </c:if>
                </a>
                <a href="${ctx}/notes"
                   class="${uri.contains('/notes') ? 'active' : ''}">
                    <span class="sidebar-nav-icon">◎</span>
                    <span>Saisie des notes</span>
                    <c:if test="${uri.contains('/notes')}">
                        <span class="sidebar-active-dot"></span>
                    </c:if>
                </a>
                <a href="${ctx}/deliberations"
                   class="${uri.contains('/deliberations') ? 'active' : ''}">
                    <span class="sidebar-nav-icon">◇</span>
                    <span>Délibérations</span>
                    <c:if test="${uri.contains('/deliberations')}">
                        <span class="sidebar-active-dot"></span>
                    </c:if>
                </a>
                <a href="${ctx}/statistiques"
                   class="${uri.contains('/statistiques') ? 'active' : ''}">
                    <span class="sidebar-nav-icon">◈</span>
                    <span>Statistiques</span>
                    <c:if test="${uri.contains('/statistiques')}">
                        <span class="sidebar-active-dot"></span>
                    </c:if>
                </a>
                <a href="${ctx}/bulletins"
                   class="${uri.contains('/bulletins') ? 'active' : ''}">
                    <span class="sidebar-nav-icon">▤</span>
                    <span>Bulletins / PDF</span>
                    <c:if test="${uri.contains('/bulletins')}">
                        <span class="sidebar-active-dot"></span>
                    </c:if>
                </a>
                <a href="${ctx}/users"
                   class="${uri.contains('/users') ? 'active' : ''}">
                    <span class="sidebar-nav-icon">◐</span>
                    <span>Utilisateurs</span>
                    <c:if test="${uri.contains('/users')}">
                        <span class="sidebar-active-dot"></span>
                    </c:if>
                </a>
            </c:when>

            <c:when test="${userRole == 'ENSEIGNANT'}">
                <a href="${ctx}/notes"
                   class="${uri.contains('/notes') ? 'active' : ''}">
                    <span class="sidebar-nav-icon">◎</span>
                    <span>Saisie des notes</span>
                    <c:if test="${uri.contains('/notes')}"><span class="sidebar-active-dot"></span></c:if>
                </a>
                <a href="${ctx}/etudiants"
                   class="${uri.contains('/etudiants') ? 'active' : ''}">
                    <span class="sidebar-nav-icon">◉</span>
                    <span>Étudiants</span>
                    <c:if test="${uri.contains('/etudiants')}"><span class="sidebar-active-dot"></span></c:if>
                </a>
                <a href="${ctx}/bulletins"
                   class="${uri.contains('/bulletins') ? 'active' : ''}">
                    <span class="sidebar-nav-icon">▤</span>
                    <span>Bulletins</span>
                    <c:if test="${uri.contains('/bulletins')}"><span class="sidebar-active-dot"></span></c:if>
                </a>
            </c:when>

            <c:when test="${userRole == 'ETUDIANT'}">
                <a href="${ctx}/bulletins"
                   class="${uri.contains('/bulletins') ? 'active' : ''}">
                    <span class="sidebar-nav-icon">▤</span>
                    <span>Mon bulletin</span>
                    <c:if test="${uri.contains('/bulletins')}"><span class="sidebar-active-dot"></span></c:if>
                </a>
                <a href="${ctx}/statistiques"
                   class="${uri.contains('/statistiques') ? 'active' : ''}">
                    <span class="sidebar-nav-icon">◈</span>
                    <span>Mes statistiques</span>
                    <c:if test="${uri.contains('/statistiques')}"><span class="sidebar-active-dot"></span></c:if>
                </a>
            </c:when>
        </c:choose>
    </nav>

    <%-- User section --%>
    <div class="sidebar-user">
        <div class="sidebar-user-card">
            <div class="sidebar-avatar" style="background: ${roleColor};">
                <%-- First 2 initials of the name --%>
                ${fn:toUpperCase(fn:substring(userName, 0, 1))}
            </div>
            <div style="flex:1; min-width:0;">
                <div class="sidebar-user-name">${userName}</div>
                <div class="sidebar-user-role" style="color: ${roleColor};">${roleLabel}</div>
            </div>
        </div>
        <a href="${ctx}/logout" class="sidebar-logout">⎋&nbsp; Déconnexion</a>
    </div>
</aside>
