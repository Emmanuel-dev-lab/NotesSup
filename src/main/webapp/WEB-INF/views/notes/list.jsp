<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notes - NotesSup</title>
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
                    <h1>Notes</h1>
                    <p>Gestion des notes des étudiants</p>
                </div>
                <a href="${pageContext.request.contextPath}/notes?action=add" class="btn btn-primary">
                    + Ajouter note
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

            <!-- Filters -->
            <div class="card" style="margin-bottom: var(--space-8);">
                <form method="GET" action="${pageContext.request.contextPath}/notes" class="flex gap-4">
                    <div style="flex: 1;">
                        <select name="etudiant" style="width: 100%; padding: var(--space-3) var(--space-4); border: 1px solid var(--color-border); border-radius: var(--radius-md);">
                            <option value="">-- Filtrer par étudiant --</option>
                            <c:forEach var="etudiant" items="${etudiants}">
                                <option value="${etudiant.id}" ${param.etudiant == etudiant.id ? 'selected' : ''}>
                                    ${etudiant.nom} ${etudiant.prenom}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-secondary">
                        Filtrer
                    </button>
                </form>
            </div>

            <!-- Table -->
            <div class="card">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Étudiant</th>
                                <th>Matricule</th>
                                <th>Matière</th>
                                <th class="numeric">Note CC</th>
                                <th class="numeric">Note Examen</th>
                                <th class="numeric">Note Finale</th>
                                <th>Mention</th>
                                <th style="text-align: center;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${notes != null && notes.size() > 0}">
                                    <c:forEach var="note" items="${notes}">
                                        <tr>
                                            <td>${note.etudiantNom}</td>
                                            <td class="numeric">${note.matricule}</td>
                                            <td>${note.matiereIntitule}</td>
                                            <td class="numeric">${note.noteCC != null ? note.noteCC : '-'}</td>
                                            <td class="numeric">${note.noteExam != null ? note.noteExam : '-'}</td>
                                            <td class="numeric">
                                                <strong>
                                                    <fmt:formatNumber value="${note.noteFinale}" maxFractionDigits="2" />
                                                </strong>
                                            </td>
                                            <td>
                                                <c:if test="${note.mention != null}">
                                                    <span class="badge badge-success">${note.mention}</span>
                                                </c:if>
                                            </td>
                                            <td style="text-align: center;">
                                                <a href="${pageContext.request.contextPath}/notes?action=edit&id=${note.id}" class="btn btn-sm btn-ghost">
                                                    Éditer
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="8" style="text-align: center; padding: var(--space-12); color: var(--color-text-secondary);">
                                            Aucune note enregistrée
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
