<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="fr">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Bulletin de notes — NotesSup</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
                <style>
                    @media print {
                        .no-print {
                            display: none !important;
                        }

                        .main {
                            margin-left: 0 !important;
                        }

                        .sidebar {
                            display: none !important;
                        }

                        .page-content {
                            padding: 0 !important;
                        }

                        .bulletin-page {
                            box-shadow: none !important;
                        }
                    }

                    .bulletin-page {
                        max-width: 210mm;
                        min-height: 297mm;
                        margin: 0 auto;
                        padding: 24mm 20mm;
                        background: white;
                        box-shadow: var(--shadow-modal);
                        border-radius: 12px;
                        font-family: var(--font-base);
                    }

                    .bulletin-logos {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        margin-bottom: 24px;
                    }

                    .bulletin-logo-box {
                        width: 70px;
                        height: 70px;
                        border: 2px dashed var(--border-medium);
                        border-radius: 8px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: var(--text-muted);
                        font-size: 11px;
                        text-align: center;
                    }

                    .bulletin-center-info {
                        text-align: center;
                        flex: 1;
                        padding: 0 20px;
                    }

                    .bulletin-univ {
                        font-size: 13px;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: 0.05em;
                        color: var(--text-primary);
                    }

                    .bulletin-dept {
                        font-size: 11.5px;
                        color: var(--text-secondary);
                        margin-top: 4px;
                    }

                    .bulletin-title {
                        font-size: 20px;
                        font-weight: 800;
                        text-transform: uppercase;
                        color: var(--sidebar-bg);
                        margin-top: 10px;
                        letter-spacing: 0.03em;
                    }

                    .bulletin-session-info {
                        font-size: 12px;
                        color: var(--text-muted);
                        margin-top: 4px;
                    }

                    .bulletin-student-grid {
                        display: grid;
                        grid-template-columns: repeat(3, 1fr);
                        gap: 0;
                        margin: 20px 0;
                        border: 1px solid var(--border-light);
                        border-radius: 8px;
                        overflow: hidden;
                        font-size: 12.5px;
                    }

                    .bulletin-student-cell {
                        padding: 8px 12px;
                        border-right: 1px solid var(--border-light);
                        border-bottom: 1px solid var(--border-light);
                    }

                    .bulletin-student-cell:nth-child(3n) {
                        border-right: none;
                    }

                    .bulletin-student-cell:nth-last-child(-n+3) {
                        border-bottom: none;
                    }

                    .bulletin-key {
                        font-size: 11px;
                        color: var(--text-muted);
                        font-weight: 600;
                        text-transform: uppercase;
                        margin-bottom: 3px;
                        letter-spacing: 0.05em;
                    }

                    .bulletin-val {
                        font-weight: 600;
                        color: var(--text-primary);
                    }

                    .bulletin-table thead th {
                        background: var(--sidebar-bg) !important;
                        color: white !important;
                        padding: 10px 12px;
                        font-size: 11.5px;
                    }

                    .bulletin-table tbody td {
                        padding: 9px 12px;
                        font-size: 12.5px;
                    }

                    .bulletin-table tbody tr:nth-child(even) {
                        background: var(--bg-row-alt);
                    }

                    .bulletin-total-row td {
                        background: var(--sidebar-bg) !important;
                        color: white !important;
                        font-weight: 700;
                        padding: 10px 12px;
                    }

                    .bulletin-result-banner {
                        padding: 20px 24px;
                        border-radius: 8px;
                        margin-top: 20px;
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                    }

                    .bulletin-result-banner.admis {
                        background: oklch(0.96 0.06 160);
                        border: 1px solid oklch(0.80 0.12 160);
                    }

                    .bulletin-result-banner.ajoune {
                        background: oklch(0.96 0.07 22);
                        border: 1px solid oklch(0.80 0.14 22);
                    }

                    .bulletin-signatures {
                        display: grid;
                        grid-template-columns: repeat(3, 1fr);
                        gap: 24px;
                        margin-top: 40px;
                    }

                    .signature-zone {
                        text-align: center;
                        padding-top: 48px;
                        border-top: 1px solid var(--text-primary);
                        font-size: 12px;
                        color: var(--text-secondary);
                    }

                    .locked-screen {
                        text-align: center;
                        padding: 80px 24px;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

                <main class="main">
                    <div class="page-content">
                        <div class="page-header no-print">
                            <div>
                                <h1>Bulletin de notes</h1>
                                <p class="subtitle">Relevé de notes académiques officiel</p>
                            </div>
                            <div class="page-header-actions">
                                <!-- Sélecteur élève (chef/enseignant) -->
                                <form method="GET" action="${pageContext.request.contextPath}/bulletins"
                                    style="display:flex; gap:8px; align-items: center;">
                                    <input type="text" name="annee"
                                        value="${anneeAcademique != null ? anneeAcademique : '2025-2026'}"
                                        placeholder="Année (ex: 2025-2026)"
                                        style="width: 120px; padding:9px 12px; border-radius:8px; border:1.5px solid var(--border-medium); font-family:var(--font-base);" />
                                        
                                    <c:if test="${sessionScope.user.role != 'ETUDIANT'}">
                                        <select name="etudiantId"
                                            style="padding:9px 12px; border-radius:8px; border:1.5px solid var(--border-medium); font-family:var(--font-base);">
                                            <option value="">— Sélectionner un étudiant —</option>
                                            <c:forEach var="e" items="${etudiants}">
                                                <option value="${e.id}" ${selectedEtudiantId==e.id ? 'selected' : '' }>
                                                    ${e.nom} ${e.prenom} (${e.matricule})</option>
                                            </c:forEach>
                                        </select>
                                    </c:if>
                                    <c:if test="${sessionScope.user.role == 'ETUDIANT'}">
                                        <input type="hidden" name="etudiantId" value="${sessionScope.user.etudiantId}" />
                                    </c:if>
                                    
                                    <select name="session"
                                        style="padding:9px 12px; border-radius:8px; border:1.5px solid var(--border-medium); font-family:var(--font-base);">
                                        <option value="NORMALE" ${selectedSession=='NORMALE' ? 'selected' : '' }>
                                            Session Normale</option>
                                        <option value="RATTRAPAGE" ${selectedSession=='RATTRAPAGE' ? 'selected' : ''
                                            }>Rattrapage</option>
                                    </select>
                                    <button type="submit" class="btn btn-ghost">Afficher</button>
                                </form>
                                <c:if test="${etudiant != null}">
                                    <button class="btn btn-ghost" onclick="window.print();">🖨 Imprimer</button>
                                    <a href="${pageContext.request.contextPath}/bulletins?format=pdf${selectedEtudiantId != null ? '&etudiantId='.concat(selectedEtudiantId) : ''}&session=${selectedSession}&annee=${anneeAcademique}"
                                        class="btn btn-primary">↓ Télécharger PDF</a>
                                </c:if>
                            </div>
                        </div>

                        <c:if test="${error != null}">
                            <div class="alert alert-danger no-print">${error}</div>
                        </c:if>

                        <!-- Locked for student if not published -->
                        <c:if test="${locked}">
                            <div class="card locked-screen">
                                <div style="font-size:48px; margin-bottom:16px;">🔒</div>
                                <div
                                    style="font-size:18px; font-weight:700; color:var(--text-primary); margin-bottom:8px;">
                                    Bulletin non disponible
                                </div>
                                <p style="color:var(--text-secondary);">
                                    Les résultats de votre filière n'ont pas encore été publiés par le chef de
                                    département.
                                </p>
                            </div>
                        </c:if>

                        <!-- Bulletin -->
                        <c:if test="${etudiant != null && !locked}">
                            <div class="bulletin-page">
                                <!-- Logos + Header -->
                                <div class="bulletin-logos">
                                    <div class="bulletin-logo-box">Logo<br>Univ.</div>
                                    <div class="bulletin-center-info">
                                        <div class="bulletin-univ">Université de l'ICT</div>
                                        <div class="bulletin-dept">UFR Sciences &amp; Technologies · Département
                                            Informatique</div>
                                        <div class="bulletin-title">Bulletin de Notes</div>
                                        <div class="bulletin-session-info">
                                            Session ${selectedSession != null ? selectedSession : 'Normale'} —
                                            Année académique ${anneeAcademique != null ? anneeAcademique : '—'}
                                        </div>
                                    </div>
                                    <div class="bulletin-logo-box">Logo<br>Dépt.</div>
                                </div>

                                <!-- Student info grid -->
                                <div class="bulletin-student-grid">
                                    <div class="bulletin-student-cell">
                                        <div class="bulletin-key">Nom</div>
                                        <div class="bulletin-val">${etudiant.nom}</div>
                                    </div>
                                    <div class="bulletin-student-cell">
                                        <div class="bulletin-key">Prénom</div>
                                        <div class="bulletin-val">${etudiant.prenom}</div>
                                    </div>
                                    <div class="bulletin-student-cell">
                                        <div class="bulletin-key">Matricule</div>
                                        <div class="bulletin-val" style="font-family:var(--font-mono);">
                                            ${etudiant.matricule}</div>
                                    </div>
                                    <div class="bulletin-student-cell">
                                        <div class="bulletin-key">Filière</div>
                                        <div class="bulletin-val">${etudiant.filiere}</div>
                                    </div>
                                    <div class="bulletin-student-cell">
                                        <div class="bulletin-key">Année</div>
                                        <div class="bulletin-val">Licence ${etudiant.annee}</div>
                                    </div>
                                    <div class="bulletin-student-cell">
                                        <div class="bulletin-key">Téléphone</div>
                                        <div class="bulletin-val" style="font-family:var(--font-mono);">
                                            ${etudiant.telephone != null ? etudiant.telephone : '—'}</div>
                                    </div>
                                </div>

                                <!-- Notes table -->
                                <table class="bulletin-table"
                                    style="width:100%; border-collapse:collapse; margin-bottom:0;">
                                    <thead>
                                        <tr>
                                            <th>Code</th>
                                            <th>Matière</th>
                                            <th>Coeff.</th>
                                            <th>CC</th>
                                            <th>Examen</th>
                                            <th>Moyenne</th>
                                            <th>Points</th>
                                            <th>Mention</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:set var="totalPoints" value="0" />
                                        <c:set var="totalCoeff" value="0" />
                                        <c:choose>
                                            <c:when test="${notes != null && notes.size() > 0}">
                                                <c:forEach var="note" items="${notes}">
                                                    <tr>
                                                        <td
                                                            style="font-family:var(--font-mono); color:var(--accent-blue); font-size:12px;">
                                                            ${note.matiere.code}</td>
                                                        <td>${note.matiere.intitule}</td>
                                                        <td style="font-family:var(--font-mono); text-align:center;">
                                                            ${note.matiere.coefficient}</td>
                                                        <td style="font-family:var(--font-mono); text-align:right;">
                                                            <c:if test="${note.noteCC != null}">
                                                                <fmt:formatNumber value="${note.noteCC}"
                                                                    maxFractionDigits="2" />
                                                            </c:if>
                                                        </td>
                                                        <td style="font-family:var(--font-mono); text-align:right;">
                                                            <c:if test="${note.noteExam != null}">
                                                                <fmt:formatNumber value="${note.noteExam}"
                                                                    maxFractionDigits="2" />
                                                            </c:if>
                                                        </td>
                                                        <td style="font-family:var(--font-mono); text-align:right; font-weight:700;
                                                color: ${note.noteFinale >= 16 ? '#059669' :
                                                         note.noteFinale >= 14 ? '#0891b2' :
                                                         note.noteFinale >= 12 ? '#7c3aed' :
                                                         note.noteFinale >= 10 ? '#d97706' : '#dc2626'};">
                                                            <c:if test="${note.noteFinale != null}">
                                                                <fmt:formatNumber value="${note.noteFinale}"
                                                                    maxFractionDigits="2" />
                                                            </c:if>
                                                        </td>
                                                        <td style="font-family:var(--font-mono); text-align:right;">
                                                            <c:if
                                                                test="${note.noteFinale != null && note.matiere != null}">
                                                                <fmt:formatNumber
                                                                    value="${note.noteFinale * note.matiere.coefficient}"
                                                                    maxFractionDigits="2" />
                                                            </c:if>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${note.noteFinale >= 16}">Très Bien
                                                                </c:when>
                                                                <c:when test="${note.noteFinale >= 14}">Bien</c:when>
                                                                <c:when test="${note.noteFinale >= 12}">Assez Bien
                                                                </c:when>
                                                                <c:when test="${note.noteFinale >= 10}">Passable
                                                                </c:when>
                                                                <c:when test="${note.noteFinale != null}">Ajourné(e)
                                                                </c:when>
                                                            </c:choose>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="8"
                                                        style="text-align:center; padding:20px; color:var(--text-muted);">
                                                        Aucune note enregistrée</td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                    <tfoot>
                                        <tr class="bulletin-total-row">
                                            <td colspan="2">TOTAL / MOYENNE</td>
                                            <td style="font-family:var(--font-mono); text-align:center;">
                                                <c:if test="${totalCoefficients > 0}">${totalCoefficients}</c:if></td>
                                            <td></td>
                                            <td></td>
                                            <td style="font-family:var(--font-mono); text-align:right;">
                                                <c:if test="${moyenneGenerale != null}">
                                                    <fmt:formatNumber value="${moyenneGenerale}" maxFractionDigits="2" />
                                                </c:if>
                                            </td>
                                            <td style="font-family:var(--font-mono); text-align:right;">
                                                <c:if test="${totalPoints > 0}">
                                                    <fmt:formatNumber value="${totalPoints}" maxFractionDigits="2" />
                                                </c:if>
                                            </td>
                                            <td></td>
                                        </tr>
                                    </tfoot>
                                </table>

                                <!-- Result banner -->
                                <c:if test="${moyenneGenerale != null}">
                                    <div class="bulletin-result-banner ${moyenneGenerale >= 10 ? 'admis' : 'ajoune'}">
                                        <div>
                                            <div
                                                style="font-size:13px; <c:choose><c:when test='${moyenneGenerale >= 10}'>color:oklch(0.28 0.14 160);</c:when><c:otherwise>color:oklch(0.35 0.18 22);</c:otherwise></c:choose>">
                                                Moyenne générale
                                            </div>
                                            <div
                                                style="font-size:24px; font-weight:800; font-family:var(--font-mono);
                                    <c:choose><c:when test='${moyenneGenerale >= 10}'>color:oklch(0.28 0.14 160);</c:when><c:otherwise>color:oklch(0.35 0.18 22);</c:otherwise></c:choose>">
                                                <fmt:formatNumber value="${moyenneGenerale}" maxFractionDigits="2" />/20
                                                &nbsp;
                                                <c:choose>
                                                    <c:when test="${moyenneGenerale >= 16}">Très Bien</c:when>
                                                    <c:when test="${moyenneGenerale >= 14}">Bien</c:when>
                                                    <c:when test="${moyenneGenerale >= 12}">Assez Bien</c:when>
                                                    <c:when test="${moyenneGenerale >= 10}">Passable</c:when>
                                                    <c:otherwise>Insuffisant</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                        <div
                                            style="font-size:18px; font-weight:800;
                                <c:choose><c:when test='${moyenneGenerale >= 10}'>color:oklch(0.28 0.14 160);</c:when><c:otherwise>color:oklch(0.35 0.18 22);</c:otherwise></c:choose>">
                                            <c:choose>
                                                <c:when test="${moyenneGenerale >= 10}">✓ ADMIS(E)</c:when>
                                                <c:otherwise>✗ AJOURNÉ(E)</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </c:if>

                                <!-- Signatures -->
                                <div class="bulletin-signatures">
                                    <div class="signature-zone">Directeur de Filière</div>
                                    <div class="signature-zone">Chef de Département</div>
                                    <div class="signature-zone">Directeur des Études</div>
                                </div>

                                <div
                                    style="text-align:center; margin-top:24px; font-size:11px; color:var(--text-muted);">
                                    Généré par NotesSup · ICT 423 ·
                                    <fmt:formatDate value="<%= new java.util.Date() %>" pattern="dd/MM/yyyy" />
                                </div>
                            </div>
                        </c:if>

                        <!-- No bulletin selected -->
                        <c:if test="${etudiant == null && !locked}">
                            <div class="card" style="text-align:center; padding:64px;">
                                <div style="font-size:40px; margin-bottom:16px;">📄</div>
                                <div
                                    style="font-size:16px; font-weight:700; color:var(--text-primary); margin-bottom:8px;">
                                    Sélectionner un étudiant
                                </div>
                                <p style="color:var(--text-secondary);">
                                    Choisissez un étudiant dans le sélecteur ci-dessus pour afficher son bulletin.
                                </p>
                            </div>
                        </c:if>
                    </div>
                </main>
            </body>

            </html>