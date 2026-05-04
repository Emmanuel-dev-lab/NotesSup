<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Utilisateurs — NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <main class="main">
        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Utilisateurs</h1>
                    <p class="subtitle">Gestion des comptes utilisateurs du système</p>
                </div>
                <div class="page-header-actions">
                    <a href="${pageContext.request.contextPath}/users?action=add" class="btn btn-primary">
                        + Ajouter utilisateur
                    </a>
                </div>
            </div>

            <c:if test="${error != null}"><div class="alert alert-danger">${error}</div></c:if>
            <c:if test="${success != null}"><div class="alert alert-success">${success}</div></c:if>

            <!-- Search toolbar -->
            <form method="GET" action="${pageContext.request.contextPath}/users">
                <div class="toolbar">
                    <div class="search-bar">
                        <span class="search-bar-icon">⌕</span>
                        <input type="text" name="search"
                               placeholder="Rechercher par login ou nom..."
                               value="${search != null ? search : ''}">
                    </div>
                    <select name="role">
                        <option value="">Tous les rôles</option>
                        <option value="CHEF_DEPT" ${selectedRole == 'CHEF_DEPT' ? 'selected' : ''}>Chef de département</option>
                        <option value="ENSEIGNANT" ${selectedRole == 'ENSEIGNANT' ? 'selected' : ''}>Enseignant</option>
                        <option value="ETUDIANT" ${selectedRole == 'ETUDIANT' ? 'selected' : ''}>Étudiant</option>
                    </select>
                    <button type="submit" class="btn btn-ghost">Rechercher</button>
                </div>
            </form>

            <!-- Table -->
            <div class="card" style="padding:0; overflow:hidden;">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Login</th>
                                <th>Nom complet</th>
                                <th>Rôle</th>
                                <th>Filière</th>
                                <th style="width:100px;"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${users != null && users.size() > 0}">
                                    <c:forEach var="user" items="${users}">
                                        <tr>
                                            <td class="td-mono" style="font-weight:600; color:var(--accent-blue);">${user.login}</td>
                                            <td class="td-bold">${user.nom}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${user.role == 'CHEF_DEPT'}">
                                                        <span class="badge badge-danger">Chef de département</span>
                                                    </c:when>
                                                    <c:when test="${user.role == 'ENSEIGNANT'}">
                                                        <span class="badge badge-info">Enseignant</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-success">Étudiant</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${user.filiere != null ? user.filiere : '—'}</td>
                                            <td>
                                                <div style="display:flex; gap:6px;">
                                                    <a href="${pageContext.request.contextPath}/users?action=edit&id=${user.id}"
                                                       class="btn btn-sm btn-ghost" title="Modifier">✎</a>
                                                    <a href="${pageContext.request.contextPath}/users?action=delete&id=${user.id}"
                                                       class="btn btn-sm btn-danger"
                                                       title="Supprimer"
                                                       onclick="return confirm('Supprimer l\'utilisateur ${user.login} ?');">✕</a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="5" style="text-align:center; padding:40px; color:var(--text-muted);">Aucun utilisateur trouvé</td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <c:if test="${currentPage != null}">
                    <div style="padding:14px 20px; border-top:1px solid var(--border-light);">
                        <div class="pagination">
                            <c:if test="${currentPage > 1}">
                                <a href="${pageContext.request.contextPath}/users?page=${currentPage-1}&search=${search}">←</a>
                            </c:if>
                            <c:forEach begin="1" end="${totalPages}" var="p">
                                <c:choose>
                                    <c:when test="${p == currentPage}"><span class="active">${p}</span></c:when>
                                    <c:otherwise><a href="${pageContext.request.contextPath}/users?page=${p}&search=${search}">${p}</a></c:otherwise>
                                </c:choose>
                            </c:forEach>
                            <c:if test="${currentPage < totalPages}">
                                <a href="${pageContext.request.contextPath}/users?page=${currentPage+1}&search=${search}">→</a>
                            </c:if>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</body>
</html>
