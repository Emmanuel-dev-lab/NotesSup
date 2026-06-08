<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Saisie des notes — NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .text-note-success { color: #059669; }
        .text-note-info { color: #0891b2; }
        .text-note-purple { color: #7c3aed; }
        .text-note-warning { color: #d97706; }
        .text-note-danger { color: #dc2626; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <main class="main">
        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Saisie des notes</h1>
                    <p class="subtitle">Gestion des notes des étudiants</p>
                </div>
                <div class="page-header-actions">
                    <a href="${pageContext.request.contextPath}/notes/grille" class="btn btn-ghost">Mode grille</a>
                    <a href="${pageContext.request.contextPath}/notes?action=add" class="btn btn-primary">+ Ajouter note</a>
                </div>
            </div>

            <c:if test="${error != null}"><div class="alert alert-danger">${error}</div></c:if>
            <c:if test="${success != null}"><div class="alert alert-success">${success}</div></c:if>

            <!-- Filtres -->
            <form method="GET" action="${pageContext.request.contextPath}/notes">
                <div class="toolbar">
                    <div class="search-bar">
                        <span class="search-bar-icon">⌕</span>
                        <input type="text" id="noteSearchInput"
                               placeholder="Rechercher par nom ou matricule..."
                               oninput="filterNoteRows(this.value)">
                    </div>
                    <select name="filiere">
                        <option value="">Toutes les filières</option>
                        <c:forEach var="f" items="${filieres}">
                            <option value="${f}" ${selectedFiliere == f ? 'selected' : ''}>${f}</option>
                        </c:forEach>
                    </select>
                    <select name="session">
                        <option value="">Toutes les sessions</option>
                        <option value="NORMALE" ${selectedSession == 'NORMALE' ? 'selected' : ''}>Normale</option>
                        <option value="RATTRAPAGE" ${selectedSession == 'RATTRAPAGE' ? 'selected' : ''}>Rattrapage</option>
                    </select>
                    <select name="matiere">
                        <option value="">Toutes les matières</option>
                        <c:forEach var="m" items="${matieres}">
                            <option value="${m.id}" ${selectedMatiere == m.id ? 'selected' : ''}>${m.intitule}</option>
                        </c:forEach>
                    </select>
                    <button type="submit" class="btn btn-ghost">Filtrer</button>
                </div>
            </form>

            <!-- Table -->
            <div class="card" style="padding:0; overflow:hidden;">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Étudiant</th>
                                <th>Matricule</th>
                                <th>Matière</th>
                                <th>CC</th>
                                <th>Examen</th>
                                <th>Finale</th>
                                <th>Mention</th>
                                <th>Saisi par</th>
                                <th style="width:80px;"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${notes != null && notes.size() > 0}">
                                    <c:forEach var="note" items="${notes}">
                                        <tr>
                                            <td class="td-bold">${note.etudiant.nom} ${note.etudiant.prenom}</td>
                                            <td class="td-mono" style="color:var(--accent-blue); font-size:12px;">${note.etudiant.matricule}</td>
                                            <td>${note.matiere.intitule}</td>
                                            <td class="td-mono">${note.noteCC != null ? note.noteCC : '?'}</td>
                                            <td class="td-mono">${note.noteExam != null ? note.noteExam : '—'}</td>
                                            <c:set var="textClass" value=""/>
                                            <c:if test="${note.noteFinale != null}">
                                                <c:choose>
                                                    <c:when test="${note.noteFinale >= 16}"><c:set var="textClass" value="text-note-success"/></c:when>
                                                    <c:when test="${note.noteFinale >= 14}"><c:set var="textClass" value="text-note-info"/></c:when>
                                                    <c:when test="${note.noteFinale >= 12}"><c:set var="textClass" value="text-note-purple"/></c:when>
                                                    <c:when test="${note.noteFinale >= 10}"><c:set var="textClass" value="text-note-warning"/></c:when>
                                                    <c:otherwise><c:set var="textClass" value="text-note-danger"/></c:otherwise>
                                                </c:choose>
                                            </c:if>
                                            <td class="td-mono ${textClass}" style="font-weight:700;">
                                                <c:if test="${note.noteFinale != null}">
                                                    <fmt:formatNumber value="${note.noteFinale}" maxFractionDigits="2"/>
                                                </c:if>
                                                <c:if test="${note.noteFinale == null}">—</c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${note.noteFinale >= 16}"><span class="badge badge-success">Très Bien</span></c:when>
                                                    <c:when test="${note.noteFinale >= 14}"><span class="badge badge-info">Bien</span></c:when>
                                                    <c:when test="${note.noteFinale >= 12}"><span class="badge badge-purple">Assez Bien</span></c:when>
                                                    <c:when test="${note.noteFinale >= 10}"><span class="badge badge-warning">Passable</span></c:when>
                                                    <c:when test="${note.noteFinale != null}"><span class="badge badge-danger">Ajourné</span></c:when>
                                                    <c:otherwise><span style="color:var(--text-muted);">—</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="font-size:12px; color:var(--text-muted);">${note.saisiePar}</td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/notes?action=edit&id=${note.id}"
                                                   class="btn btn-sm btn-ghost">✎</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="9" style="text-align:center; padding:40px; color:var(--text-muted);">
                                            Aucune note enregistrée
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            <c:if test="${totalPages > 1}">
                <div class="pagination">
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <c:choose>
                            <c:when test="${p == currentPage}">
                                <span class="page-link active">${p}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="?page=${p}&etudiant=${etudiant}&matiere=${matiere}" class="page-link">${p}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                </div>
            </c:if>
        </div>
    </main>
</body>
</html>
