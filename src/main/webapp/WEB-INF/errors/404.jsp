<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page non trouvée - NotesSup</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
        }

        .error-container {
            text-align: center;
            max-width: 500px;
        }

        .error-code {
            font-size: 120px;
            font-weight: bold;
            color: var(--color-primary);
            margin: 0;
            line-height: 1;
        }

        .error-message {
            font-size: 24px;
            color: var(--color-text-primary);
            margin: 20px 0;
        }

        .error-description {
            color: var(--color-text-secondary);
            margin-bottom: 40px;
        }

        .error-actions {
            display: flex;
            gap: 10px;
            justify-content: center;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <h1 class="error-code">404</h1>
        <h2 class="error-message">Page non trouvée</h2>
        <p class="error-description">
            La page que vous recherchez n'existe pas ou a été déplacée.
        </p>
        <div class="error-actions">
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
                Accueil
            </a>
            <a href="javascript:history.back()" class="btn btn-secondary">
                Retour
            </a>
        </div>
    </div>
</body>
</html>
