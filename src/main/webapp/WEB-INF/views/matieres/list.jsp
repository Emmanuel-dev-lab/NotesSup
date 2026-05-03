<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Matières - NotesSup</title>
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
                    <h1>Matières</h1>
                    <p>Gestion des matières par filière</p>
                </div>
                <a href="${pageContext.request.contextPath}/matieres?action=add" class="btn btn-primary">
                    + Ajouter matière
                </a>
            </div>
        </header>

        <!-- Page Content -->
        <div class="page-content">
            <c:if test="${error != null}">
                <div class="alert alert-danger" style="margin-bottom: var(--space-8);">
                    ${error}
                </div>
            </c:if>

            <c:if test="${success != null}">
                <div class="alert alert-success" style="margin-bottom: var(--space-8);">
                    ${success}
                </div>
            </c:if>

            <!-- Matieres Cards by Filière -->
            <div class="grid-3">
                <c:choose>
                    <c:when test="${matieres != null && matieres.size() > 0}">
                        <c:forEach var="matiere" items="${matieres}">
                            <div class="card">
                                <div class="card-header">
                                    <h3>${matiere.intitule}</h3>
                                </div>
                                <div class="card-body">
                                    <p><strong>Code:</strong> ${matiere.code}</p>
                                    <p><strong>Coefficient:</strong> <span class="badge badge-primary">${matiere.coefficient}</span></p>
                                    <p><strong>Enseignant:</strong> ${matiere.enseignant != null ? matiere.enseignant : 'Non assigné'}</p>
                                    <p><strong>Semestre:</strong> ${matiere.semestre}</p>
                                    <p><strong>Filière:</strong> ${matiere.filiere}</p>
                                </div>
                                <div class="card-footer">
                                    <a href="${pageContext.request.contextPath}/matieres?action=edit&id=${matiere.id}" class="btn btn-sm btn-ghost">
                                        Éditer
                                    </a>
                                    <a href="${pageContext.request.contextPath}/matieres?action=delete&id=${matiere.id}" class="btn btn-sm btn-danger" onclick="return confirm('Êtes-vous sûr?');">
                                        Supprimer
                                    </a>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div style="grid-column: 1 / -1; text-align: center; padding: var(--space-12); color: var(--color-text-secondary);">
                            <p>Aucune matière enregistrée</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</body>
</html>
