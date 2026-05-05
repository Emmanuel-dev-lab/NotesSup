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
                                    <label for="etudiant">Étudiant *</label>
                                    <select id="etudiant" name="etudiant_id" required>
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
                                        value="${note != null ? note.anneeAcademique : '2023-2024'}"
                                        placeholder="2023-2024" required>
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
            </body>

            </html>