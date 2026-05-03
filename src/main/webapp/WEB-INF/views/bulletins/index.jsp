<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bulletin - NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        @media print {
            body {
                margin: 0;
                padding: 0;
            }
            .no-print {
                display: none;
            }
        }

        .bulletin-page {
            max-width: 210mm;
            min-height: 297mm;
            margin: auto;
            padding: 20mm;
            background: white;
            box-shadow: var(--shadow-lg);
            font-family: 'DM Sans', Arial, sans-serif;
        }

        .bulletin-header {
            text-align: center;
            margin-bottom: 20px;
            border-bottom: 2px solid var(--color-border-dark);
            padding-bottom: 20px;
        }

        .bulletin-header h1 {
            font-size: 24px;
            margin: 0;
        }

        .bulletin-info {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .bulletin-info p {
            margin: 5px 0;
        }

        .bulletin-notes {
            margin-bottom: 20px;
        }

        .bulletin-notes table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        .bulletin-notes thead th {
            background-color: var(--color-bg-hover);
            padding: 8px;
            text-align: left;
            border: 1px solid var(--color-border);
        }

        .bulletin-notes tbody td {
            padding: 8px;
            border: 1px solid var(--color-border);
        }

        .bulletin-notes .numeric {
            text-align: right;
            font-family: 'DM Mono', monospace;
        }

        .bulletin-result {
            background-color: var(--color-bg-hover);
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 20px;
        }

        .bulletin-result-item {
            text-align: center;
        }

        .bulletin-result-value {
            font-size: 20px;
            font-weight: bold;
            color: var(--color-primary);
            font-family: 'DM Mono', monospace;
        }

        .bulletin-result-label {
            font-size: 12px;
            color: var(--color-text-secondary);
        }

        .bulletin-footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 2px solid var(--color-border-dark);
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
            font-size: 12px;
        }

        .signature-box {
            text-align: center;
        }

        .signature-line {
            margin-top: 30px;
            border-top: 1px solid var(--color-text-primary);
            padding-top: 5px;
        }
    </style>
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
                    <h1>Bulletin</h1>
                    <p>Relevé de notes académiques</p>
                </div>
                <div class="no-print" style="display: flex; gap: var(--space-4);">
                    <button class="btn btn-secondary" onclick="window.print();">
                        Imprimer
                    </button>
                    <a href="${pageContext.request.contextPath}/bulletins?format=pdf" class="btn btn-primary">
                        Télécharger PDF
                    </a>
                </div>
            </div>
        </header>

        <!-- Page Content -->
        <div class="page-content">
            <c:if test="${error != null}">
                <div class="alert alert-danger no-print" style="margin-bottom: var(--space-8);">
                    ${error}
                </div>
            </c:if>

            <c:if test="${etudiant != null}">
                <!-- Bulletin Content -->
                <div class="bulletin-page">
                    <!-- Header -->
                    <div class="bulletin-header">
                        <h1>BULLETIN DE NOTES</h1>
                        <p style="margin: 10px 0 0 0; font-size: 12px; color: var(--color-text-secondary);">
                            Année académique: ${anneeAcademique}
                        </p>
                    </div>

                    <!-- Student Info -->
                    <div class="bulletin-info">
                        <div>
                            <p><strong>Étudiant:</strong> ${etudiant.nom} ${etudiant.prenom}</p>
                            <p><strong>Matricule:</strong> ${etudiant.matricule}</p>
                            <p><strong>Filière:</strong> ${etudiant.filiere}</p>
                        </div>
                        <div>
                            <p><strong>Année:</strong> ${etudiant.annee}</p>
                            <p><strong>Semestre:</strong> 1</p>
                            <p><strong>Session:</strong> Normale</p>
                        </div>
                    </div>

                    <!-- Notes Table -->
                    <div class="bulletin-notes">
                        <table>
                            <thead>
                                <tr>
                                    <th>Matière</th>
                                    <th class="numeric">Coef.</th>
                                    <th class="numeric">Note CC</th>
                                    <th class="numeric">Note Examen</th>
                                    <th class="numeric">Note Finale</th>
                                    <th>Mention</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${notes != null && notes.size() > 0}">
                                        <c:forEach var="note" items="${notes}">
                                            <tr>
                                                <td>${note.matiereIntitule}</td>
                                                <td class="numeric">${note.coefficient}</td>
                                                <td class="numeric">
                                                    <c:if test="${note.noteCC != null}">
                                                        <fmt:formatNumber value="${note.noteCC}" maxFractionDigits="2" />
                                                    </c:if>
                                                </td>
                                                <td class="numeric">
                                                    <c:if test="${note.noteExam != null}">
                                                        <fmt:formatNumber value="${note.noteExam}" maxFractionDigits="2" />
                                                    </c:if>
                                                </td>
                                                <td class="numeric">
                                                    <strong>
                                                        <fmt:formatNumber value="${note.noteFinale}" maxFractionDigits="2" />
                                                    </strong>
                                                </td>
                                                <td>${note.mention}</td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="6" style="text-align: center; padding: 20px;">
                                                Aucune note enregistrée
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                    <!-- Results Summary -->
                    <div class="bulletin-result">
                        <div class="bulletin-result-item">
                            <div class="bulletin-result-label">Moyenne Générale</div>
                            <div class="bulletin-result-value">
                                <fmt:formatNumber value="${moyenneGenerale}" maxFractionDigits="2" />
                            </div>
                        </div>
                        <div class="bulletin-result-item">
                            <div class="bulletin-result-label">Taux Réussite</div>
                            <div class="bulletin-result-value">${tauxReussite}%</div>
                        </div>
                        <div class="bulletin-result-item">
                            <div class="bulletin-result-label">Mention</div>
                            <div class="bulletin-result-value" style="font-size: 16px;">
                                ${mentionGenerale}
                            </div>
                        </div>
                    </div>

                    <!-- Footer with Signatures -->
                    <div class="bulletin-footer">
                        <div class="signature-box">
                            <div class="signature-line">Directeur de Filière</div>
                        </div>
                        <div class="signature-box">
                            <div class="signature-line">Chef d'Établissement</div>
                        </div>
                    </div>
                </div>
            </c:if>

            <c:if test="${etudiant == null}">
                <div class="card">
                    <p style="text-align: center; color: var(--color-text-secondary);">
                        Aucun bulletin disponible pour votre compte.
                    </p>
                </div>
            </c:if>
        </div>
    </main>
</body>
</html>
