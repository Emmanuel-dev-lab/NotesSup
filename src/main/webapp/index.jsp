<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NotesSup - Système de Gestion des Notes</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <c:choose>
        <c:when test="${sessionScope.user != null}">
            <!-- Redirect to dashboard if already logged in -->
            <c:redirect url="/dashboard" />
        </c:when>
        <c:otherwise>
            <!-- Redirect to login page -->
            <c:redirect url="/login" />
        </c:otherwise>
    </c:choose>
</body>
</html>
