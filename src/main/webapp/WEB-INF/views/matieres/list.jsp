<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Matières — NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .matieres-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 16px;
        }

        .matiere-card {
            background: white;
            border-radius: 12px;
            border: 1px solid var(--border-light);
            box-shadow: var(--shadow-card);
            overflow: hidden;
        }

        .matiere-card-body {
            padding: 18px 20px;
        }

        .matiere-code-chip {
            display: inline-block;
            font-family: var(--font-mono);
            font-size: 12px;
            font-weight: 600;
            background: oklch(0.95 0.05 252);
            color: var(--accent-blue);
            padding: 3px 10px;
            border-radius: 6px;
            margin-bottom: 10px;
        }

        .matiere-intitule {
            font-size: 14.5px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 6px;
        }

        .matiere-enseignant {
            font-size: 12px;
            color: var(--text-muted);
            margin-bottom: 14px;
        }

        .matiere-card-footer {
            padding: 14px 20px;
            border-top: 1px solid var(--border-light);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .coeff-section {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .coeff-number {
            font-size: 22px;
            font-weight: 800;
            color: var(--accent-blue);
            font-family: var(--font-mono);
        }

        .coeff-bar {
            width: 60px;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/components/sidebar.jsp" />

    <main class="main">
        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1>Matières</h1>
                    <p class="subtitle">Gestion des matières par filière</p>
                </div>
                <div class="page-header-actions">
                    <c:if test="${sessionScope.user.role == 'CHEF_DEPT'}">
                        <a href="${pageContext.request.contextPath}/matieres?action=add" class="btn btn-primary">
                            + Ajouter matière
                        </a>
                    </c:if>
                </div>
            </div>

            <c:if test="${error != null}"><div class="alert alert-danger">${error}</div></c:if>
            <c:if test="${success != null}"><div class="alert alert-success">${success}</div></c:if>

            <!-- Filtres -->
            <form method="GET" action="${pageContext.request.contextPath}/matieres">
                <div class="toolbar" style="margin-bottom: 20px;">
                    <div class="search-bar">
                        <span class="search-bar-icon">⌕</span>
                        <input type="text" name="search"
                               placeholder="Rechercher une matière..."
                               value="${search != null ? search : ''}">
                    </div>
                    <select name="filiere">
                        <option value="">Toutes les filières</option>
                        <c:forEach var="f" items="${filieres}">
                            <option value="${f}" ${selectedFiliere == f ? 'selected' : ''}>${f}</option>
                        </c:forEach>
                    </select>
                    <button type="submit" class="btn btn-ghost">Filtrer</button>
                </div>
            </form>

            <!-- Matières Cards -->
            <c:choose>
                <c:when test="${matieres != null && matieres.size() > 0}">
                    <div class="matieres-grid">
                        <c:forEach var="m" items="${matieres}">
                            <div class="matiere-card">
                                <div class="matiere-card-body">
                                    <div style="display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:10px;">
                                        <span class="matiere-code-chip">${m.code}</span>
                                        <span class="badge badge-neutral">S${m.semestre}</span>
                                    </div>
                                    <div class="matiere-intitule">${m.intitule}</div>
                                    <div class="matiere-enseignant">
                                        ${m.enseignant != null ? m.enseignant : 'Enseignant non assigné'}
                                    </div>
                                    <span class="badge badge-info">${m.filiere}</span>
                                </div>
                                <div class="matiere-card-footer">
                                    <div class="coeff-section">
                                        <div class="coeff-number">${m.coefficient}</div>
                                        <div class="coeff-bar">
                                            <div class="progress-bar-track">
                                                <div class="progress-bar-fill"
                                                     style="width: ${m.coefficient * 10}%; background: var(--accent-blue);"></div>
                                            </div>
                                            <div style="font-size:10px; color:var(--text-muted); margin-top:3px;">coeff /10</div>
                                        </div>
                                    </div>
                                    <c:if test="${sessionScope.user.role == 'CHEF_DEPT'}">
                                        <div style="display:flex; gap:6px;">
                                            <a href="${pageContext.request.contextPath}/matieres?action=edit&id=${m.id}"
                                               class="btn btn-sm btn-ghost">✎</a>
                                            <a href="${pageContext.request.contextPath}/matieres?action=delete&id=${m.id}"
                                               class="btn btn-sm btn-danger"
                                               onclick="return confirm('Supprimer ${m.intitule} ?');">✕</a>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- Pagination -->
                    <c:if test="${totalPages > 1}">
                        <div class="pagination" style="margin-top: 30px;">
                            <c:if test="${currentPage > 1}">
                                <a href="?page=${currentPage - 1}${not empty search ? '&search='.concat(search) : ''}${not empty selectedFiliere ? '&filiere='.concat(selectedFiliere) : ''}" 
                                   class="btn btn-ghost">← Précédent</a>
                            </c:if>
                            
                            <div class="pagination-pages">
                                <c:forEach begin="1" end="${totalPages}" var="p">
                                    <a href="?page=${p}${not empty search ? '&search='.concat(search) : ''}${not empty selectedFiliere ? '&filiere='.concat(selectedFiliere) : ''}" 
                                       class="page-link ${p == currentPage ? 'active' : ''}">${p}</a>
                                </c:forEach>
                            </div>

                            <c:if test="${currentPage < totalPages}">
                                <a href="?page=${currentPage + 1}${not empty search ? '&search='.concat(search) : ''}${not empty selectedFiliere ? '&filiere='.concat(selectedFiliere) : ''}" 
                                   class="btn btn-ghost">Suivant →</a>
                            </c:if>
                        </div>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <div class="card" style="text-align:center; padding:48px;">
                        <div style="font-size:32px; margin-bottom:12px;">📚</div>
                        <p style="color:var(--text-secondary);">Aucune matière enregistrée</p>
                        <c:if test="${sessionScope.user.role == 'CHEF_DEPT'}">
                            <a href="${pageContext.request.contextPath}/matieres?action=add"
                               class="btn btn-primary" style="margin-top:16px;">Ajouter une matière</a>
                        </c:if>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</body>
</html>
