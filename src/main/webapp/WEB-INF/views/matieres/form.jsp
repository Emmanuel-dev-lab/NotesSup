<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${matiere != null ? 'Éditer' : 'Ajouter'} matière - NotesSup</title>
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
                    <h1>${matiere != null ? 'Modifier la matière' : 'Ajouter une matière'}</h1>
                    <p class="subtitle">${matiere != null ? matiere.intitule : 'Enregistrer une nouvelle matière'}</p>
                </div>
                <div class="page-header-actions">
                    <a href="${pageContext.request.contextPath}/matieres" class="btn btn-ghost">← Retour</a>
                </div>
            </div>

            <div class="card" style="max-width: 620px;">
                <c:if test="${error != null}">
                    <div class="alert alert-danger" style="margin-bottom: var(--space-6);">
                        ${error}
                    </div>
                </c:if>

                <form method="POST" action="${pageContext.request.contextPath}/matieres">
                    <input type="hidden" name="action" value="${matiere != null ? 'update' : 'create'}">
                    <c:if test="${matiere != null}">
                        <input type="hidden" name="id" value="${matiere.id}">
                    </c:if>

                    <div class="form-group">
                        <label for="code">Code *</label>
                        <input
                            type="text"
                            id="code"
                            name="code"
                            value="${matiere != null ? matiere.code : ''}"
                            placeholder="EX: INFO301"
                            required
                        >
                    </div>

                    <div class="form-group">
                        <label for="intitule">Intitulé *</label>
                        <input
                            type="text"
                            id="intitule"
                            name="intitule"
                            value="${matiere != null ? matiere.intitule : ''}"
                            required
                        >
                    </div>

                    <div class="form-grid">
                        <div class="form-group">
                            <label for="coefficient">Coefficient *</label>
                            <input
                                type="number"
                                id="coefficient"
                                name="coefficient"
                                value="${matiere != null ? matiere.coefficient : '1'}"
                                min="1"
                                max="6"
                                required
                            >
                        </div>

                        <div class="form-group">
                            <label for="semestre">Semestre *</label>
                            <select id="semestre" name="semestre" required>
                                <option value="">-- Sélectionner --</option>
                                <option value="1" ${matiere != null && matiere.semestre == 1 ? 'selected' : ''}>
                                    Semestre 1
                                </option>
                                <option value="2" ${matiere != null && matiere.semestre == 2 ? 'selected' : ''}>
                                    Semestre 2
                                </option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="filiere">Filière *</label>
                        <select id="filiere" name="filiere" required>
                            <option value="">-- Sélectionner --</option>
                            <option value="Informatique" ${matiere != null && matiere.filiere == 'Informatique' ? 'selected' : ''}>
                                Informatique
                            </option>
                            <option value="Gestion" ${matiere != null && matiere.filiere == 'Gestion' ? 'selected' : ''}>
                                Gestion
                            </option>
                            <option value="Génie Civil" ${matiere != null && matiere.filiere == 'Génie Civil' ? 'selected' : ''}>
                                Génie Civil
                            </option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="enseignant">Enseignant</label>
                        <input
                            type="text"
                            id="enseignant"
                            name="enseignant"
                            value="${matiere != null ? matiere.enseignant : ''}"
                        >
                    </div>

                    <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:8px;">
                        <a href="${pageContext.request.contextPath}/matieres" class="btn btn-ghost">Annuler</a>
                        <button type="submit" class="btn btn-primary">
                            ${matiere != null ? 'Mettre à jour' : 'Créer la matière'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</body>
</html>
