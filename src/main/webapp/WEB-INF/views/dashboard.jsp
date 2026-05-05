<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de bord — NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <main class="main">
        <div class="page-content">
            <c:choose>
                <%-- ══ CHEF DE DÉPARTEMENT ══ --%>
                <c:when test="${sessionScope.user.role == 'CHEF_DEPT'}">
                    <div class="page-header">
                        <div>
                            <h1>Tableau de bord</h1>
                            <p class="subtitle">Vue d'ensemble du département</p>
                        </div>
                        <div class="page-header-actions">
                            <a href="${pageContext.request.contextPath}/etudiants?action=add" class="btn btn-primary">
                                + Ajouter étudiant
                            </a>
                        </div>
                    </div>

                    <%-- KPI Cards --%>
                    <div class="grid-4" style="margin-bottom: 24px;">
                        <div class="stat-card">
                            <div class="stat-card-icon" style="background: oklch(0.56 0.16 252 / 0.12);">👥</div>
                            <div>
                                <div class="stat-card-value">${totalEtudiants != null ? totalEtudiants : 0}</div>
                                <div class="stat-card-label">Étudiants inscrits</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-card-icon" style="background: oklch(0.58 0.14 160 / 0.12);">📚</div>
                            <div>
                                <div class="stat-card-value">${totalMatieres != null ? totalMatieres : 0}</div>
                                <div class="stat-card-label">Matières</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-card-icon" style="background: oklch(0.72 0.16 72 / 0.12);">✏️</div>
                            <div>
                                <div class="stat-card-value">${totalNotes != null ? totalNotes : 0}</div>
                                <div class="stat-card-label">Notes saisies</div>
                                <c:if test="${tauxReussite != null}">
                                    <div class="stat-card-sub" style="color: var(--accent-amber);">${tauxReussite}% de réussite</div>
                                </c:if>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-card-icon" style="background: oklch(0.56 0.18 22 / 0.12);">🎓</div>
                            <div>
                                <div class="stat-card-value">${totalDeliberations != null ? totalDeliberations : 0}</div>
                                <div class="stat-card-label">Délibérations</div>
                            </div>
                        </div>
                    </div>

                    <%-- 2-column content grid --%>
                    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px; margin-bottom: 24px;">
                        <%-- Résultats by filière --%>
                        <div class="card">
                            <div class="card-header">
                                <h3>Résultats par filière</h3>
                            </div>
                            <c:choose>
                                <c:when test="${filiereStats != null && !filiereStats.isEmpty()}">
                                    <c:forEach var="stat" items="${filiereStats}">
                                        <div style="margin-bottom: 16px;">
                                            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
                                                <span style="font-size:13.5px; font-weight:600;">${stat.filiere}</span>
                                                <span style="font-size:12.5px; color:var(--text-secondary);">${stat.nbEtudiants} étudiants</span>
                                                <span style="font-family:var(--font-mono); font-weight:700; font-size:14px;
                                                      color: ${stat.moyenne >= 10 ? 'var(--accent-green)' : 'var(--accent-red)'};">
                                                    <fmt:formatNumber value="${stat.moyenne}" maxFractionDigits="2"/>/20
                                                </span>
                                            </div>
                                            <div class="progress-bar-track">
                                                <div class="progress-bar-fill"
                                                     style="width: ${stat.tauxReussite}%;
                                                            background: ${stat.tauxReussite >= 50 ? 'var(--accent-green)' : 'var(--accent-red)'};">
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <p style="color:var(--text-muted); font-size:13px; text-align:center; padding: 24px 0;">
                                        Aucune donnée disponible
                                    </p>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <%-- Right column --%>
                        <div style="display:flex; flex-direction:column; gap:16px;">
                            <%-- Alertes --%>
                            <div class="card">
                                <div class="card-header">
                                    <h3>⚠ Alertes</h3>
                                </div>
                                <c:choose>
                                    <c:when test="${alertes != null && !alertes.isEmpty()}">
                                        <c:forEach var="alerte" items="${alertes}">
                                            <div style="display:flex; align-items:flex-start; gap:8px; margin-bottom:10px;">
                                                <span style="color:var(--accent-red); margin-top:2px;">●</span>
                                                <div>
                                                    <div style="font-size:13px; font-weight:600;">${alerte.etudiantNom}</div>
                                                    <div style="font-size:11.5px; color:var(--text-secondary);">${alerte.matiereNom}</div>
                                                    <div style="font-size:12px; color:var(--accent-red); font-family:var(--font-mono); font-weight:700;">
                                                        <fmt:formatNumber value="${alerte.note}" maxFractionDigits="2"/>/20
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <p style="color:var(--text-muted); font-size:12.5px;">Aucun étudiant en difficulté.</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <%-- État délibérations --%>
                            <div class="card">
                                <div class="card-header">
                                    <h3>Délibérations</h3>
                                </div>
                                <c:choose>
                                    <c:when test="${deliberations != null && !deliberations.isEmpty()}">
                                        <c:forEach var="delib" items="${deliberations}">
                                            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                                                <span style="font-size:13px;">${delib.filiere}</span>
                                                <c:choose>
                                                    <c:when test="${delib.publiee}">
                                                        <span class="badge badge-success">Publiée</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-warning">En attente</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <p style="color:var(--text-muted); font-size:12.5px;">Aucune délibération.</p>
                                    </c:otherwise>
                                </c:choose>
                                <a href="${pageContext.request.contextPath}/deliberations"
                                   class="btn btn-ghost btn-sm" style="margin-top:12px; width:100%;">
                                    Voir tout
                                </a>
                            </div>
                        </div>
                    </div>

                    <%-- Dernières notes saisies --%>
                    <c:if test="${dernieresNotes != null && !dernieresNotes.isEmpty()}">
                        <div class="card">
                            <div class="card-header">
                                <h3>Dernières notes saisies</h3>
                            </div>
                            <div class="table-container">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>Étudiant</th>
                                            <th>Matière</th>
                                            <th>CC</th>
                                            <th>Examen</th>
                                            <th>Finale</th>
                                            <th>Mention</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="note" items="${dernieresNotes}">
                                            <tr>
                                                <td class="td-bold">${note.etudiantNom}</td>
                                                <td>${note.matiereNom}</td>
                                                <td class="td-mono"><fmt:formatNumber value="${note.noteCC}" maxFractionDigits="2"/></td>
                                                <td class="td-mono"><fmt:formatNumber value="${note.noteExam}" maxFractionDigits="2"/></td>
                                                <td class="td-mono" style="font-weight:700;
                                                    color: ${note.noteFinale >= 16 ? '#059669' :
                                                             note.noteFinale >= 14 ? '#0891b2' :
                                                             note.noteFinale >= 12 ? '#7c3aed' :
                                                             note.noteFinale >= 10 ? '#d97706' : '#dc2626'};">
                                                    <fmt:formatNumber value="${note.noteFinale}" maxFractionDigits="2"/>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${note.noteFinale >= 16}"><span class="badge badge-success">Très Bien</span></c:when>
                                                        <c:when test="${note.noteFinale >= 14}"><span class="badge badge-info">Bien</span></c:when>
                                                        <c:when test="${note.noteFinale >= 12}"><span class="badge badge-purple">Assez Bien</span></c:when>
                                                        <c:when test="${note.noteFinale >= 10}"><span class="badge badge-warning">Passable</span></c:when>
                                                        <c:otherwise><span class="badge badge-danger">Ajourné</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:if>

                    <%-- Fallback quick actions if no data --%>
                    <c:if test="${dernieresNotes == null || dernieresNotes.isEmpty()}">
                        <div class="grid-3">
                            <a href="${pageContext.request.contextPath}/etudiants?action=add" class="card" style="text-decoration:none; display:block;">
                                <div style="font-size:28px; margin-bottom:12px;">👤</div>
                                <div style="font-size:14px; font-weight:700; margin-bottom:6px;">Ajouter un étudiant</div>
                                <div style="font-size:12.5px; color:var(--text-secondary);">Enregistrer un nouvel étudiant</div>
                            </a>
                            <a href="${pageContext.request.contextPath}/notes" class="card" style="text-decoration:none; display:block;">
                                <div style="font-size:28px; margin-bottom:12px;">✏️</div>
                                <div style="font-size:14px; font-weight:700; margin-bottom:6px;">Saisir des notes</div>
                                <div style="font-size:12.5px; color:var(--text-secondary);">Enregistrer les notes</div>
                            </a>
                            <a href="${pageContext.request.contextPath}/deliberations" class="card" style="text-decoration:none; display:block;">
                                <div style="font-size:28px; margin-bottom:12px;">🎓</div>
                                <div style="font-size:14px; font-weight:700; margin-bottom:6px;">Délibérations</div>
                                <div style="font-size:12.5px; color:var(--text-secondary);">Publier les résultats</div>
                            </a>
                        </div>
                    </c:if>
                </c:when>

                <%-- ══ ENSEIGNANT ══ --%>
                <c:when test="${sessionScope.user.role == 'ENSEIGNANT'}">
                    <div class="page-header">
                        <div>
                            <h1>Tableau de bord</h1>
                            <p class="subtitle">Bienvenue, ${sessionScope.user.nom}</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/notes" class="btn btn-primary">Saisir des notes</a>
                    </div>

                    <div class="grid-3" style="margin-bottom: 24px;">
                        <div class="stat-card">
                            <div class="stat-card-icon" style="background: oklch(0.56 0.16 252 / 0.12);">👥</div>
                            <div>
                                <div class="stat-card-value">${mesEtudiants != null ? mesEtudiants : 0}</div>
                                <div class="stat-card-label">Mes étudiants</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-card-icon" style="background: oklch(0.58 0.14 160 / 0.12);">📚</div>
                            <div>
                                <div class="stat-card-value">${mesMatieres != null ? mesMatieres : 0}</div>
                                <div class="stat-card-label">Mes matières</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-card-icon" style="background: oklch(0.72 0.16 72 / 0.12);">✏️</div>
                            <div>
                                <div class="stat-card-value">${notesASaisir != null ? notesASaisir : 0}</div>
                                <div class="stat-card-label">Notes à saisir</div>
                            </div>
                        </div>
                    </div>
                </c:when>

                <%-- ══ ÉTUDIANT ══ --%>
                <c:when test="${sessionScope.user.role == 'ETUDIANT'}">
                    <div class="page-header">
                        <div style="display: flex; align-items: center; gap: 16px;">
                            <div class="avatar-sm" style="width: 64px; height: 64px;">
                                <c:choose>
                                    <c:when test="${etudiant.photoPath != null}">
                                        <img src="${pageContext.request.contextPath}/${etudiant.photoPath}" alt="Photo">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="avatar-placeholder" style="font-size: 24px;">${sessionScope.user.nom.substring(0,1)}</div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div>
                                <h1>Mon tableau de bord</h1>
                                <p class="subtitle">Bienvenue, ${sessionScope.user.nom} (${etudiant.matricule})</p>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/bulletins" class="btn btn-ghost">Mon bulletin</a>
                    </div>

                    <div class="grid-3" style="margin-bottom: 24px;">
                        <div class="stat-card">
                            <div class="stat-card-icon" style="background: oklch(0.56 0.16 252 / 0.12);">📊</div>
                            <div>
                                <div class="stat-card-value" style="font-size:36px; font-weight:800;
                                     color: ${moyenneGenerale != null && moyenneGenerale >= 16 ? '#059669' :
                                              moyenneGenerale != null && moyenneGenerale >= 14 ? '#0891b2' :
                                              moyenneGenerale != null && moyenneGenerale >= 12 ? '#7c3aed' :
                                              moyenneGenerale != null && moyenneGenerale >= 10 ? '#d97706' : '#dc2626'};">
                                    ${moyenneGenerale != null ? moyenneGenerale : '—'}
                                </div>
                                <div class="stat-card-label">Moyenne générale</div>
                                <c:if test="${mention != null}">
                                    <div class="stat-card-sub" style="color:var(--accent-blue); margin-top:4px;">
                                        <span class="badge badge-info">${mention}</span>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-card-icon" style="background: oklch(0.58 0.14 160 / 0.12);">✅</div>
                            <div>
                                <div class="stat-card-value">${matieresValidees != null ? matieresValidees : 0}</div>
                                <div class="stat-card-label">Matières validées</div>
                                <c:if test="${totalMatieres != null}">
                                    <div class="stat-card-sub" style="color:var(--text-secondary);">sur ${totalMatieres}</div>
                                </c:if>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-card-icon" style="background: oklch(0.72 0.16 72 / 0.12);">🏆</div>
                            <div>
                                <div class="stat-card-value">${creditsTotal != null ? creditsTotal : 0}</div>
                                <div class="stat-card-label">Crédits obtenus</div>
                            </div>
                        </div>
                    </div>

                    <%-- Notes table --%>
                    <c:if test="${mesNotes != null && !mesNotes.isEmpty()}">
                        <div class="card">
                            <div class="card-header"><h3>Mes notes</h3></div>
                            <div class="table-container">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>Code</th>
                                            <th>Matière</th>
                                            <th>Coeff.</th>
                                            <th>CC</th>
                                            <th>Examen</th>
                                            <th>Finale</th>
                                            <th>Mention</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="note" items="${mesNotes}">
                                            <tr>
                                                <td class="td-mono" style="color:var(--accent-blue);">${note.matiereCode}</td>
                                                <td>${note.matiereNom}</td>
                                                <td class="td-mono">${note.coefficient}</td>
                                                <td class="td-mono"><fmt:formatNumber value="${note.noteCC}" maxFractionDigits="2"/></td>
                                                <td class="td-mono"><fmt:formatNumber value="${note.noteExam}" maxFractionDigits="2"/></td>
                                                <td class="td-mono" style="font-weight:700;
                                                    color: ${note.noteFinale >= 16 ? '#059669' :
                                                             note.noteFinale >= 14 ? '#0891b2' :
                                                             note.noteFinale >= 12 ? '#7c3aed' :
                                                             note.noteFinale >= 10 ? '#d97706' : '#dc2626'};">
                                                    <fmt:formatNumber value="${note.noteFinale}" maxFractionDigits="2"/>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${note.noteFinale >= 16}"><span class="badge badge-success">Très Bien</span></c:when>
                                                        <c:when test="${note.noteFinale >= 14}"><span class="badge badge-info">Bien</span></c:when>
                                                        <c:when test="${note.noteFinale >= 12}"><span class="badge badge-purple">Assez Bien</span></c:when>
                                                        <c:when test="${note.noteFinale >= 10}"><span class="badge badge-warning">Passable</span></c:when>
                                                        <c:otherwise><span class="badge badge-danger">Ajourné</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:if>
                </c:when>
            </c:choose>
        </div>
    </main>
</body>
</html>
