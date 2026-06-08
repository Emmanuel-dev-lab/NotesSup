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
    <style>
        .search-filter-bar {
            display: flex;
            gap: 12px;
            align-items: center;
            margin-bottom: 16px;
        }
        .search-filter-bar .search-input {
            flex: 1;
            padding: 10px 14px;
            border: 1.5px solid var(--border-medium, #d1d5db);
            border-radius: 8px;
            font-size: 14px;
            font-family: inherit;
            background: white;
            transition: border-color 0.2s;
        }
        .search-filter-bar .search-input:focus {
            outline: none;
            border-color: var(--accent-blue, #3b82f6);
            box-shadow: 0 0 0 3px rgba(59,130,246,0.12);
        }
        tr.hidden-row { display: none; }
        .search-count {
            font-size: 13px;
            color: var(--text-muted, #9ca3af);
            margin-left: auto;
            white-space: nowrap;
        }
    </style>
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

            <!-- Search Bar -->
            <div class="card" style="margin-bottom: var(--space-8);">
                <div class="search-filter-bar">
                    <span style="font-size: 16px;">⌕</span>
                    <input type="text" id="grilleSearch" class="search-input"
                           placeholder="Rechercher par nom ou matricule...">
                    <span id="searchCount" class="search-count"></span>
                </div>
            </div>

            <!-- Notes Matrix Table -->
            <div class="card">
                <div class="table-container">
                    <table id="grilleTable">
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
                                        <tr data-nom="${etudiant.nom} ${etudiant.prenom}" data-matricule="${etudiant.matricule}">
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

    <script>
    (function() {
        const searchInput = document.getElementById('grilleSearch');
        const table = document.getElementById('grilleTable');
        const countSpan = document.getElementById('searchCount');
        const rows = table ? table.querySelectorAll('tbody tr[data-nom]') : [];

        function filterRows() {
            const query = searchInput.value.toLowerCase().trim();
            let visible = 0;
            rows.forEach(row => {
                const nom = (row.getAttribute('data-nom') || '').toLowerCase();
                const matricule = (row.getAttribute('data-matricule') || '').toLowerCase();
                if (!query || nom.includes(query) || matricule.includes(query)) {
                    row.classList.remove('hidden-row');
                    visible++;
                } else {
                    row.classList.add('hidden-row');
                }
            });
            if (query) {
                countSpan.textContent = visible + ' / ' + rows.length + ' étudiants';
            } else {
                countSpan.textContent = rows.length + ' étudiants';
            }
        }

        if (searchInput) {
            searchInput.addEventListener('input', filterRows);
            filterRows(); // initial count
        }
    })();
    </script>
</body>
</html>
