# 🎓 NotesSup — Système de Gestion de Notes Universitaire

![NotesSup Banner](https://img.shields.io/badge/Release-v1.0--SNAPSHOT-blue?style=for-the-badge)
![Jakarta EE](https://img.shields.io/badge/Jakarta_EE-11-blueviolet?style=for-the-badge)
![Java](https://img.shields.io/badge/Java-21-orange?style=for-the-badge)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?style=for-the-badge&logo=mysql)

**NotesSup** est une application web moderne de gestion académique développée pour l'Université de l'ICT. Elle permet de centraliser la gestion des étudiants, des matières, des notes et des délibérations avec une architecture robuste et sécurisée.

---

## 🚀 Fonctionnalités Clés

- **Gestion des Étudiants :** CRUD complet, recherche par matricule, pagination.
- **Gestion des Matières :** Organisation par filière et semestre, coefficients modulables.
- **Saisie des Notes :** Calcul automatique des moyennes finales (40% CC, 60% Examen).
- **Délibérations :** Publication officielle des résultats, blocage des bulletins avant délibération.
- **Reporting Avancé :** Génération de bulletins individuels en PDF et PV de délibération via iText 8.
- **Sécurité :** RBAC (Role-Based Access Control) avec 3 niveaux d'accès, mots de passe hachés (BCrypt).

---

## 🛠️ Stack Technique

- **Core :** Jakarta EE 11 (Servlets 6.1, JSP 3.1)
- **Langage :** Java 21
- **Base de Données :** MySQL 8.0
- **Build Tool :** Maven
- **PDF Engine :** iText 8.0.2
- **Sécurité :** jBCrypt, Authentication & Authorization Filters

---

## 📦 Prérequis

Avant de commencer, assurez-vous d'avoir installé :
- [Java JDK 21](https://www.oracle.com/java/technologies/downloads/#java21)
- [Apache Maven 3.9+](https://maven.apache.org/download.cgi)
- [Docker & Docker Compose](https://docs.docker.com/get-docker/) (recommandé pour la base de données)
- Un serveur d'application compatible Jakarta EE 11 (ex: [Apache Tomcat 11](https://tomcat.apache.org/download-11.cgi))

---

## 💾 Configuration de la Base de Données

Vous avez deux options pour configurer l'environnement MySQL.

### Option A : Utiliser Docker Compose (Recommandé)

Cette méthode est la plus rapide et configure automatiquement le schéma et les données de test.

1. Lancez le service :
   ```bash
   docker compose up -d
   ```
2. La base de données sera accessible sur `localhost:3306` avec les accès suivants :
   - **Database :** `notessup_db`
   - **User :** `notessup_user`
   - **Password :** `notessup_pass`

### Option B : Installation Locale

Si vous préférez installer MySQL manuellement :

1. Créez la base de données :
   ```sql
   CREATE DATABASE notessup_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```
2. Créez l'utilisateur et donnez-lui les droits :
   ```sql
   CREATE USER 'notessup_user'@'localhost' IDENTIFIED BY 'notessup_pass';
   GRANT ALL PRIVILEGES ON notessup_db.* TO 'notessup_user'@'localhost';
   FLUSH PRIVILEGES;
   ```
3. Importez le schéma initial :
   ```bash
   mysql -u notessup_user -p notessup_db < db/schema.sql
   ```

---

## 🛠️ Compilation et Exécution

1. **Compilation du projet :**
   ```bash
   mvn clean package
   ```
   Cela générera un fichier `NotesSup.war` dans le dossier `target/`.

2. **Déploiement :**
   - Copiez `target/NotesSup.war` dans le dossier `webapps/` de votre serveur Tomcat 11.
   - Démarrez Tomcat.

3. **Accès Web :**
   L'application sera disponible sur `http://localhost:8080/NotesSup`.

---

## 🔐 Comptes de Test

Utilisez les identifiants suivants pour tester les différents rôles.
**Mot de passe commun :** `root123`

| Rôle | Login | Nom de démonstration |
| :--- | :--- | :--- |
| **Chef de Département** | `chef` | Prof. Jean-Claude Atangana |
| **Enseignant** | `mabena` | Dr. Michel Abena |
| **Étudiant** | `labena` | Luc Abena |

---

## 📁 Structure du Projet

```text
NotesSup/
├── db/                       # Scripts SQL d'initialisation
├── docs/                     # Spécifications et documentation design
├── src/main/java/            # Code source Java (Logic & Data Access)
│   ├── org.ict4d.notessup
│   │   ├── dao/              # Couche d'accès aux données (JDBC)
│   │   ├── filters/          # Sécurité et Authentification
│   │   ├── models/           # Entités métier
│   │   ├── services/         # Logique métier et PDF
│   │   ├── servlets/         # Contrôleurs Web
│   │   └── utils/            # Utilitaires (DBConnection, Constants)
├── src/main/webapp/          # Ressources Web (JSP, CSS, JS)
│   ├── WEB-INF/views/        # Vues privées
│   ├── css/                  # Styles modernes (Vanilla CSS)
│   └── js/                   # Scripts frontend
├── docker-compose.yml        # Orchestration MySQL
└── pom.xml                   # Configuration Maven
```

---

## 📄 Licence

Ce projet est réalisé dans le cadre du cours **ICT 423**. 
Usage académique uniquement.
