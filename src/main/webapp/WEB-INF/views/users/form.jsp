<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${user != null ? 'Modifier' : 'Ajouter'} un Utilisateur - NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <main class="main">
        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>${user != null ? 'Modifier un utilisateur' : 'Ajouter un utilisateur'}</h1>
                    <p class="subtitle">Veuillez remplir les informations du compte</p>
                </div>
                <div class="page-header-actions">
                    <a href="${pageContext.request.contextPath}/users" class="btn btn-ghost">← Retour</a>
                </div>
            </div>

            <div class="card" style="max-width: 620px;">
                <form action="${pageContext.request.contextPath}/users" method="POST" class="auth-form" style="margin: 0; padding: 0; background: none; box-shadow: none;">
                    
                    <input type="hidden" name="action" value="${user != null ? 'update' : 'insert'}">
                    <c:if test="${user != null}">
                        <input type="hidden" name="id" value="${user.id}">
                    </c:if>

                    <div class="form-group" style="margin-bottom: var(--space-4);">
                        <label class="form-label" for="login">Login / Identifiant (Requis)</label>
                        <input type="text" id="login" name="login" class="form-control" value="${user != null ? user.login : ''}" required>
                    </div>

                    <div class="form-group" style="margin-bottom: var(--space-4);">
                        <label class="form-label" for="password">Mot de passe (Laissez vide pour conserver l'ancien mode pass, ou taper pour modifier)</label>
                        <input type="password" id="password" name="password" class="form-control" ${user == null ? 'placeholder="pass123 par défaut"' : ''}>
                    </div>

                    <div class="form-group" style="margin-bottom: var(--space-4);">
                        <label class="form-label" for="nom">Nom Complet (Requis)</label>
                        <input type="text" id="nom" name="nom" class="form-control" value="${user != null ? user.nom : ''}" required>
                    </div>

                    <div class="form-group" style="margin-bottom: var(--space-4);">
                        <label class="form-label" for="role">Rôle (Requis)</label>
                        <select id="role" name="role" class="form-control" required style="width: 100%; border-radius: var(--radius-md); padding: var(--space-3) var(--space-4);">
                            <option value="ENSEIGNANT" ${user != null && user.role == 'ENSEIGNANT' ? 'selected' : ''}>Enseignant</option>
                            <option value="ETUDIANT" ${user != null && user.role == 'ETUDIANT' ? 'selected' : ''}>Étudiant</option>
                            <option value="CHEF_DEPT" ${user != null && user.role == 'CHEF_DEPT' ? 'selected' : ''}>Chef de Département</option>
                        </select>
                    </div>

                    <div class="form-group" style="margin-bottom: var(--space-6);">
                        <label class="form-label" for="filiere">Filière</label>
                        <input type="text" id="filiere" name="filiere" class="form-control" value="${user != null ? user.filiere : ''}">
                    </div>

                    <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:8px;">
                        <a href="${pageContext.request.contextPath}/users" class="btn btn-ghost">Annuler</a>
                        <button type="submit" class="btn btn-primary">Enregistrer</button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</body>
</html>
