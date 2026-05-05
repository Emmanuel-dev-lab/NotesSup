<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nouvelle délibération — NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <main class="main">
        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Nouvelle délibération</h1>
                    <p class="subtitle">Lancer une session de délibération pour une filière</p>
                </div>
                <div class="page-header-actions">
                    <a href="${pageContext.request.contextPath}/deliberations" class="btn btn-ghost">← Retour</a>
                </div>
            </div>

            <div class="card" style="max-width: 500px;">
                <c:if test="${error != null}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <form method="POST" action="${pageContext.request.contextPath}/deliberations">
                    <input type="hidden" name="action" value="create">
                    
                    <div class="form-group">
                        <label for="filiere">Filière *</label>
                        <select id="filiere" name="filiere" required>
                            <option value="">— Sélectionner —</option>
                            <c:forEach var="f" items="${filieres}">
                                <option value="${f}">${f}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="session">Session *</label>
                        <select id="session" name="session" required>
                            <option value="NORMALE">Session Normale</option>
                            <option value="RATTRAPAGE">Session Rattrapage</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="anneeAcademique">Année Académique *</label>
                        <input type="text" id="anneeAcademique" name="anneeAcademique" 
                               placeholder="Ex: 2025-2026" 
                               value="2025-2026" required>
                    </div>

                    <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:24px;">
                        <a href="${pageContext.request.contextPath}/deliberations" class="btn btn-ghost">Annuler</a>
                        <button type="submit" class="btn btn-primary">
                            Lancer la délibération
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</body>
</html>
