<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes Statistiques — NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <main class="main">
        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Mes Statistiques</h1>
                    <p class="subtitle">Analyse détaillée de mes résultats par rapport à la classe</p>
                </div>
            </div>

            <!-- KPI Cards -->
            <div class="grid-4" style="margin-bottom: 24px;">
                <div class="stat-card">
                    <div class="stat-card-icon" style="background: oklch(0.56 0.16 252 / 0.12);">📊</div>
                    <div>
                        <div class="stat-card-value td-mono" style="color: ${maMoyenne != null && maMoyenne >= 16 ? '#059669' :
                                                                          maMoyenne != null && maMoyenne >= 14 ? '#0891b2' :
                                                                          maMoyenne != null && maMoyenne >= 12 ? '#7c3aed' :
                                                                          maMoyenne != null && maMoyenne >= 10 ? '#d97706' : '#dc2626'};">
                            <c:if test="${maMoyenne != null}">
                                <fmt:formatNumber value="${maMoyenne}" maxFractionDigits="2"/>
                            </c:if>
                            <c:if test="${maMoyenne == null}">—</c:if>
                        </div>
                        <div class="stat-card-label">Moyenne générale</div>
                        <c:if test="${maMention != null}">
                            <div class="stat-card-sub" style="margin-top:4px;">
                                <span class="badge badge-info">${maMention}</span>
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

            <!-- Table de comparaison avec la classe -->
            <div class="card">
                <div class="card-header"><h3>Comparatif par matière</h3></div>
                <c:choose>
                    <c:when test="${mesNotes != null && !mesNotes.isEmpty()}">
                        <div class="table-container">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Matière</th>
                                        <th>Coeff</th>
                                        <th>Ma Note</th>
                                        <th>Moyenne Classe</th>
                                        <th>Max Classe</th>
                                        <th>Min Classe</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="note" items="${mesNotes}">
                                        <c:set var="m" value="${matieresMap[note.matiereId]}" />
                                        <c:set var="stats" value="${subjectStats[note.matiereId]}" />
                                        <tr>
                                            <td class="td-bold">${m.intitule}</td>
                                            <td class="td-mono">${m.coefficient}</td>
                                            <td class="td-mono" style="font-weight:700;
                                                color: ${note.noteFinale >= 16 ? '#059669' :
                                                         note.noteFinale >= 14 ? '#0891b2' :
                                                         note.noteFinale >= 12 ? '#7c3aed' :
                                                         note.noteFinale >= 10 ? '#d97706' : '#dc2626'};">
                                                <fmt:formatNumber value="${note.noteFinale}" maxFractionDigits="2"/>
                                            </td>
                                            <td class="td-mono" style="color:var(--text-secondary);">
                                                <c:if test="${stats != null && stats.moy != null}">
                                                    <fmt:formatNumber value="${stats.moy}" maxFractionDigits="2"/>
                                                </c:if>
                                            </td>
                                            <td class="td-mono" style="color:#059669;">
                                                <c:if test="${stats != null && stats.max != null}">
                                                    <fmt:formatNumber value="${stats.max}" maxFractionDigits="2"/>
                                                </c:if>
                                            </td>
                                            <td class="td-mono" style="color:#dc2626;">
                                                <c:if test="${stats != null && stats.min != null}">
                                                    <fmt:formatNumber value="${stats.min}" maxFractionDigits="2"/>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p style="color:var(--text-muted); font-size:13px; text-align:center; padding:24px 0;">Aucune note disponible pour cette session.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</body>
</html>
