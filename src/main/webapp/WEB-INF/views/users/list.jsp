<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Utilisateurs - NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <!-- Include Sidebar -->
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <!-- Main Content -->
    <main class="main">
        <header class="page-header">
            <div class="flex-between">
                <div>
                    <h1>Utilisateurs</h1>
                    <p>Gestion des comptes utilisateurs</p>
                </div>
                <a href="${pageContext.request.contextPath}/users?action=add" class="btn btn-primary">
                    + Ajouter un utilisateur
                </a>
            </div>
        </header>

        <div class="page-content">
            <!-- Search Form -->
            <div class="card" style="margin-bottom: var(--space-8);">
                <form method="GET" action="${pageContext.request.contextPath}/users" class="flex gap-4">
                    <div style="flex: 1;">
                        <input
                            type="text"
                            name="search"
                            placeholder="Rechercher par login ou nom..."
                            value="${search != null ? search : ''}"
                            style="width: 100%; padding: var(--space-3) var(--space-4); border: 1px solid var(--color-border); border-radius: var(--radius-md);"
                        >
                    </div>
                    <button type="submit" class="btn btn-secondary">
                        Rechercher
                    </button>
                </form>
            </div>

            <c:if test="${error != null}">
                <div class="alert alert-danger" style="margin-bottom: var(--space-8);">
                    ${error}
                </div>
            </c:if>

            <div class="card">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Login</th>
                                <th>Nom complet</th>
                                <th>Rôle</th>
                                <th>Filière</th>
                                <th style="text-align: center;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${users != null && users.size() > 0}">
                                    <c:forEach var="user" items="${users}">
                                        <tr>
                                            <td class="numeric">${user.id}</td>
                                            <td><strong>${user.login}</strong></td>
                                            <td>${user.nom}</td>
                                            <td>
                                                <span class="badge ${user.role == 'CHEF_DEPT' ? 'badge-primary' : (user.role == 'ENSEIGNANT' ? 'badge-success' : 'badge-warning')}">
                                                    ${user.role}
                                                </span>
                                            </td>
                                            <td>${user.filiere != null ? user.filiere : '-'}</td>
                                            <td style="text-align: center;">
                                                <a href="${pageContext.request.contextPath}/users?action=edit&id=${user.id}" class="btn btn-sm btn-ghost">
                                                    Éditer
                                                </a>
                                                <a href="${pageContext.request.contextPath}/users?action=delete&id=${user.id}" class="btn btn-sm btn-danger" onclick="return confirm('Voulez-vous vraiment supprimer cet utilisateur ?');">
                                                    Supprimer
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" style="text-align: center; padding: var(--space-12); color: var(--color-text-secondary);">
                                            Aucun utilisateur trouvé
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <c:if test="${currentPage != null}">
                    <div class="pagination">
                        <c:if test="${currentPage > 1}">
                            <a href="${pageContext.request.contextPath}/users?page=1">Première</a>
                            <a href="${pageContext.request.contextPath}/users?page=${currentPage - 1}">Précédent</a>
                        </c:if>

                        <span class="active">${currentPage}</span>

                        <a href="${pageContext.request.contextPath}/users?page=${currentPage + 1}">Suivant</a>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</body>
</html>
