<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Délibérations — NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .delib-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
            gap: 16px;
        }

        .delib-card {
            background: white;
            border-radius: 12px;
            border: 1px solid var(--border-light);
            box-shadow: var(--shadow-card);
            overflow: hidden;
        }

        .delib-card-top {
            height: 4px;
        }

        .delib-card-body {
            padding: 20px 20px 16px;
        }

        .delib-card-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 8px;
        }

        .delib-card-badges {
            display: flex;
            gap: 6px;
            margin-bottom: 18px;
        }

        .delib-stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 12px;
            margin-bottom: 16px;
        }

        .delib-stat {
            text-align: center;
            padding: 10px 6px;
            background: var(--bg-row-alt);
            border-radius: 8px;
        }

        .delib-stat-value {
            font-size: 20px;
            font-weight: 700;
            font-family: var(--font-mono);
            color: var(--text-primary);
        }

        .delib-stat-label {
            font-size: 11px;
            color: var(--text-muted);
            margin-top: 2px;
        }

        .delib-date {
            font-size: 12px;
            color: var(--text-muted);
            margin-bottom: 14px;
        }

        .delib-actions {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
            padding: 14px 20px;
            border-top: 1px solid var(--border-light);
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <main class="main">
        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Délibérations</h1>
                    <p class="subtitle">Gestion et publication des sessions de délibérations</p>
                </div>
            </div>

            <c:if test="${error != null}"><div class="alert alert-danger">${error}</div></c:if>
            <c:if test="${success != null}"><div class="alert alert-success">${success}</div></c:if>

            <c:choose>
                <c:when test="${deliberations != null && deliberations.size() > 0}">
                    <div class="delib-grid">
                        <c:forEach var="delib" items="${deliberations}">
                            <div class="delib-card">
                                <div class="delib-card-top"
                                     style="background: ${delib.publiee ? 'var(--accent-green)' : 'var(--accent-amber)'};"></div>
                                <div class="delib-card-body">
                                    <div class="delib-card-title">${delib.filiere}</div>
                                    <div class="delib-card-badges">
                                        <span class="badge badge-neutral">${delib.session}</span>
                                        <span class="badge badge-neutral">${delib.anneeAcademique}</span>
                                        <span class="badge ${delib.publiee ? 'badge-success' : 'badge-warning'}">
                                            ${delib.publiee ? 'Publiée' : 'En attente'}
                                        </span>
                                    </div>

                                    <!-- 3 stats -->
                                    <div class="delib-stats">
                                        <div class="delib-stat">
                                            <div class="delib-stat-value">${delib.nbEtudiants != null ? delib.nbEtudiants : '—'}</div>
                                            <div class="delib-stat-label">Étudiants</div>
                                        </div>
                                        <div class="delib-stat">
                                            <div class="delib-stat-value" style="color:var(--accent-green);">
                                                ${delib.nbAdmis != null ? delib.nbAdmis : '—'}
                                            </div>
                                            <div class="delib-stat-label">Admis</div>
                                        </div>
                                        <div class="delib-stat">
                                            <div class="delib-stat-value" style="color:var(--accent-blue);">
                                                <c:if test="${delib.moyenne != null}">
                                                    <fmt:formatNumber value="${delib.moyenne}" maxFractionDigits="2"/>
                                                </c:if>
                                                <c:if test="${delib.moyenne == null}">—</c:if>
                                            </div>
                                            <div class="delib-stat-label">Moyenne</div>
                                        </div>
                                    </div>

                                    <c:if test="${delib.publiee && delib.datePublication != null}">
                                        <div class="delib-date">
                                            Publié le <fmt:formatDate value="${delib.datePublication}" pattern="dd/MM/yyyy"/>
                                            <c:if test="${delib.publiePar != null}"> · par ${delib.publiePar}</c:if>
                                        </div>
                                    </c:if>
                                </div>

                                <div class="delib-actions">
                                    <a href="${pageContext.request.contextPath}/deliberations?action=pv&id=${delib.id}"
                                       class="btn btn-sm btn-ghost">📋 Voir PV</a>
                                    <a href="${pageContext.request.contextPath}/deliberations?action=pdf&id=${delib.id}"
                                       class="btn btn-sm btn-ghost">↓ PDF</a>
                                    <c:if test="${!delib.publiee && sessionScope.user.role == 'CHEF_DEPT'}">
                                        <form method="POST" action="${pageContext.request.contextPath}/deliberations" style="display:inline;">
                                            <input type="hidden" name="action" value="publish">
                                            <input type="hidden" name="id" value="${delib.id}">
                                            <button type="submit" class="btn btn-sm btn-success">✓ Publier les résultats</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${delib.publiee && sessionScope.user.role == 'CHEF_DEPT'}">
                                        <a href="${pageContext.request.contextPath}/deliberations?action=sms&id=${delib.id}"
                                           class="btn btn-sm btn-warning">✉ Envoyer SMS</a>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="card" style="text-align:center; padding:48px;">
                        <div style="font-size:32px; margin-bottom:12px;">🎓</div>
                        <p style="color:var(--text-secondary);">Aucune délibération enregistrée</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</body>
</html>
