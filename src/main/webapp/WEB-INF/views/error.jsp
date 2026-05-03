<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Erreur - NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <!-- Include Sidebar (if user logged in) -->
    <c:if test="${sessionScope.user != null}">
        <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />
    </c:if>

    <!-- Main Content -->
    <main class="main">
        <!-- Page Header -->
        <header class="page-header">
            <h1>Erreur</h1>
        </header>

        <!-- Page Content -->
        <div class="page-content">
            <div class="card" style="max-width: 600px;">
                <div class="alert alert-danger">
                    <strong>Une erreur est survenue</strong>
                </div>

                <c:if test="${error != null}">
                    <p style="color: var(--color-text-secondary); margin-bottom: var(--space-6);">
                        ${error}
                    </p>
                </c:if>

                <div style="margin-top: var(--space-8);">
                    <a href="javascript:history.back()" class="btn btn-secondary">
                        Retour
                    </a>
                    <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">
                        Aller au dashboard
                    </a>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
