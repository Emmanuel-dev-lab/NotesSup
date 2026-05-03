<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <!-- Include Sidebar -->
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <!-- Main Content -->
    <main class="main">
        <!-- Page Header -->
        <header class="page-header">
            <h1>Dashboard</h1>
            <p>Bienvenue dans NotesSup - Système de Gestion des Notes & Bulletins</p>
        </header>

        <!-- Page Content -->
        <div class="page-content">
            <c:choose>
                <c:when test="${sessionScope.user.role == 'CHEF_DEPT'}">
                    <!-- Chef Dept Dashboard -->
                    <h2 style="margin-bottom: var(--space-8);">Vue d'ensemble</h2>

                    <!-- KPI Cards -->
                    <div class="grid-4">
                        <div class="kpi-card">
                            <div class="kpi-number">${totalEtudiants != null ? totalEtudiants : 0}</div>
                            <div class="kpi-label">Étudiants</div>
                        </div>

                        <div class="kpi-card">
                            <div class="kpi-number">${totalMatieres != null ? totalMatieres : 0}</div>
                            <div class="kpi-label">Matières</div>
                        </div>

                        <div class="kpi-card">
                            <div class="kpi-number">${totalNotes != null ? totalNotes : 0}</div>
                            <div class="kpi-label">Notes Saisies</div>
                        </div>

                        <div class="kpi-card">
                            <div class="kpi-number">${tauxReussite != null ? tauxReussite : 0}%</div>
                            <div class="kpi-label">Taux Réussite</div>
                            <div class="kpi-badge">Année Courante</div>
                        </div>
                    </div>

                    <!-- Actions rapides -->
                    <div style="margin-top: var(--space-12);">
                        <h3 style="margin-bottom: var(--space-6);">Actions rapides</h3>
                        <div class="grid-3">
                            <div class="card">
                                <h3>Ajouter un étudiant</h3>
                                <p style="color: var(--color-text-secondary); margin: var(--space-3) 0;">
                                    Enregistrer un nouvel étudiant dans le système
                                </p>
                                <div class="card-footer">
                                    <a href="${pageContext.request.contextPath}/etudiants?action=add" class="btn btn-primary">
                                        Ajouter
                                    </a>
                                </div>
                            </div>

                            <div class="card">
                                <h3>Saisir des notes</h3>
                                <p style="color: var(--color-text-secondary); margin: var(--space-3) 0;">
                                    Enregistrer ou modifier les notes des étudiants
                                </p>
                                <div class="card-footer">
                                    <a href="${pageContext.request.contextPath}/notes" class="btn btn-primary">
                                        Aller aux notes
                                    </a>
                                </div>
                            </div>

                            <div class="card">
                                <h3>Publier délibérations</h3>
                                <p style="color: var(--color-text-secondary); margin: var(--space-3) 0;">
                                    Publier les résultats des délibérations
                                </p>
                                <div class="card-footer">
                                    <a href="${pageContext.request.contextPath}/deliberations" class="btn btn-primary">
                                        Gérer
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                </c:when>

                <c:when test="${sessionScope.user.role == 'ENSEIGNANT'}">
                    <!-- Enseignant Dashboard -->
                    <h2 style="margin-bottom: var(--space-8);">Mes statistiques</h2>

                    <div class="grid-3">
                        <div class="kpi-card">
                            <div class="kpi-number">${mesEtudiants != null ? mesEtudiants : 0}</div>
                            <div class="kpi-label">Mes Étudiants</div>
                        </div>

                        <div class="kpi-card">
                            <div class="kpi-number">${mesMatieres != null ? mesMatieres : 0}</div>
                            <div class="kpi-label">Mes Matières</div>
                        </div>

                        <div class="kpi-card">
                            <div class="kpi-number">${notesASaisir != null ? notesASaisir : 0}</div>
                            <div class="kpi-label">Notes à Saisir</div>
                        </div>
                    </div>

                    <div style="margin-top: var(--space-12);">
                        <a href="${pageContext.request.contextPath}/notes" class="btn btn-primary">
                            Gérer mes notes
                        </a>
                    </div>

                </c:when>

                <c:when test="${sessionScope.user.role == 'ETUDIANT'}">
                    <!-- Étudiant Dashboard -->
                    <h2 style="margin-bottom: var(--space-8);">Mon profil académique</h2>

                    <div class="grid-2">
                        <div class="card">
                            <div class="card-header">
                                <h3>Informations</h3>
                            </div>
                            <div class="card-body">
                                <p><strong>Matricule:</strong> ${studentInfo.matricule}</p>
                                <p><strong>Filière:</strong> ${studentInfo.filiere}</p>
                                <p><strong>Année:</strong> ${studentInfo.annee}</p>
                            </div>
                        </div>

                        <div class="card">
                            <div class="card-header">
                                <h3>Statistiques</h3>
                            </div>
                            <div class="card-body">
                                <p><strong>Moyenne générale:</strong> <span class="numeric">${moyenneGenerale != null ? moyenneGenerale : 'N/A'}</span></p>
                                <p><strong>Notes saisies:</strong> ${notesCount != null ? notesCount : 0}</p>
                            </div>
                        </div>
                    </div>

                    <div style="margin-top: var(--space-12);">
                        <h3 style="margin-bottom: var(--space-6);">Actions</h3>
                        <a href="${pageContext.request.contextPath}/bulletins" class="btn btn-primary">
                            Voir mon bulletin
                        </a>
                    </div>

                </c:when>
            </c:choose>
        </div>
    </main>
</body>
</html>
