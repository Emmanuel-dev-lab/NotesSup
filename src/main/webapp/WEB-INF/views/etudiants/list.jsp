<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Étudiants - NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <!-- Include Sidebar -->
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <!-- Main Content -->
    <main class="main">
        <!-- Page Header -->
        <header class="page-header">
            <div class="flex-between">
                <div>
                    <h1>Étudiants</h1>
                    <p>Gestion des informations des étudiants</p>
                </div>
                <a href="${pageContext.request.contextPath}/etudiants?action=add" class="btn btn-primary">
                    + Ajouter étudiant
                </a>
            </div>
        </header>

        <!-- Page Content -->
        <div class="page-content">
            <!-- Search Form -->
            <div class="card" style="margin-bottom: var(--space-8);">
                <form method="GET" action="${pageContext.request.contextPath}/etudiants" class="flex gap-4">
                    <div style="flex: 1;">
                        <input
                            type="text"
                            name="search"
                            placeholder="Rechercher par matricule ou nom..."
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

            <!-- Table -->
            <div class="card">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Matricule</th>
                                <th>Nom</th>
                                <th>Prénom</th>
                                <th>Filière</th>
                                <th>Année</th>
                                <th>Téléphone</th>
                                <th style="text-align: center;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${etudiants != null && etudiants.size() > 0}">
                                    <c:forEach var="etudiant" items="${etudiants}">
                                        <tr>
                                            <td class="numeric">${etudiant.matricule}</td>
                                            <td>${etudiant.nom}</td>
                                            <td>${etudiant.prenom}</td>
                                            <td>${etudiant.filiere}</td>
                                            <td class="numeric">${etudiant.annee}</td>
                                            <td>${etudiant.telephone != null ? etudiant.telephone : '-'}</td>
                                            <td style="text-align: center;">
                                                <a href="${pageContext.request.contextPath}/etudiants?action=edit&id=${etudiant.id}" class="btn btn-sm btn-ghost">
                                                    Éditer
                                                </a>
                                                <a href="${pageContext.request.contextPath}/etudiants?action=delete&id=${etudiant.id}" class="btn btn-sm btn-danger" onclick="return confirm('Êtes-vous sûr?');">
                                                    Supprimer
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" style="text-align: center; padding: var(--space-12); color: var(--color-text-secondary);">
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
                    <div class="pagination">
                        <c:if test="${currentPage > 1}">
                            <a href="${pageContext.request.contextPath}/etudiants?page=1">Première</a>
                            <a href="${pageContext.request.contextPath}/etudiants?page=${currentPage - 1}">Précédent</a>
                        </c:if>

                        <span class="active">${currentPage}</span>

                        <a href="${pageContext.request.contextPath}/etudiants?page=${currentPage + 1}">Suivant</a>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</body>
</html>
