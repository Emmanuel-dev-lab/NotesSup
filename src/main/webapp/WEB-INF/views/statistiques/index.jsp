<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Statistiques — NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .filiere-toggles { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 20px; }
        .toggle-btn {
            padding: 8px 16px; border-radius: 8px; border: 1.5px solid var(--border-medium);
            background: white; color: var(--text-primary); font-size: 13px; font-weight: 500;
            cursor: pointer; font-family: var(--font-base); transition: all var(--transition-fast);
        }
        .toggle-btn.active { background: var(--accent-blue); border-color: var(--accent-blue); color: white; }

        .mention-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
        .mention-bar-label { width: 90px; font-size: 13px; font-weight: 500; }
        .mention-bar-track { flex: 1; height: 10px; border-radius: 99px; background: var(--border-light); overflow: hidden; }
        .mention-bar-fill { height: 100%; border-radius: 99px; }
        .mention-bar-count { font-size: 13px; font-family: var(--font-mono); font-weight: 600; width: 40px; text-align: right; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <main class="main">
        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Statistiques</h1>
                    <p class="subtitle">Vue d'ensemble et analyses des résultats</p>
                </div>
                <div class="page-header-actions">
                    <a href="${pageContext.request.contextPath}/export?format=csv" class="btn btn-ghost">↓ Export CSV</a>
                </div>
            </div>

            <!-- Filière Toggles -->
            <c:if test="${filieres != null}">
                <div class="filiere-toggles">
                    <a href="${pageContext.request.contextPath}/statistiques"
                       class="toggle-btn ${selectedFiliere == null ? 'active' : ''}">Toutes</a>
                    <c:forEach var="f" items="${filieres}">
                        <a href="${pageContext.request.contextPath}/statistiques?filiere=${f}"
                           class="toggle-btn ${selectedFiliere == f ? 'active' : ''}">${f}</a>
                    </c:forEach>
                </div>
            </c:if>

            <!-- KPI Cards -->
            <div class="grid-4" style="margin-bottom: 24px;">
                <div class="stat-card">
                    <div class="stat-card-icon" style="background: oklch(0.56 0.16 252 / 0.12);">👥</div>
                    <div>
                        <div class="stat-card-value">${totalEtudiants != null ? totalEtudiants : 0}</div>
                        <div class="stat-card-label">Étudiants</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-card-icon" style="background: oklch(0.58 0.14 160 / 0.12);">📊</div>
                    <div>
                        <div class="stat-card-value td-mono">
                            <c:if test="${moyenneGenerale != null}">
                                <fmt:formatNumber value="${moyenneGenerale}" maxFractionDigits="2"/>
                            </c:if>
                            <c:if test="${moyenneGenerale == null}">—</c:if>
                        </div>
                        <div class="stat-card-label">Moyenne générale</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-card-icon" style="background: oklch(0.72 0.16 72 / 0.12);">✅</div>
                    <div>
                        <div class="stat-card-value">${pourcentageAdmis != null ? pourcentageAdmis : 0}%</div>
                        <div class="stat-card-label">Taux de réussite</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-card-icon" style="background: oklch(0.62 0.16 300 / 0.12);">📚</div>
                    <div>
                        <div class="stat-card-value">${totalMatieres != null ? totalMatieres : 0}</div>
                        <div class="stat-card-label">Matières évaluées</div>
                    </div>
                </div>
            </div>

            <!-- Main content: 2 columns -->
            <div style="display:grid; grid-template-columns: 2fr 1fr; gap: 20px; margin-bottom: 24px;">
                <!-- Table par matière -->
                <div class="card">
                    <div class="card-header"><h3>Résultats par matière</h3></div>
                    <c:choose>
                        <c:when test="${statsParMatiere != null && !statsParMatiere.isEmpty()}">
                            <div class="table-container">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>Matière</th>
                                            <th>Moyenne</th>
                                            <th>Max</th>
                                            <th>Min</th>
                                            <th>Réussite</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="s" items="${matierePassRates}">
                                            <tr>
                                                <td>${matieresMap[s.key].intitule}</td>
                                                <td class="td-mono" style="font-weight:700; color: var(--text-muted);">
                                                    —
                                                </td>
                                                <td class="td-mono">—</td>
                                                <td class="td-mono">—</td>
                                                <td>
                                                    <div style="display:flex; align-items:center; gap:8px;">
                                                        <div class="progress-bar-track" style="width:60px;">
                                                            <div class="progress-bar-fill"
                                                                 style="width:${s.value}%;
                                                                        background: ${s.value >= 50 ? 'var(--accent-green)' : 'var(--accent-red)'};"></div>
                                                        </div>
                                                        <span style="font-size:12px; color:var(--text-secondary);">
                                                            <fmt:formatNumber value="${s.value}" maxFractionDigits="2"/>%
                                                        </span>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <p style="color:var(--text-muted); font-size:13px; text-align:center; padding:24px 0;">Aucune donnée disponible</p>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Distribution des mentions -->
                <div class="card">
                    <div class="card-header"><h3>Distribution des mentions</h3></div>
                    <div class="mention-bar">
                        <span class="mention-bar-label" style="color:#059669;">Très Bien</span>
                        <div class="mention-bar-track">
                            <div class="mention-bar-fill" style="width:${tresBienPct != null ? tresBienPct : 0}%; background:#059669;"></div>
                        </div>
                        <span class="mention-bar-count">${tresBienCount != null ? tresBienCount : 0}</span>
                    </div>
                    <div class="mention-bar">
                        <span class="mention-bar-label" style="color:#0891b2;">Bien</span>
                        <div class="mention-bar-track">
                            <div class="mention-bar-fill" style="width:${bienPct != null ? bienPct : 0}%; background:#0891b2;"></div>
                        </div>
                        <span class="mention-bar-count">${bienCount != null ? bienCount : 0}</span>
                    </div>
                    <div class="mention-bar">
                        <span class="mention-bar-label" style="color:#7c3aed;">Assez Bien</span>
                        <div class="mention-bar-track">
                            <div class="mention-bar-fill" style="width:${assezBienPct != null ? assezBienPct : 0}%; background:#7c3aed;"></div>
                        </div>
                        <span class="mention-bar-count">${assezBienCount != null ? assezBienCount : 0}</span>
                    </div>
                    <div class="mention-bar">
                        <span class="mention-bar-label" style="color:#d97706;">Passable</span>
                        <div class="mention-bar-track">
                            <div class="mention-bar-fill" style="width:${passablePct != null ? passablePct : 0}%; background:#d97706;"></div>
                        </div>
                        <span class="mention-bar-count">${passableCount != null ? passableCount : 0}</span>
                    </div>
                    <div class="mention-bar">
                        <span class="mention-bar-label" style="color:#dc2626;">Ajourné</span>
                        <div class="mention-bar-track">
                            <div class="mention-bar-fill" style="width:${ajournePct != null ? ajournePct : 0}%; background:#dc2626;"></div>
                        </div>
                        <span class="mention-bar-count">${ajourneCount != null ? ajourneCount : 0}</span>
                    </div>
                </div>
            </div>

            <!-- Classement -->
            <div class="card">
                <div class="card-header"><h3>Classement général</h3></div>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Rang</th>
                                <th>Matricule</th>
                                <th>Nom</th>
                                <th>Moyenne</th>
                                <th>Mention</th>
                                <th>Décision</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${topStudents != null && !topStudents.isEmpty()}">
                                    <c:forEach var="s" items="${topStudents}" varStatus="loop">
                                        <tr>
                                            <td style="font-weight:700; font-size:16px;">
                                                <c:choose>
                                                    <c:when test="${loop.index == 0}">🥇</c:when>
                                                    <c:when test="${loop.index == 1}">🥈</c:when>
                                                    <c:when test="${loop.index == 2}">🥉</c:when>
                                                    <c:otherwise>${loop.index + 1}</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="td-mono" style="color:var(--accent-blue); font-size:12px;">${etudiantsMap[s.key].matricule}</td>
                                            <td class="td-bold">${etudiantsMap[s.key].nom} ${etudiantsMap[s.key].prenom}</td>
                                            <td class="td-mono" style="font-weight:700;
                                                color: ${s.value >= 16 ? '#059669' :
                                                         s.value >= 14 ? '#0891b2' :
                                                         s.value >= 12 ? '#7c3aed' :
                                                         s.value >= 10 ? '#d97706' : '#dc2626'};">
                                                <fmt:formatNumber value="${s.value}" maxFractionDigits="2"/>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${s.value >= 16}"><span class="badge badge-success">Très Bien</span></c:when>
                                                    <c:when test="${s.value >= 14}"><span class="badge badge-info">Bien</span></c:when>
                                                    <c:when test="${s.value >= 12}"><span class="badge badge-purple">Assez Bien</span></c:when>
                                                    <c:when test="${s.value >= 10}"><span class="badge badge-warning">Passable</span></c:when>
                                                    <c:otherwise><span class="badge badge-danger">Ajourné</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${s.value >= 10}"><span class="badge badge-success">Admis(e)</span></c:when>
                                                    <c:otherwise><span class="badge badge-danger">Ajourné(e)</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr><td colspan="6" style="text-align:center; padding:40px; color:var(--text-muted);">Aucune donnée disponible</td></tr>
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
