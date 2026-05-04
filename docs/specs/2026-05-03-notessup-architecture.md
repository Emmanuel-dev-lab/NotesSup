# NotesSup — Spécification Architecture & Implémentation

**Date:** 2026-05-03  
**Projet:** NotesSup — Module Notes & Bulletins (ICT 423)  
**Scope:** Implémentation complète Jakarta EE 11 — application déployable, fonctionnelle.

---

## Décisions architecturales

### Stack technique
- **Runtime:** Jakarta EE 11 (servlet 6.0)
- **Language:** Java 11+
- **Build:** Maven WAR
- **Database:** MySQL 8 (Docker)
- **View:** JSP avec JSTL
- **Template styling:** CSS3 (design tokens du README design handoff)

### Pattern architectural — Vertical par entité
Chaque entité métier (Étudiant, Matière, Note, Délibération) suit pattern identique:
```
Model (POJO)
  ↓
DAO (JDBC PreparedStatement + interface)
  ↓
Service (logique métier, validations)
  ↓
Servlet (dispatcher HTTP → JSP ou JSON)
  ↓
JSPs (list, add/edit, detail) — rendu HTML
```

**BaseDAO abstrait** réutilisable pour CRUD standard.

### Sécurité
- **Auth:** Session HTTP + filter (AuthenticationFilter)
- **Autorisation:** Filtre par rôle (AuthorizationFilter) — 3 rôles: CHEF_DEPT, ENSEIGNANT, ETUDIANT
- **Password:** BCrypt (jBCrypt)
- **Headers:** X-Frame-Options, X-Content-Type-Options (SecurityHeaderFilter)
- **SQL:** PreparedStatement obligatoire, no string concatenation

---

## Modèle de données

**5 entités principales** (voir theme.md):

| Entité | Fields | CRUD | Validations |
|--------|--------|------|---|
| **User** | id, login, password, role, nom, filiere?, etudiantId? | C-U-D (auth) | login unique, pwd bcrypt |
| **Étudiant** | id, matricule, nom, prenom, filiere, annee (1-5), telephone | ✓ | matricule unique, annee range |
| **Matière** | id, code, intitule, coeff, enseignant, semestre, filiere | ✓ | code unique, coeff 1-6 |
| **Note** | id, etudiant_id, matiere_id, noteCC, noteExam, noteFinale, session, anneeAcad, saisiePar | ✓ | uk(etudiant+matiere+session+annee), noteFinale calc |
| **Délibération** | id, filiere, session, anneeAcad, publiee, datePublication, publiePar | U-D (création auto) | déclenchée par publication |

---

## Fonctionnalités à implémenter

### Authentification & Autorisation (Feat. 1-3, 13-14)
- Login form → valider user + role → session HTTP
- 3 rôles: Chef Dept | Enseignant | Étudiant — permissions granulaires (cf. design handoff)
- BCrypt password hashing
- Filtre authorization sur chaque endpoint sensible
- Security headers sur toutes réponses HTTP

### CRUD complet (Feat. 4-6)
- Étudiants: list (paginated) + add + edit + delete + search
- Matières: list + add + edit + delete + filtre filière/semestre
- Notes: list (tableau/grille) + edit inline ou modal + auto-calcul noteFinale
- Délibérations: list + publier (toggle + SMS) + voir PV

### Avancées (Feat. 7-12, 15-16)
- **PDF** (iText 7): Bulletin individuel + PV délibération + rapport stats
- **SMS** (SMSLib ou simulé): notifications publication notes + alertes danger
- **Pagination:** LIMIT/OFFSET, 6 lignes par page
- **Recherche:** SQL LIKE sur matricule/nom matière
- **Export CSV:** liste étudiants ou notes
- **Upload fichiers:** (optionnel, structure prête)
- **Statistiques:** SQL GROUP BY/AVG/COUNT, classements, mentions
- **Pages d'erreur:** 404, 500 déclarées web.xml

### Dashboard & Rapports (Feat. 10, 26-136)
- **Chef Dept:** KPI cards + grille résultats par filière + alertes étudiants
- **Enseignant:** ses notes, ses étudiants
- **Étudiant:** son bulletin (bloqué si délibération non publiée), ses stats

---

## Structure fichiers cible

