<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${etudiant != null ? 'Modifier' : 'Ajouter'} étudiant — NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <main class="main">
        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>${etudiant != null ? 'Modifier l\'étudiant' : 'Ajouter un étudiant'}</h1>
                    <p class="subtitle">${etudiant != null ? etudiant.prenom.concat(' ').concat(etudiant.nom) : 'Enregistrer un nouvel étudiant'}</p>
                </div>
                <div class="page-header-actions">
                    <a href="${pageContext.request.contextPath}/etudiants" class="btn btn-ghost">← Retour</a>
                </div>
            </div>

            <div class="card" style="max-width: 620px;">
                <c:if test="${error != null}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <form method="POST" action="${pageContext.request.contextPath}/etudiants" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="${etudiant != null ? 'update' : 'create'}">
                    <c:if test="${etudiant != null}">
                        <input type="hidden" name="id" value="${etudiant.id}">
                    </c:if>

                    <div class="form-grid">
                        <div class="form-group">
                            <label for="matricule">Matricule *</label>
                            <input type="text" id="matricule" name="matricule"
                                   placeholder="Ex: 2024INFO001"
                                   value="${etudiant != null ? etudiant.matricule : ''}" required>
                        </div>
                        <div class="form-group">
                            <label for="annee">Année *</label>
                            <select id="annee" name="annee" required>
                                <option value="">— Sélectionner —</option>
                                <c:forEach var="i" begin="1" end="5">
                                    <option value="${i}" ${etudiant != null && etudiant.annee == i ? 'selected' : ''}>Licence ${i}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="prenom">Prénom *</label>
                            <input type="text" id="prenom" name="prenom"
                                   placeholder="Prénom"
                                   value="${etudiant != null ? etudiant.prenom : ''}" required>
                        </div>
                        <div class="form-group">
                            <label for="nom">Nom *</label>
                            <input type="text" id="nom" name="nom"
                                   placeholder="Nom de famille"
                                   value="${etudiant != null ? etudiant.nom : ''}" required>
                        </div>
                        <div class="form-group">
                            <label for="filiere">Filière *</label>
                            <select id="filiere" name="filiere" required>
                                <option value="">— Sélectionner —</option>
                                <option value="Informatique" ${etudiant != null && etudiant.filiere == 'Informatique' ? 'selected' : ''}>Informatique</option>
                                <option value="Gestion" ${etudiant != null && etudiant.filiere == 'Gestion' ? 'selected' : ''}>Gestion</option>
                                <option value="Génie Civil" ${etudiant != null && etudiant.filiere == 'Génie Civil' ? 'selected' : ''}>Génie Civil</option>
                                <option value="Sciences" ${etudiant != null && etudiant.filiere == 'Sciences' ? 'selected' : ''}>Sciences</option>
                                <option value="Droit" ${etudiant != null && etudiant.filiere == 'Droit' ? 'selected' : ''}>Droit</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="telephone">Téléphone</label>
                            <input type="tel" id="telephone" name="telephone"
                                   placeholder="Ex: +221 77 123 45 67"
                                   value="${etudiant != null ? etudiant.telephone : ''}">
                        </div>
                        <div class="form-group" style="grid-column: span 2;">
                            <label for="photo">Photo de profil (Optionnel)</label>
                            <input type="file" id="photo" name="photo" accept="image/*">
                            <c:if test="${etudiant != null && etudiant.photoPath != null}">
                                <div style="margin-top: 8px; display: flex; align-items: center; gap: 8px;">
                                    <img src="${pageContext.request.contextPath}/${etudiant.photoPath}" 
                                         alt="Photo actuelle" 
                                         style="width: 48px; height: 48px; object-fit: cover; border-radius: 4px; border: 1px solid var(--border-color);">
                                    <span class="subtitle">Photo actuelle</span>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:8px;">
                        <a href="${pageContext.request.contextPath}/etudiants" class="btn btn-ghost">Annuler</a>
                        <button type="submit" class="btn btn-primary">
                            ${etudiant != null ? 'Mettre à jour' : 'Créer l\'étudiant'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</body>
</html>
