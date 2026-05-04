<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NotesSup — Connexion</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body {
            display: flex;
            background: var(--bg-app);
            min-height: 100vh;
            margin: 0;
        }

        .login-wrap {
            display: grid;
            grid-template-columns: 42% 58%;
            width: 100%;
            min-height: 100vh;
        }

        /* ── Left dark panel ── */
        .login-left {
            background: var(--sidebar-bg);
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 60px 52px;
            color: white;
        }

        .login-logo-row {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 48px;
        }

        .login-logo-box {
            width: 44px; height: 44px;
            background: var(--accent-blue);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-hero {
            font-size: 40px;
            font-weight: 700;
            letter-spacing: -0.5px;
            line-height: 1.1;
            margin-bottom: 16px;
        }

        .login-desc {
            font-size: 14px;
            color: oklch(0.68 0.04 252);
            line-height: 1.6;
            margin-bottom: 48px;
        }

        .login-stats {
            display: flex;
            gap: 32px;
        }

        .login-stat-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .login-stat-number {
            font-size: 28px;
            font-weight: 700;
            color: white;
            font-family: var(--font-mono);
        }

        .login-stat-label {
            font-size: 12px;
            color: oklch(0.55 0.04 252);
        }

        /* ── Right form panel ── */
        .login-right {
            background: var(--bg-app);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 48px 40px;
        }

        .login-card {
            background: white;
            border-radius: 16px;
            padding: 40px;
            width: 100%;
            max-width: 440px;
            box-shadow: 0 4px 24px oklch(0 0 0 / 0.08);
            border: 1px solid var(--border-light);
        }

        .login-card-title {
            font-size: 22px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 8px;
        }

        .login-card-sub {
            font-size: 13.5px;
            color: var(--text-secondary);
            margin-bottom: 28px;
        }

        .login-form-fields {
            display: flex;
            flex-direction: column;
            gap: 18px;
            margin-bottom: 24px;
        }

        .login-btn-submit {
            width: 100%;
            padding: 11px;
            background: var(--accent-blue);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            font-family: var(--font-base);
            transition: opacity var(--transition-fast);
        }
        .login-btn-submit:hover { opacity: 0.88; }

        .login-demo-section {
            margin-top: 24px;
            padding-top: 20px;
            border-top: 1px solid var(--border-light);
        }

        .login-demo-label {
            font-size: 11.5px;
            color: var(--text-muted);
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            font-weight: 600;
        }

        .login-demo-btns {
            display: flex;
            flex-direction: column;
            gap: 7px;
        }

        .login-demo-btn {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 9px 12px;
            background: var(--bg-row-alt);
            border: 1.5px solid var(--border-light);
            border-radius: 8px;
            cursor: pointer;
            font-size: 13px;
            color: var(--text-primary);
            font-family: var(--font-base);
            transition: background var(--transition-fast), border-color var(--transition-fast);
            width: 100%;
            text-align: left;
        }
        .login-demo-btn:hover {
            background: var(--border-light);
            border-color: var(--border-medium);
        }

        .login-demo-dot {
            width: 8px; height: 8px;
            border-radius: 50%;
            flex-shrink: 0;
        }

        .login-demo-info {
            flex: 1;
        }

        .login-demo-info strong {
            display: block;
            font-weight: 600;
        }

        .login-demo-info span {
            font-size: 11px;
            color: var(--text-muted);
        }

        .login-error {
            background: oklch(0.97 0.04 22);
            border: 1.5px solid oklch(0.80 0.14 22);
            border-radius: 8px;
            padding: 10px 14px;
            margin-bottom: 16px;
            font-size: 13px;
            color: oklch(0.45 0.18 22);
        }

        @media (max-width: 768px) {
            .login-wrap { grid-template-columns: 1fr; }
            .login-left { padding: 40px 32px; min-height: 260px; }
        }
    </style>
</head>
<body>
    <div class="login-wrap">
        <!-- Left: Dark hero panel -->
        <div class="login-left">
            <div class="login-logo-row">
                <div class="login-logo-box">
                    <svg width="24" height="24" viewBox="0 0 28 28" fill="none">
                        <rect x="2" y="2" width="11" height="11" rx="2" fill="white" fill-opacity="0.9"/>
                        <rect x="15" y="2" width="11" height="11" rx="2" fill="white" fill-opacity="0.5"/>
                        <rect x="2" y="15" width="11" height="11" rx="2" fill="white" fill-opacity="0.5"/>
                        <rect x="15" y="15" width="11" height="11" rx="2" fill="white" fill-opacity="0.2"/>
                    </svg>
                </div>
                <span style="font-size:18px; font-weight:700; letter-spacing:-0.2px;">NotesSup</span>
            </div>

            <div class="login-hero">Gestion des<br>Notes &amp; Bulletins</div>
            <p class="login-desc">
                Plateforme pédagogique pour l'enseignement supérieur.<br>
                Saisie des notes, délibérations, bulletins PDF.
            </p>

            <div class="login-stats">
                <div class="login-stat-item">
                    <span class="login-stat-number">500+</span>
                    <span class="login-stat-label">Étudiants</span>
                </div>
                <div class="login-stat-item">
                    <span class="login-stat-number">30+</span>
                    <span class="login-stat-label">Matières</span>
                </div>
                <div class="login-stat-item">
                    <span class="login-stat-number">5</span>
                    <span class="login-stat-label">Filières</span>
                </div>
            </div>
        </div>

        <!-- Right: Login form -->
        <div class="login-right">
            <div class="login-card">
                <div class="login-card-title">Connexion</div>
                <p class="login-card-sub">Entrez vos identifiants pour accéder au système</p>

                <c:if test="${error != null}">
                    <div class="login-error">
                        ⚠ ${error}
                    </div>
                </c:if>

                <form method="POST" action="${pageContext.request.contextPath}/login" id="loginForm">
                    <div class="login-form-fields">
                        <div class="form-group" style="margin-bottom:0;">
                            <label for="login">Identifiant</label>
                            <input type="text" id="login" name="login"
                                   placeholder="Votre identifiant"
                                   value="${param.login != null ? param.login : ''}"
                                   required autofocus>
                        </div>
                        <div class="form-group" style="margin-bottom:0;">
                            <label for="password">Mot de passe</label>
                            <input type="password" id="password" name="password"
                                   placeholder="••••••••" required>
                        </div>
                    </div>
                    <button type="submit" class="login-btn-submit">Se connecter</button>
                </form>

                <!-- Demo accounts -->
                <div class="login-demo-section">
                    <div class="login-demo-label">Comptes de démonstration</div>
                    <div class="login-demo-btns">
                        <button type="button" class="login-demo-btn"
                                onclick="fillDemo('chef','chef123')">
                            <span class="login-demo-dot" style="background:oklch(0.56 0.18 22);"></span>
                            <div class="login-demo-info">
                                <strong>Chef de département</strong>
                                <span>login: chef · mot de passe: chef123</span>
                            </div>
                        </button>
                        <button type="button" class="login-demo-btn"
                                onclick="fillDemo('enseignant','prof123')">
                            <span class="login-demo-dot" style="background:oklch(0.56 0.16 252);"></span>
                            <div class="login-demo-info">
                                <strong>Enseignant</strong>
                                <span>login: enseignant · mot de passe: prof123</span>
                            </div>
                        </button>
                        <button type="button" class="login-demo-btn"
                                onclick="fillDemo('etudiant','etud123')">
                            <span class="login-demo-dot" style="background:oklch(0.58 0.14 160);"></span>
                            <div class="login-demo-info">
                                <strong>Étudiant</strong>
                                <span>login: etudiant · mot de passe: etud123</span>
                            </div>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function fillDemo(login, password) {
            document.getElementById('login').value = login;
            document.getElementById('password').value = password;
        }
    </script>
</body>
</html>
