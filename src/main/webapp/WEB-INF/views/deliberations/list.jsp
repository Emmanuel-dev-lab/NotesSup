<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Délibérations - NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <!-- Include Sidebar -->
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <!-- Main Content -->
    <main class="main">
        <!-- Page Header -->
        <header class="page-header">
            <div>
                <h1>Délibérations</h1>
                <p>Gestion des sessions de délibérations</p>
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

            <!-- Deliberations Cards -->
            <div class="grid-3">
                <c:choose>
                    <c:when test="${deliberations != null && deliberations.size() > 0}">
                        <c:forEach var="delib" items="${deliberations}">
                            <div class="card">
                                <div class="card-header">
                                    <h3>${delib.filiere}</h3>
                                </div>
                                <div class="card-body">
                                    <p><strong>Année académique:</strong> ${delib.anneeAcademique}</p>
                                    <p><strong>Session:</strong> ${delib.session}</p>
                                    <c:if test="${delib.publiee}">
                                        <p>
                                            <strong>Publiée le:</strong>
                                            <fmt:formatDate value="${delib.datePublication}" pattern="dd/MM/yyyy" />
                                        </p>
                                    </c:if>
                                    <div style="margin-top: var(--space-4);">
                                        <span class="badge ${delib.publiee ? 'badge-success' : 'badge-warning'}">
                                            ${delib.publiee ? 'Publiée' : 'Non publiée'}
                                        </span>
                                    </div>
                                </div>
                                <div class="card-footer">
                                    <c:if test="${!delib.publiee}">
                                        <form method="POST" action="${pageContext.request.contextPath}/deliberations" style="display: inline;">
                                            <input type="hidden" name="action" value="publish">
                                            <input type="hidden" name="id" value="${delib.id}">
                                            <button type="submit" class="btn btn-sm btn-success">
                                                Publier
                                            </button>
                                        </form>
                                    </c:if>
                                    <a href="${pageContext.request.contextPath}/deliberations?action=pv&id=${delib.id}" class="btn btn-sm btn-ghost">
                                        Voir PV
                                    </a>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div style="grid-column: 1 / -1; text-align: center; padding: var(--space-12); color: var(--color-text-secondary);">
                            <p>Aucune délibération enregistrée</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</body>
</html>