```
NotesSup/
├── pom.xml                           # dépendances (iText, SMSLib, jBCrypt, etc.)
├── docker-compose.yml                # MySQL 8 service
├── db/
│   └── schema.sql                    # CREATE TABLE + INSERTS demo
├── src/main/
│   ├── java/org/ict4d/notessup/
│   │   ├── models/
│   │   │   ├── User.java
│   │   │   ├── Etudiant.java
│   │   │   ├── Matiere.java
│   │   │   ├── Note.java
│   │   │   └── Deliberation.java
│   │   ├── dao/
│   │   │   ├── BaseDAO.java          # abstraction PreparedStatement
│   │   │   ├── UserDAO.java
│   │   │   ├── EtudiantDAO.java
│   │   │   ├── MatiereDAO.java
│   │   │   ├── NoteDAO.java
│   │   │   └── DeliberationDAO.java
│   │   ├── services/
│   │   │   ├── AuthService.java      # BCrypt + session validation
│   │   │   ├── NoteService.java      # calc noteFinale, mention, taux réussite
│   │   │   ├── PDFService.java       # iText 7
│   │   │   └── SMSService.java
│   │   ├── servlets/
│   │   │   ├── LoginServlet.java     # POST login
│   │   │   ├── LogoutServlet.java    # clear session
│   │   │   ├── EtudiantServlet.java  # GET list + POST/PUT/DELETE
│   │   │   ├── MatiereServlet.java
│   │   │   ├── NoteServlet.java
│   │   │   ├── DeliberationServlet.java
│   │   │   ├── BulletinServlet.java  # GET bulletin + PDF
│   │   │   ├── StatistiquesServlet.java
│   │   │   ├── ExportServlet.java    # CSV
│   │   │   └── DashboardServlet.java
│   │   ├── filters/
│   │   │   ├── AuthenticationFilter.java
│   │   │   ├── AuthorizationFilter.java
│   │   │   └── SecurityHeaderFilter.java
│   │   └── utils/
│   │       ├── DBConnection.java     # pool JDBC
│   │       ├── ValidationUtils.java
│   │       └── Constants.java
│   └── webapp/
│       ├── WEB-INF/web.xml           # servlet + filter mappings, error pages
│       ├── WEB-INF/vues/
│       │   ├── login.jsp
│       │   ├── dashboard.jsp
│       │   ├── etudiants/list.jsp, add.jsp, edit.jsp
│       │   ├── matieres/list.jsp, add.jsp, edit.jsp
│       │   ├── notes/list.jsp, grille.jsp
│       │   ├── deliberations/list.jsp, pv.jsp
│       │   ├── statistiques/index.jsp
│       │   ├── bulletins/index.jsp (HTML rendu + PDF)
│       │   ├── 404.jsp, 500.jsp
│       │   └── components/ (header, sidebar, footer JSPs)
│       ├── css/style.css              # design tokens (couleurs, typo, ombres)
│       └── js/app.js                  # validation forms, modals légers
└── docs/
    └── specs/ (ce fichier)
```

---

## Web.xml mapping — Déclaration servlets obligatoire

```xml
<!-- Filters -->
<filter>
  <filter-name>AuthenticationFilter</filter-name>
  <filter-class>org.ict4d.notessup.filters.AuthenticationFilter</filter-class>
</filter>
<filter-mapping>
  <filter-name>AuthenticationFilter</filter-name>
  <url-pattern>/*</url-pattern>
</filter-mapping>

<filter>
  <filter-name>AuthorizationFilter</filter-name>
  <filter-class>org.ict4d.notessup.filters.AuthorizationFilter</filter-class>
</filter>
<filter-mapping>
  <filter-name>AuthorizationFilter</filter-name>
  <url-pattern>/secured/*</url-pattern>
</filter-mapping>

<filter>
  <filter-name>SecurityHeaderFilter</filter-name>
  <filter-class>org.ict4d.notessup.filters.SecurityHeaderFilter</filter-class>
</filter>
<filter-mapping>
  <filter-name>SecurityHeaderFilter</filter-name>
  <url-pattern>/*</url-pattern>
</filter-mapping>

<!-- Servlets -->
<servlet>
  <servlet-name>LoginServlet</servlet-name>
  <servlet-class>org.ict4d.notessup.servlets.LoginServlet</servlet-class>
</servlet>
<servlet-mapping>
  <servlet-name>LoginServlet</servlet-name>
  <url-pattern>/login</url-pattern>
</servlet-mapping>

<!-- ... autres servlets ... -->

<!-- Error pages -->
<error-page>
  <error-code>404</error-code>
  <location>/WEB-INF/vues/404.jsp</location>
</error-page>
<error-page>
  <error-code>500</error-code>
  <location>/WEB-INF/vues/500.jsp</location>
</error-page>

<!-- Session config -->
<session-config>
  <cookie-config>
    <secure>false</secure> <!-- true en prod -->
    <http-only>true</http-only>
  </cookie-config>
  <tracking-mode>COOKIE</tracking-mode>
</session-config>
```

