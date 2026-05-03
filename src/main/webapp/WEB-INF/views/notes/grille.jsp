<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Grille des Notes - NotesSup</title>
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
                <h1>Grille des Notes</h1>
                <p>Vue matricielle Étudiants × Matières</p>
            </div>
        </header>

        <!-- Page Content -->
        <div class="page-content">
            <c:if test="${error != null}">
                <div class="alert alert-danger" style="margin-bottom: var(--space-8);">
                    ${error}
                </div>
            </c:if>

            <!-- Filters -->
            <div class="card" style="margin-bottom: var(--space-8);">
                <form method="GET" action="${pageContext.request.contextPath}/notes?action=grille" class="flex gap-4">
                    <div style="flex: 1;">
                        <select name="filiere" style="width: 100%; padding: var(--space-3) var(--space-4); border: 1px solid var(--color-border); border-radius: var(--radius-md);">
                            <option value="">-- Filtrer par filière --</option>
                            <option value="Informatique" ${param.filiere == 'Informatique' ? 'selected' : ''}>
                                Informatique
                            </option>
                            <option value="Gestion" ${param.filiere == 'Gestion' ? 'selected' : ''}>
                                Gestion
                            </option>
                            <option value="Génie Civil" ${param.filiere == 'Génie Civil' ? 'selected' : ''}>
                                Génie Civil
                            </option>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-secondary">
                        Filtrer
                    </button>
                </form>
            </div>

            <!-- Notes Matrix Table -->
            <div class="card">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Étudiant</th>
                                <th>Matricule</th>
                                <c:forEach var="matiere" items="${matieres}">
                                    <th class="numeric" title="${matiere.intitule}">${matiere.code}</th>
                                </c:forEach>
                                <th class="numeric">Moyenne</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${etudiants != null && etudiants.size() > 0}">
                                    <c:forEach var="etudiant" items="${etudiants}">
                                        <tr>
                                            <td>${etudiant.nom} ${etudiant.prenom}</td>
                                            <td class="numeric">${etudiant.matricule}</td>
                                            <c:forEach var="matiere" items="${matieres}">
                                                <c:set var="noteValue" value=""/>
                                                <c:forEach var="note" items="${notes}">
                                                    <c:if test="${note.etudiantId == etudiant.id && note.matiereId == matiere.id}">
                                                        <c:set var="noteValue" value="${note.noteFinale}"/>
                                                    </c:if>
                                                </c:forEach>
                                                <td class="numeric">
                                                    <c:choose>
                                                        <c:when test="${noteValue != ''}">
                                                            <fmt:formatNumber value="${noteValue}" maxFractionDigits="2" />
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color: var(--color-text-muted);">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </c:forEach>
                                            <td class="numeric">
                                                <strong>${etudiantMoyenne[etudiant.id] != null ? etudiantMoyenne[etudiant.id] : '-'}</strong>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="4" style="text-align: center; padding: var(--space-12); color: var(--color-text-secondary);">
                                            Aucun étudiant ou matière trouvée
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
