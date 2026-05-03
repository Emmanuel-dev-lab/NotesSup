<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- Page Header -->
<header class="page-header">
    <div class="flex-between">
        <div>
            <h1>${title != null ? title : 'Dashboard'}</h1>
            <c:if test="${subtitle != null}">
                <p>${subtitle}</p>
            </c:if>
        </div>
        <c:if test="${showActions == 'true'}">
            <div style="display: flex; gap: var(--space-4);">
                <c:if test="${createAction != null}">
                    <a href="${createAction}" class="btn btn-primary">Ajouter</a>
                </c:if>
                <c:if test="${exportAction != null}">
                    <a href="${exportAction}" class="btn btn-ghost">Exporter</a>
                </c:if>
            </div>
        </c:if>
    </div>
</header>