---

## Flux authentification

1. **GET /login** → LoginServlet renvoie JSP login form (ou redirige si session active)
2. **POST /login** → valider user/pwd vs DB → BCrypt check → créer session
3. **Toute requête** → AuthenticationFilter vérifie session valide
4. **Accès /secured/** → AuthorizationFilter vérifie role
5. **POST /logout** → destroy session

---

## Exemple DAO — Pattern répétitif

**BaseDAO.java** — abstraction réutilisable:
```java
public abstract class BaseDAO<T> {
  protected Connection getConnection() { /* DBConnection pool */ }
  public List<T> findAll(int limit, int offset) { /* template */ }
  public T findById(Long id) { /* template */ }
  public void insert(T entity) { /* override */ }
  public void update(T entity) { /* override */ }
  public void delete(Long id) { /* PreparedStatement */ }
}
```

**EtudiantDAO.java** — spécialisation 80 lignes:
```java
public class EtudiantDAO extends BaseDAO<Etudiant> {
  public List<Etudiant> findByFiliere(String filiere, int limit, int offset) { }
  public Etudiant findByMatricule(String matricule) { }
  @Override
  public void insert(Etudiant e) { /* PreparedStatement */ }
  @Override
  public void update(Etudiant e) { }
}
```

---

## Calculs métier — NoteService

```java
public class NoteService {
  public static BigDecimal calcNoteFinale(BigDecimal cc, BigDecimal exam) {
    return cc.multiply(new BigDecimal("0.4"))
      .add(exam.multiply(new BigDecimal("0.6")));
  }

  public static String getMention(BigDecimal noteFinale) {
    if (noteFinale.compareTo(new BigDecimal("16")) >= 0) return "Très Bien";
    if (noteFinale.compareTo(new BigDecimal("14")) >= 0) return "Bien";
    // ...
  }

  public static boolean isAdmis(BigDecimal noteFinale) {
    return noteFinale.compareTo(new BigDecimal("10")) >= 0;
  }
}
```

---

## Génération PDF — iText 7

**PDFService.java** — classe réutilisable:
- Template bulletin: table infos étudiant + tableau notes + ligne résultat
- Template PV: classement étudiants par moyenne
- Template stats: distribution mentions par filière
- Font embed: DM Sans (ou liberation sans en fallback)

---

## SMS — SMSLib ou simulé

**SMSService.java**:
- Simulé: logguer destination + contenu
- Réel (SMSLib): configurer compte, envoyer via Twilio/SMS gateway

---

## Déploiement

```bash
# 1. Démarrer DB
docker-compose up -d

# 2. Build WAR
mvn clean package

# 3. Deploy Tomcat 9+ (copier WAR vers CATALINA_HOME/webapps)
cp target/NotesSup.war /path/to/tomcat/webapps/

# 4. Accès application
http://localhost:8080/NotesSup
```

---

## Validation & Tests

**Pas de tests unitaires — application testé via déploiement:**
- Login 3 rôles (credential corrections fixtures)
- CRUD étudiants (add/edit/delete/search)
- Saisie notes + calcul automatique
- Publication délibération + SMS
- Génération PDF bulletin
- Export CSV

---

## Priorisations critiques

1. **pom.xml** + **docker-compose.yml** + **web.xml** — démarrage rapide
2. **DBConnection** + **BaseDAO** — fondation réutilisable
3. **Models + Servlets Login** — authentification d'abord
4. **CRUD Étudiants/Matières** — copier/adapter pattern
5. **Notes + Services** — logique métier
6. **PDF + SMS** — features high-value
7. **JSPs** — rendu final
8. **CSS** — design tokens

---

## Estimation effort

| Component | Lignes | Difficulté |
|-----------|--------|---|
| pom.xml | 80 | ⭐ |
| web.xml | 150 | ⭐ |
| Models (5×) | 50 | ⭐ |
| BaseDAO | 100 | ⭐⭐ |
| DAOs (5×) | 400 | ⭐ |
| Services (Auth/Note/PDF/SMS) | 200 | ⭐⭐ |
| Filters (3×) | 80 | ⭐⭐ |
| Servlets (8×) | 400 | ⭐ |
| JSPs (10+) | 300 | ⭐ |
| CSS | 100 | ⭐ |
| SQL schema + seed | 50 | ⭐ |
| **Total** | **~1800** | — |

**Durée estimée:** 6–8 heures dev continu, ~1500–1800 lignes code.

