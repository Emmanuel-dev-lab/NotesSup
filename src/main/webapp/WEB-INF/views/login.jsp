<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NotesSup - Connexion</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            background-color: var(--color-sidebar-bg);
            margin: 0;
        }

        .login-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            width: 90%;
            max-width: 900px;
            min-height: 500px;
            border-radius: var(--radius-lg);
            overflow: hidden;
            box-shadow: var(--shadow-xl);
        }

        .login-sidebar {
            background-color: var(--color-sidebar-bg);
            color: white;
            padding: var(--space-12);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
        }

        .login-sidebar h1 {
            font-size: var(--text-2xl);
            margin-bottom: var(--space-4);
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        .login-sidebar p {
            color: rgba(255, 255, 255, 0.8);
            margin-bottom: var(--space-8);
        }

        .login-card {
            background-color: var(--color-bg-card);
            padding: var(--space-12);
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .login-card h2 {
            font-size: var(--text-xl);
            margin-bottom: var(--space-8);
            color: var(--color-text-primary);
        }

        .login-form {
            display: flex;
            flex-direction: column;
            gap: var(--space-6);
        }

        @media (max-width: 768px) {
            .login-container {
                grid-template-columns: 1fr;
                min-height: auto;
            }

            .login-sidebar {
                padding: var(--space-8);
                min-height: 200px;
            }

            .login-card {
                padding: var(--space-8);
            }
        }
    </style>
</head>
<body>
    <div class="login-container">
        <!-- Left: Dark Sidebar -->
        <div class="login-sidebar">
            <h1>NotesSup</h1>
            <p>Système de Gestion des Notes & Bulletins</p>
            <p style="font-size: var(--text-sm); color: rgba(255, 255, 255, 0.6);">
                Connectez-vous avec vos identifiants pour accéder au système.
            </p>
        </div>

        <!-- Right: Login Form -->
        <div class="login-card">
            <h2>Connexion</h2>

            <c:if test="${error != null}">
                <div class="alert alert-danger">
                    ${error}
                </div>
            </c:if>

            <form method="POST" action="${pageContext.request.contextPath}/login" class="login-form">
                <div class="form-group">
                    <label for="login">Identifiant</label>
                    <input type="text" id="login" name="login" required autofocus>
                </div>

                <div class="form-group">
                    <label for="password">Mot de passe</label>
                    <input type="password" id="password" name="password" required>
                </div>

                <button type="submit" class="btn btn-primary" style="margin-top: var(--space-4);">
                    Se connecter
                </button>

                <div style="text-align: center; margin-top: var(--space-4); color: var(--color-text-secondary); font-size: var(--text-sm);">
                    <p>Identifiants de démonstration disponibles</p>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
