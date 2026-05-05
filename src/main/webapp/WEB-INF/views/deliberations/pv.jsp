<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Procès-Verbal — ${deliberation.filiere} — ${deliberation.session}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .pv-header {
            text-align: center;
            margin-bottom: 32px;
            border-bottom: 2px solid var(--border-color);
            padding-bottom: 16px;
        }
        .pv-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 24px;
            background: white;
            border-radius: var(--radius-md);
            overflow: hidden;
            box-shadow: var(--shadow-sm);
        }
        .pv-table th, .pv-table td {
            padding: 12px 16px;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }
        .pv-table th {
            background: var(--bg-secondary);
            font-weight: 600;
            color: var(--text-secondary);
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .badge-admis {
            background: #e6fffa;
            color: #047481;
            padding: 4px 8px;
            border-radius: 4px;
            font-weight: 600;
            font-size: 0.75rem;
        }
        .badge-refuse {
            background: #fff5f5;
            color: #c53030;
            padding: 4px 8px;
            border-radius: 4px;
            font-weight: 600;
            font-size: 0.75rem;
        }
        @media print {
            .sidebar, .page-header-actions, .btn-ghost {
                display: none !important;
            }
            .main {
                margin-left: 0 !important;
                padding: 0 !important;
            }
            .card {
                box-shadow: none !important;
                border: none !important;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <main class="main">
        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Procès-Verbal de Délibération</h1>
                    <p class="subtitle">${deliberation.filiere} — Session ${deliberation.session} (${deliberation.anneeAcademique})</p>
                </div>
                <div class="page-header-actions">
                    <button onclick="window.print()" class="btn btn-secondary">Imprimer</button>
                    <a href="${pageContext.request.contextPath}/deliberations" class="btn btn-ghost">Retour</a>
                </div>
            </div>

            <c:if test="${success != null}">
                <div class="alert alert-info">${success}</div>
            </c:if>

            <div class="card">
                <div class="pv-header">
                    <h2>RÉPUBLIQUE DU CAMEROUN</h2>
                    <p>Paix - Travail - Patrie</p>
                    <div style="margin: 16px 0;">
                        <strong>UNIVERSITÉ DE...</strong><br>
                        FACULTÉ DES SCIENCES / DÉPARTEMENT D'INFORMATIQUE
                    </div>
                    <h3>PV DE DÉLIBÉRATION (PROVISOIRE)</h3>
                </div>

                <table class="pv-table">
                    <thead>
                        <tr>
                            <th>Rang</th>
                            <th>Matricule</th>
                            <th>Nom & Prénoms</th>
                            <th>Moyenne</th>
                            <th>Mention</th>
                            <th>Décision</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="res" items="${results}" varStatus="status">
                            <tr>
                                <td>${status.index + 1}</td>
                                <td><code>${res.etudiant.matricule}</code></td>
                                <td><strong>${res.etudiant.nom}</strong> ${res.etudiant.prenom}</td>
                                <td>
                                    <span style="font-family: monospace; font-weight: bold; font-size: 1.1rem;">
                                        ${res.moyenne}
                                    </span>
                                </td>
                                <td>${res.mention}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${res.admis}">
                                            <span class="badge-admis">ADMIS</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-refuse">ÉCHEC</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>

                <div style="margin-top: 48px; display: flex; justify-content: flex-end;">
                    <div style="text-align: center; width: 300px;">
                        <p>Fait à..., le <fmt:formatDate value="<%= new java.util.Date() %>" pattern="dd/MM/yyyy"/></p>
                        <p style="margin-top: 64px;"><strong>Le Président du Jury</strong></p>
                    </div>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
