<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Statistiques - NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <!-- Include Sidebar -->
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <!-- Main Content -->
    <main class="main">
        <!-- Page Header -->
        <header class="page-header">
            <div class="flex-between">
                <div>
                    <h1>Statistiques</h1>
                    <p>Vue d'ensemble et analyses des résultats</p>
                </div>
                <a href="${pageContext.request.contextPath}/export?format=csv" class="btn btn-ghost">
                    Exporter CSV
                </a>
            </div>
        </header>

        <!-- Page Content -->
        <div class="page-content">
            <!-- Summary KPIs -->
            <div class="grid-4" style="margin-bottom: var(--space-12);">
                <div class="kpi-card">
                    <div class="kpi-number">${totalEtudiants}</div>
                    <div class="kpi-label">Étudiants</div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-number">${etudiantsAdmis}</div>
                    <div class="kpi-label">Admis</div>
                    <div class="kpi-badge">${pourcentageAdmis}%</div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-number">${etudiantsAux}</div>
                    <div class="kpi-label">Auxilaire</div>
                    <div class="kpi-badge" style="background-color: rgba(255, 193, 7, 0.1); color: var(--color-warning);">
                        ${pourcentageAux}%
                    </div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-number">${moyenneGenerale}</div>
                    <div class="kpi-label">Moyenne</div>
                </div>
            </div>

            <!-- Distribution by Mention -->
            <div class="card" style="margin-bottom: var(--space-8);">
                <div class="card-header">
                    <h2>Distribution des mentions</h2>
                </div>
                <div class="card-body">
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th>Mention</th>
                                    <th class="numeric">Nombre</th>
                                    <th class="numeric">Pourcentage</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="mention" items="${mentionStats}">
                                    <tr>
                                        <td>
                                            <span class="badge badge-primary">${mention.mention}</span>
                                        </td>
                                        <td class="numeric">${mention.count}</td>
                                        <td class="numeric">${mention.percentage}%</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Top Students -->
            <div class="grid-2" style="margin-bottom: var(--space-8);">
                <div class="card">
                    <div class="card-header">
                        <h2>Top 5 Meilleurs</h2>
                    </div>
                    <div class="card-body">
                        <div class="table-container">
                            <table style="font-size: var(--text-sm);">
                                <thead>
                                    <tr>
                                        <th>Étudiant</th>
                                        <th class="numeric">Moyenne</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="student" items="${topStudents}" varStatus="loop">
                                        <c:if test="${loop.index < 5}">
                                            <tr>
                                                <td>${student.nom} ${student.prenom}</td>
                                                <td class="numeric">
                                                    <fmt:formatNumber value="${student.moyenne}" maxFractionDigits="2" />
                                                </td>
                                            </tr>
                                        </c:if>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h2>5 Nécessitant Aide</h2>
                    </div>
                    <div class="card-body">
                        <div class="table-container">
                            <table style="font-size: var(--text-sm);">
                                <thead>
                                    <tr>
                                        <th>Étudiant</th>
                                        <th class="numeric">Moyenne</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="student" items="${bottomStudents}" varStatus="loop">
                                        <c:if test="${loop.index < 5}">
                                            <tr>
                                                <td>${student.nom} ${student.prenom}</td>
                                                <td class="numeric">
                                                    <fmt:formatNumber value="${student.moyenne}" maxFractionDigits="2" />
                                                </td>
                                            </tr>
                                        </c:if>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Statistics by Filière -->
            <div class="card">
                <div class="card-header">
                    <h2>Statistiques par filière</h2>
                </div>
                <div class="card-body">
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th>Filière</th>
                                    <th class="numeric">Étudiants</th>
                                    <th class="numeric">Moyenne</th>
                                    <th class="numeric">Taux Réussite</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="filiereStats" items="${filieresStats}">
                                    <tr>
                                        <td>${filiereStats.filiere}</td>
                                        <td class="numeric">${filiereStats.count}</td>
                                        <td class="numeric">
                                            <fmt:formatNumber value="${filiereStats.moyenne}" maxFractionDigits="2" />
                                        </td>
                                        <td class="numeric">${filiereStats.tauxReussite}%</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
