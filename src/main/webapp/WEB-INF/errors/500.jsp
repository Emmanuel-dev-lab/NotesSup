<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Erreur serveur - NotesSup</title>
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
            color: var(--color-danger);
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

        .error-details {
            background-color: var(--color-bg-hover);
            padding: 20px;
            border-radius: 8px;
            text-align: left;
            margin-top: 30px;
            font-family: 'DM Mono', monospace;
            font-size: 12px;
            color: var(--color-text-secondary);
            max-height: 200px;
            overflow-y: auto;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <h1 class="error-code">500</h1>
        <h2 class="error-message">Erreur serveur interne</h2>
        <p class="error-description">
            Une erreur interne est survenue. Nos équipes techniques ont été notifiées.
            Veuillez réessayer plus tard.
        </p>
        <div class="error-actions">
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
                Accueil
            </a>
            <a href="javascript:history.back()" class="btn btn-secondary">
                Retour
            </a>
        </div>

        <%
            Throwable exception = (Throwable) request.getAttribute("javax.servlet.error.exception");
            if (exception != null) {
        %>
        <div class="error-details">
            <strong>Détails techniques (développement):</strong><br>
            <%= exception.getMessage() %>
            <br><br>
            <%
                java.io.StringWriter sw = new java.io.StringWriter();
                java.io.PrintWriter pw = new java.io.PrintWriter(sw);
                exception.printStackTrace(pw);
                String stackTrace = sw.toString();
                if (stackTrace.length() > 500) {
                    out.print(stackTrace.substring(0, 500) + "...");
                } else {
                    out.print(stackTrace);
                }
            %>
        </div>
        <% } %>
    </div>
</body>
</html>
