<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Étudiants — NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <main class="main">
        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Étudiants</h1>
                    <p class="subtitle">Gestion des informations étudiants</p>
                </div>
                <div class="page-header-actions">
                    <a href="${pageContext.request.contextPath}/etudiants?export=csv" class="btn btn-ghost">
                        ↓ Export CSV
                    </a>
                    <c:if test="${sessionScope.user.role == 'CHEF_DEPT'}">
                        <a href="${pageContext.request.contextPath}/etudiants?action=add" class="btn btn-primary">
                            + Ajouter
                        </a>
                    </c:if>
                </div>
            </div>

            <c:if test="${error != null}">
                <div class="alert alert-danger">${error}</div>
            </c:if>
            <c:if test="${success != null}">
                <div class="alert alert-success">${success}</div>
            </c:if>

            <!-- Toolbar -->
            <form method="GET" action="${pageContext.request.contextPath}/etudiants">
                <div class="toolbar">
                    <div class="search-bar">
                        <span class="search-bar-icon">⌕</span>
                        <input type="text" name="search"
                               placeholder="Rechercher par matricule ou nom..."
                               value="${search != null ? search : ''}">
                    </div>
                    <select name="filiere">
                        <option value="">Toutes les filières</option>
                        <c:forEach var="f" items="${filieres}">
                            <option value="${f}" ${selectedFiliere == f ? 'selected' : ''}>${f}</option>
                        </c:forEach>
                    </select>
                    <button type="submit" class="btn btn-ghost">Rechercher</button>
                </div>
            </form>

            <!-- Table -->
            <div class="card" style="padding: 0; overflow: hidden;">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Matricule</th>
                                <th>Nom &amp; Prénom</th>
                                <th>Filière</th>
                                <th>Année</th>
                                <th>Téléphone</th>
                                <c:if test="${sessionScope.user.role == 'CHEF_DEPT'}">
                                    <th style="width:100px;"></th>
                                </c:if>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${etudiants != null && etudiants.size() > 0}">
                                    <c:forEach var="e" items="${etudiants}">
                                        <tr>
                                            <td class="td-mono" style="color:var(--accent-blue); font-weight:500;">${e.matricule}</td>
                                            <td class="td-bold">${e.nom} ${e.prenom}</td>
                                            <td><span class="badge badge-info">${e.filiere}</span></td>
                                            <td class="td-mono">L${e.annee}</td>
                                            <td class="td-mono">${e.telephone != null ? e.telephone : '—'}</td>
                                            <c:if test="${sessionScope.user.role == 'CHEF_DEPT'}">
                                                <td>
                                                    <div style="display:flex; gap:6px;">
                                                        <a href="${pageContext.request.contextPath}/etudiants?action=edit&id=${e.id}"
                                                           class="btn btn-sm btn-ghost" title="Modifier">✎</a>
                                                        <a href="${pageContext.request.contextPath}/etudiants?action=delete&id=${e.id}"
                                                           class="btn btn-sm btn-danger"
                                                           title="Supprimer"
                                                           onclick="return confirm('Supprimer ${e.prenom} ${e.nom} ?');">✕</a>
                                                    </div>
                                                </td>
                                            </c:if>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" style="text-align:center; padding:40px; color:var(--text-muted);">
                                            Aucun étudiant trouvé
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <c:if test="${currentPage != null}">
                    <div style="padding: 14px 20px; border-top: 1px solid var(--border-light);">
                        <div class="pagination">
                            <span class="pagination-info">
                                ${(currentPage-1)*pageSize+1}–${currentPage*pageSize} sur ${totalCount}
                            </span>
                            <c:if test="${currentPage > 1}">
                                <a href="${pageContext.request.contextPath}/etudiants?page=${currentPage-1}&search=${search}">←</a>
                            </c:if>
                            <c:forEach begin="1" end="${totalPages}" var="p">
                                <c:choose>
                                    <c:when test="${p == currentPage}">
                                        <span class="active">${p}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/etudiants?page=${p}&search=${search}">${p}</a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                            <c:if test="${currentPage < totalPages}">
                                <a href="${pageContext.request.contextPath}/etudiants?page=${currentPage+1}&search=${search}">→</a>
                            </c:if>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</body>
</html>
