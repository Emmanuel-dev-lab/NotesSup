<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="fr">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>${note != null ? 'Éditer' : 'Ajouter'} note - NotesSup</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
                <style>
                    .search-select-wrapper { position: relative; }
                    .search-select-input {
                        width: 100%;
                        padding: 10px 12px;
                        border: 1.5px solid var(--border-medium, #d1d5db);
                        border-radius: 8px;
                        font-size: 14px;
                        font-family: inherit;
                        background: white;
                        transition: border-color 0.2s;
                        box-sizing: border-box;
                    }
                    .search-select-input:focus {
                        outline: none;
                        border-color: var(--accent-blue, #3b82f6);
                        box-shadow: 0 0 0 3px rgba(59,130,246,0.12);
                    }
                    .search-select-dropdown {
                        position: absolute;
                        top: 100%;
                        left: 0;
                        right: 0;
                        max-height: 220px;
                        overflow-y: auto;
                        background: white;
                        border: 1.5px solid var(--border-medium, #d1d5db);
                        border-top: none;
                        border-radius: 0 0 8px 8px;
                        box-shadow: 0 8px 24px rgba(0,0,0,0.12);
                        z-index: 100;
                        display: none;
                    }
                    .search-select-dropdown.open { display: block; }
                    .search-select-option {
                        padding: 10px 14px;
                        cursor: pointer;
                        font-size: 14px;
                        border-bottom: 1px solid var(--border-light, #f0f0f0);
                        transition: background 0.15s;
                    }
                    .search-select-option:hover,
                    .search-select-option.highlighted {
                        background: var(--bg-row-alt, #f8fafc);
                    }
                    .search-select-option .matricule {
                        font-family: var(--font-mono, monospace);
                        font-size: 12px;
                        color: var(--accent-blue, #3b82f6);
                        margin-left: 6px;
                    }
                    .search-select-option .no-results {
                        color: var(--text-muted, #9ca3af);
                        font-style: italic;
                    }
                </style>
            </head>

            <body>
                <!-- Include Sidebar -->
                <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

                <!-- Main Content -->
                <main class="main">
                    <div class="page-content">
                        <div class="page-header">
                            <div>
                                <h1>${note != null ? 'Modifier la note' : 'Ajouter une note'}</h1>
                                <p class="subtitle">Saisir les notes de contrôle et d'examen</p>
                            </div>
                            <div class="page-header-actions">
                                <a href="${pageContext.request.contextPath}/notes" class="btn btn-ghost">← Retour</a>
                            </div>
                        </div>

                        <div class="card" style="max-width: 620px;">
                            <c:if test="${error != null}">
                                <div class="alert alert-danger" style="margin-bottom: var(--space-6);">
                                    ${error}
                                </div>
                            </c:if>

                            <form method="POST" action="${pageContext.request.contextPath}/notes">
                                <input type="hidden" name="action" value="${note != null ? 'update' : 'create'}">
                                <c:if test="${note != null}">
                                    <input type="hidden" name="id" value="${note.id}">
                                </c:if>

                                <div class="form-group">
                                    <label for="etudiantSearch">Étudiant *</label>
                                    <div class="search-select-wrapper">
                                        <input type="text" id="etudiantSearch" class="search-select-input"
                                            placeholder="Rechercher par nom ou matricule..."
                                            autocomplete="off">
                                        <div id="etudiantDropdown" class="search-select-dropdown"></div>
                                    </div>
                                    <select id="etudiant" name="etudiant_id" required style="display:none;">
                                        <option value="">-- Sélectionner --</option>
                                        <c:forEach var="etudiant" items="${etudiants}">
                                            <option value="${etudiant.id}" ${note !=null && note.etudiantId==etudiant.id
                                                ? 'selected' : '' }>
                                                ${etudiant.nom} ${etudiant.prenom} (${etudiant.matricule})
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label for="matiere">Matière *</label>
                                    <select id="matiere" name="matiere_id" required>
                                        <option value="">-- Sélectionner --</option>
                                        <c:forEach var="matiere" items="${matieres}">
                                            <option value="${matiere.id}" ${note !=null && note.matiereId==matiere.id
                                                ? 'selected' : '' }>
                                                ${matiere.intitule} (${matiere.code})
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="form-grid">
                                    <div class="form-group">
                                        <label for="noteCC">Note CC (0-20) *</label>
                                        <input type="number" id="noteCC" name="note_cc"
                                            value="${note != null && note.noteCC != null ? note.noteCC : ''}" min="0"
                                            max="20" step="0.5" required>
                                    </div>

                                    <div class="form-group">
                                        <label for="noteExam">Note Examen (0-20) *</label>
                                        <input type="number" id="noteExam" name="note_exam"
                                            value="${note != null && note.noteExam != null ? note.noteExam : ''}"
                                            min="0" max="20" step="0.5" required>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="session">Session *</label>
                                    <select id="session" name="session" required>
                                        <option value="NORMALE" ${note !=null && note.session=='NORMALE' ? 'selected'
                                            : '' }>
                                            Session Normale
                                        </option>
                                        <option value="RATTRAPAGE" ${note !=null && note.session=='RATTRAPAGE'
                                            ? 'selected' : '' }>
                                            Session Rattrapage
                                        </option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label for="annee">Année Académique *</label>
                                    <input type="text" id="annee" name="annee_academique"
                                        value="${note != null ? note.anneeAcademique : '2025-2026'}"
                                        placeholder="2025-2026" required>
                                </div>

                                <c:if test="${note != null && note.noteFinale != null}">
                                    <div class="alert alert-info">
                                        <strong>Note finale calculée:</strong>
                                        <fmt:formatNumber value="${note.noteFinale}" maxFractionDigits="2" />
                                    </div>
                                </c:if>

                                <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:8px;">
                                    <a href="${pageContext.request.contextPath}/notes" class="btn btn-ghost">Annuler</a>
                                    <button type="submit" class="btn btn-primary">
                                        ${note != null ? 'Mettre à jour' : 'Enregistrer la note'}
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </main>

                <script>
                (function() {
                    const select = document.getElementById('etudiant');
                    const searchInput = document.getElementById('etudiantSearch');
                    const dropdown = document.getElementById('etudiantDropdown');

                    // Build student data from hidden select options
                    const students = [];
                    for (let i = 1; i < select.options.length; i++) {
                        const opt = select.options[i];
                        students.push({
                            id: opt.value,
                            label: opt.textContent.trim(),
                            selected: opt.selected
                        });
                    }

                    // If editing, pre-fill the search input
                    const selectedOpt = select.options[select.selectedIndex];
                    if (selectedOpt && selectedOpt.value) {
                        searchInput.value = selectedOpt.textContent.trim();
                    }

                    function renderDropdown(filter) {
                        const query = (filter || '').toLowerCase();
                        const filtered = query
                            ? students.filter(s => s.label.toLowerCase().includes(query))
                            : students;

                        dropdown.innerHTML = '';
                        if (filtered.length === 0) {
                            dropdown.innerHTML = '<div class="search-select-option"><span class="no-results">Aucun résultat</span></div>';
                        } else {
                            filtered.forEach(s => {
                                const div = document.createElement('div');
                                div.className = 'search-select-option';
                                // Parse out the matricule
                                const match = s.label.match(/^(.+?)\s*\((.+)\)$/);
                                if (match) {
                                    div.innerHTML = match[1] + '<span class="matricule">(' + match[2] + ')</span>';
                                } else {
                                    div.textContent = s.label;
                                }
                                div.addEventListener('mousedown', function(e) {
                                    e.preventDefault();
                                    select.value = s.id;
                                    searchInput.value = s.label;
                                    dropdown.classList.remove('open');
                                });
                                dropdown.appendChild(div);
                            });
                        }
                        dropdown.classList.add('open');
                    }

                    searchInput.addEventListener('focus', function() {
                        renderDropdown(this.value);
                    });

                    searchInput.addEventListener('input', function() {
                        renderDropdown(this.value);
                        // Clear selection if text doesn't match
                        const match = students.find(s => s.label.toLowerCase() === this.value.toLowerCase());
                        if (!match) {
                            select.value = '';
                        }
                    });

                    searchInput.addEventListener('blur', function() {
                        setTimeout(() => dropdown.classList.remove('open'), 200);
                    });

                    // Close dropdown on outside click
                    document.addEventListener('click', function(e) {
                        if (!searchInput.contains(e.target) && !dropdown.contains(e.target)) {
                            dropdown.classList.remove('open');
                        }
                    });
                })();
                </script>
            </body>

            </html>