# Manuel de Maîtrise — NotesSup

> But de ce manuel : qu'à la fin de la lecture tu puisses **expliquer et défendre chaque ligne** du projet à l'oral, et **redessiner l'architecture de mémoire**. On part de zéro sur chaque technologie (JDBC, Servlet, Filter, JSP, Service…), puis on montre exactement **où** et **comment** elle est utilisée dans *ce* projet, avec le fichier et le numéro de ligne.

Conseil de lecture : lis dans l'ordre. Chaque chapitre suppose le précédent. À la fin de chaque chapitre il y a une section **« Questions de jury »** — si tu sais y répondre sans regarder, tu maîtrises.

---

## Table des matières

1. [Vue d'ensemble & vocabulaire](#1)
2. [L'architecture en couches (MVC + DAO + Service)](#2)
3. [Le fil rouge : cycle de vie d'une requête HTTP](#3)
4. [Jakarta EE, le conteneur, et le fichier WAR](#4)
5. [Maven & le `pom.xml`](#5)
6. [Les Servlets](#6)
7. [Les Filtres (Filters)](#7)
8. [Les Sessions & l'authentification](#8)
9. [JSP, JSTL et EL (la couche Vue)](#9)
10. [Les Models (POJO / JavaBeans) et les DTO](#10)
11. [JDBC et la couche DAO](#11)
12. [La couche Service (logique métier)](#12)
13. [La base de données MySQL](#13)
14. [Sécurité : BCrypt, RBAC, en-têtes HTTP](#14)
15. [Fonctions transversales : PDF (iText), SMS (Strategy), CSV, upload, pagination](#15)
16. [Carte mentale finale & questions de synthèse](#16)
17. [Glossaire](#17)

---

<a name="1"></a>
## 1. Vue d'ensemble & vocabulaire

**NotesSup** est une application web de gestion de notes universitaires. Trois types d'utilisateurs (rôles) :

| Rôle (constante) | Valeur en base | Qui | Peut faire |
|---|---|---|---|
| `ROLE_CHEF` | `CHEF_DEPT` | Chef de département | Tout (CRUD étudiants, matières, notes, publier les délibérations, voir stats) |
| `ROLE_ENSEIGNANT` | `ENSEIGNANT` | Enseignant | Saisir/modifier les notes de **ses** matières, voir étudiants & bulletins |
| `ROLE_ETUDIANT` | `ETUDIANT` | Étudiant | Voir **son** bulletin et **ses** statistiques (uniquement si la délibération est publiée) |

Ces constantes sont définies une seule fois dans `utils/Constants.java:14-16`.

**La stack technique** (à connaître par cœur, source : `README.md` et `pom.xml`) :

- **Langage** : Java 21
- **Plateforme web** : Jakarta EE 11 — Servlets 6.1 + JSP 3.1 + JSTL 3.0
- **Base de données** : MySQL 8.0, accédée en **JDBC pur** (pas d'ORM type Hibernate)
- **Build** : Maven → produit un **`.war`** déployé sur **Tomcat 11**
- **Sécurité** : jBCrypt (hachage des mots de passe) + filtres maison
- **PDF** : iText 8 (bulletins)
- **SMS** : passerelle enfichable (Africa's Talking par défaut, ou console, ou modem GSM)
- **Logs** : SLF4J + Logback

**Mot-clé à retenir** : c'est une application **« Servlet/JSP classique »** (Model 2 / MVC), sans framework (pas de Spring). Tout est fait « à la main », ce qui est parfait pour comprendre les fondations.

---

<a name="2"></a>
## 2. L'architecture en couches (MVC + DAO + Service)

Le projet suit le patron **MVC modèle 2** enrichi de deux couches métier. De haut en bas, une requête traverse :

```
   Navigateur (HTTP)
        │
        ▼
┌─────────────────────┐
│  FILTRES            │  filters/  → sécurité + authentification (avant tout)
├─────────────────────┤
│  SERVLETS           │  servlets/ → le "Contrôleur" (C du MVC) : reçoit la requête,
│  (Controller)       │             décide quoi faire, prépare les données
├─────────────────────┤
│  SERVICES           │  services/ → logique métier (calcul moyenne, PDF, SMS, auth)
├─────────────────────┤
│  DAO                │  dao/      → accès base de données (JDBC, SQL)
├─────────────────────┤
│  MODELS (entités)   │  models/   → objets de données (Etudiant, Note, User…) = le "M"
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│  JSP (View)         │  webapp/WEB-INF/views/ → génère le HTML = le "V"
└─────────────────────┘
        │
        ▼
   HTML renvoyé au navigateur
```

Correspondance avec les dossiers réels (`src/main/java/org/ict4d/notessup/`) :

| Couche | Dossier | Rôle | Exemple |
|---|---|---|---|
| Contrôleur | `servlets/` | Reçoit requêtes, orchestre | `EtudiantServlet.java` |
| Filtre | `filters/` | Coupe-circuit avant les servlets | `AuthenticationFilter.java` |
| Service | `services/` | Règles métier, calculs | `NoteService.java` |
| DAO | `dao/` | SQL + JDBC | `EtudiantDAO.java` |
| Modèle | `models/` | Données pures | `Etudiant.java` |
| Vue | `webapp/WEB-INF/views/` | HTML dynamique | `etudiants/list.jsp` |
| Utilitaires | `utils/` | Constantes, connexion DB, validation | `Constants.java` |

**Pourquoi séparer en couches ?** (réponse type jury)
- **Responsabilité unique** : chaque classe a un seul travail. Le servlet ne sait pas écrire du SQL ; le DAO ne sait pas calculer une moyenne ; le service ne sait pas générer du HTML.
- **Testabilité & réutilisation** : `NoteService.calcNoteFinale()` est appelé par `NoteServlet` *et* `PDFService` *et* `DeliberationServlet`. Écrit une fois, réutilisé partout.
- **Maintenance** : si on change de base de données, on ne touche que la couche DAO.

**La règle d'or des dépendances** : les flèches vont toujours vers le bas. Une JSP n'appelle jamais un DAO directement ; un DAO n'appelle jamais un servlet. (On verra plus loin que ce projet a une petite entorse : certaines JSP appellent des méthodes du modèle, ce qui est toléré.)

---

<a name="3"></a>
## 3. Le fil rouge : cycle de vie d'une requête HTTP

C'est **LE** schéma à savoir refaire. Prenons un exemple concret : **l'enseignant clique sur « Étudiants »**, ce qui appelle `GET /NotesSup/etudiants`.

1. **Le navigateur** envoie `GET /NotesSup/etudiants HTTP/1.1` avec son cookie de session `JSESSIONID`.

2. **Tomcat** (le conteneur) reçoit la requête. Il regarde la chaîne de filtres déclarée dans `web.xml`.

3. **`SecurityHeaderFilter`** (`filters/SecurityHeaderFilter.java`) s'exécute en premier : il ajoute les en-têtes de sécurité (anti-clickjacking, CSP…) puis appelle `chain.doFilter(...)` pour passer au suivant.

4. **`AuthenticationFilter`** (`filters/AuthenticationFilter.java`) s'exécute :
   - `/etudiants` n'est pas une URL publique → il vérifie la session (`getSession(false)`).
   - La session existe et contient un `user` → il vérifie le rôle via `hasPermission()`.
   - `ENSEIGNANT` a le droit de **voir** `/etudiants` (seules les actions `add/edit/delete` lui sont interdites) → `chain.doFilter(...)` laisse passer.

5. **Tomcat** consulte `web.xml`, voit que `/etudiants` est mappé sur `EtudiantServlet`, et appelle sa méthode `doGet(req, resp)`.

6. **`EtudiantServlet.doGet()`** (`servlets/EtudiantServlet.java:30`) :
   - re-vérifie le rôle (défense en profondeur),
   - lit les paramètres (`page`, `search`),
   - appelle le **DAO** : `etudiantDAO.findAll(PAGE_SIZE, offset)` et `etudiantDAO.count()`,
   - calcule la pagination,
   - dépose les résultats dans la requête : `req.setAttribute("etudiants", etudiants)`,
   - **transfère** (forward) vers la JSP : `req.getRequestDispatcher("/WEB-INF/views/etudiants/list.jsp").forward(req, resp)`.

7. **`EtudiantDAO.findAll()`** (`dao/EtudiantDAO.java:14`) ouvre une connexion JDBC, exécute `SELECT * FROM etudiant ... LIMIT ? OFFSET ?`, transforme chaque ligne du `ResultSet` en objet `Etudiant`, renvoie la `List<Etudiant>`.

8. **La JSP `list.jsp`** s'exécute côté serveur : elle lit `${etudiants}` et, avec la boucle JSTL `<c:forEach>`, génère une ligne `<tr>` de tableau HTML par étudiant.

9. **Tomcat** renvoie le HTML produit au navigateur. Fin.

> Mémorise la phrase : **« Filtre → Servlet → Service/DAO → Model → JSP → HTML »**. Tout le reste n'est que du détail sur chaque étage.

Deux façons pour un servlet de répondre, à ne **jamais** confondre :

| Mécanisme | Code | Effet | Quand |
|---|---|---|---|
| **Forward** | `req.getRequestDispatcher("…jsp").forward(req,resp)` | Transfert **interne** au serveur, même requête, l'URL ne change pas dans le navigateur. On garde les `attributes`. | Pour **afficher** une vue (afficher une liste, un formulaire) |
| **Redirect** | `resp.sendRedirect(ctx + "/etudiants")` | Le serveur dit au navigateur « va à cette nouvelle URL », **nouvelle** requête, l'URL change. On perd les `attributes`. | **Après** une modification (POST), pour éviter le double-submit (patron POST-Redirect-GET) |

Exemple dans le code : après une création d'étudiant en POST, on fait `resp.sendRedirect(...)` (`EtudiantServlet.java:165`). Pour afficher la liste en GET, on fait `forward` (`EtudiantServlet.java:78`).

---

<a name="4"></a>
## 4. Jakarta EE, le conteneur, et le fichier WAR

### Qu'est-ce que Jakarta EE ?
Jakarta EE (anciennement Java EE) est un **ensemble de spécifications** pour les applications d'entreprise en Java. Ici on n'utilise qu'une petite partie : la **Servlet API** et **JSP/JSTL**. Le `pom.xml` tire tout ça via une seule dépendance : `jakarta.jakartaee-web-api` (`pom.xml`, scope `provided`).

> **Pourquoi `scope=provided` ?** Parce que le **serveur** (Tomcat) fournit déjà ces classes à l'exécution. On compile contre elles, mais on ne les met **pas** dans le `.war` (sinon conflit). À retenir : *provided = « le serveur me le donnera »*.

### Le conteneur de servlets (Tomcat)
Un **conteneur** (servlet container) est un programme qui :
- écoute le port HTTP (8080),
- gère le **cycle de vie** des servlets (les instancie une fois, appelle `init`, `service`, `destroy`),
- gère les **sessions** (cookie `JSESSIONID`),
- applique les **filtres** et le **routing** déclarés dans `web.xml`.

Toi tu n'écris **jamais** `new EtudiantServlet()` : c'est Tomcat qui crée **une seule instance** par servlet et la partage entre toutes les requêtes (d'où l'importance que les servlets soient *sans état*, on y revient).

### Le packaging WAR
`pom.xml` déclare `<packaging>war</packaging>`. Un **WAR** (*Web Application aRchive*) est un `.zip` avec une structure imposée :

```
NotesSup.war
├── index.jsp, css/, js/        ← ressources publiques (servies directement)
├── WEB-INF/
│   ├── web.xml                 ← descripteur de déploiement
│   ├── views/                  ← JSP PRIVÉES (inaccessibles par URL directe !)
│   └── classes/ + lib/         ← code compilé + dépendances .jar
```

**Point d'examen crucial** : tout ce qui est sous `WEB-INF/` est **invisible depuis l'extérieur**. On y met les JSP exprès : un utilisateur ne peut pas taper `…/views/etudiants/list.jsp` dans son navigateur. Il **doit** passer par un servlet qui fait le `forward`. C'est une sécurité : la vue ne s'affiche jamais sans que le contrôleur ait préparé les données et vérifié les droits.

### `web.xml` — le descripteur de déploiement
`webapp/WEB-INF/web.xml` configure l'application **de façon déclarative** (sans code). On y trouve :
- la config de session (`web.xml:11-18`) : cookie `HttpOnly` + `Secure`, timeout 30 min ;
- la déclaration des **filtres** et de leur mapping `/*` (`web.xml:22-41`) ;
- la déclaration des **servlets** et de leur URL (`web.xml:45-142`) — ex. `LoginServlet` → `/login` ;
- les **pages d'erreur** (`web.xml:146-161`) : 404 → `404.jsp`, 500 → `500.jsp`, 403 → `403.jsp` ;
- les **welcome files** (`web.xml:164-167`).

> Détail subtil : les servlets sont mappés ici **dans `web.xml`**, mais les **filtres** sont *aussi* annotés `@WebFilter` dans leur classe Java (`AuthenticationFilter.java:16`). Les deux méthodes coexistent. Quand `web.xml` et l'annotation déclarent la même chose, c'est `web.xml` qui définit l'**ordre** d'exécution des filtres — et ici l'ordre voulu est : sécurité d'abord, authentification ensuite.

### Questions de jury — chap. 4
- *Pourquoi met-on les JSP sous `WEB-INF/` ?* → pour les rendre inaccessibles directement, forcer le passage par un contrôleur.
- *Qui crée les objets servlet ?* → le conteneur (Tomcat), une seule instance partagée.
- *Que veut dire `provided` ?* → dépendance fournie par le serveur à l'exécution, non incluse dans le WAR.

---

<a name="5"></a>
## 5. Maven & le `pom.xml`

**Maven** est l'outil de *build* : il télécharge les dépendances, compile, et fabrique le `.war`. Tout est piloté par `pom.xml` (*Project Object Model*).

Sections à savoir lire :

- **Coordonnées** du projet : `groupId=org.ict4d`, `artifactId=NotesSup`, `version=1.0-SNAPSHOT`. Ces trois valeurs identifient un artefact de façon unique.
- **`<properties>`** : Java 21, encodage UTF-8, version Jakarta EE.
- **`<dependencies>`** : chaque `<dependency>` = une bibliothèque externe. À connaître :
  - `jakarta.jakartaee-web-api` (provided) → Servlet/JSP
  - `jakarta.servlet.jsp.jstl` (api + impl glassfish) → les balises `<c:…>` des JSP
  - `mysql-connector-j` (scope `runtime`) → le **driver JDBC** MySQL
  - `jbcrypt` → hachage de mots de passe
  - `itext-core` → génération PDF
  - `jackson-databind` → JSON (présent, peu utilisé)
  - `slf4j` + `logback` → logs
- **`<build><plugins>`** :
  - `maven-compiler-plugin` (Java 21),
  - `maven-war-plugin` avec `failOnMissingWebXml=false` (on a un `web.xml`, mais ça autorise aussi les apps sans),
  - `cargo-maven3-plugin` : permet de lancer un Tomcat embarqué pour tester.

**Les scopes Maven** (question fréquente) :
| Scope | Sens | Dans le WAR ? | Exemple ici |
|---|---|---|---|
| (défaut/compile) | nécessaire partout | oui | jbcrypt, itext |
| `provided` | fourni par le serveur | non | jakarta web-api |
| `runtime` | pas à la compilation, mais à l'exécution | oui | mysql-connector-j |

> Pourquoi le driver MySQL est `runtime` ? Parce qu'on ne référence jamais ses classes directement dans notre code (on passe par l'interface JDBC standard `java.sql.*`). Il n'est nécessaire qu'au moment de se connecter, à l'exécution.

**Commandes** (README) : `mvn clean package` → `target/NotesSup.war` → déployer dans `tomcat/webapps/` → app sur `http://localhost:8080/NotesSup`.

---

<a name="6"></a>
## 6. Les Servlets

### Concept
Un **servlet** est une classe Java qui traite une requête HTTP et produit une réponse. C'est le **Contrôleur** du MVC. Toute classe servlet **hérite de `HttpServlet`** et redéfinit une ou plusieurs méthodes selon le verbe HTTP :

| Verbe HTTP | Méthode à redéfinir | Usage dans le projet |
|---|---|---|
| GET | `doGet()` | Afficher une page/liste/formulaire |
| POST | `doPost()` | Créer/modifier (soumission de formulaire) |
| PUT | `doPut()` | Basculer un état (ex. publier/dépublier) |
| DELETE | `doDelete()` | Supprimer |

Le conteneur appelle d'abord `service()`, qui aiguille vers la bonne méthode selon le verbe. Tu n'as qu'à remplir les méthodes.

### Anatomie d'un servlet du projet : `EtudiantServlet`
Lis `servlets/EtudiantServlet.java` en entier, c'est le plus représentatif (il a GET, POST, DELETE et un upload de fichier).

**Champs** (`:25-27`) :
```java
public class EtudiantServlet extends HttpServlet {
    private final EtudiantDAO etudiantDAO = new EtudiantDAO();
    private static final int PAGE_SIZE = Constants.DEFAULT_PAGE_SIZE;
```
Le servlet possède son DAO. **Attention au piège** : comme Tomcat ne crée qu'**une** instance du servlet partagée par tous les utilisateurs, ce champ `etudiantDAO` est partagé. Ici c'est sans danger car le DAO est *sans état* (il n'a pas de variable d'instance modifiée par requête). **Règle absolue : ne jamais stocker de donnée propre à une requête dans un champ de servlet.** Les données par requête vont dans des variables locales.

**`doGet` (`:30-84`)** — un routeur basé sur le paramètre `action` :
```java
String action = req.getParameter("action");
if ("add".equals(action))  → forward vers form.jsp (formulaire vide)
else if ("edit".equals(action)) → charge l'étudiant par id, forward vers form.jsp (pré-rempli)
else  → liste paginée : DAO.findAll/search + count, calcul totalPages, forward vers list.jsp
```
Remarque le style `"add".equals(action)` (constante d'abord) : si `action` est `null`, pas de `NullPointerException`. C'est un réflexe pro.

**`doPost` (`:86-175`)** — création/mise à jour :
- vérifie que le rôle est `CHEF_DEPT` (sinon `403`),
- construit un objet `Etudiant` depuis les `req.getParameter(...)`,
- gère l'**upload de photo** (`req.getPart("photo")`, voir chap. 15),
- appelle `etudiantDAO.insert/update`,
- à la création, **crée automatiquement un compte `User`** pour l'étudiant avec login = matricule et mot de passe par défaut `pass123` haché en BCrypt (`:153-163`),
- `sendRedirect` vers `/etudiants` (POST-Redirect-GET).

**`doDelete` (`:177-195`)** — supprime par id, réservé au chef.

**`@MultipartConfig` (`:20-24`)** — annotation obligatoire pour qu'un servlet accepte un upload `multipart/form-data` (limites de taille définies ici).

### Objets clés manipulés dans un servlet
- `HttpServletRequest req` : la requête entrante. Méthodes vitales :
  - `req.getParameter("nom")` → valeur d'un champ de formulaire ou d'un paramètre d'URL (`?nom=…`)
  - `req.setAttribute("clé", objet)` → dépose un objet pour la JSP (durée = la requête)
  - `req.getSession(false/true)` → récupère/crée la session
  - `req.getRequestDispatcher("…").forward(...)` → passe la main à une JSP
  - `req.getPart("photo")` → un fichier uploadé
- `HttpServletResponse resp` : la réponse sortante.
  - `resp.sendRedirect(url)` → redirige
  - `resp.sendError(403, "…")` → renvoie un code d'erreur HTTP (déclenche la page d'erreur de `web.xml`)
  - `resp.setContentType("application/pdf")` + `resp.getOutputStream()` → renvoyer un fichier binaire (PDF, chap. 15)
  - `resp.getWriter()` → écrire du texte directement (CSV, chap. 15)

### `req.getAttribute` vs `req.getParameter` (piège classique)
| | `getParameter` | `getAttribute` / `setAttribute` |
|---|---|---|
| D'où ça vient | du **client** (URL ou formulaire) | du **serveur** (déposé par le servlet) |
| Type | toujours `String` | n'importe quel objet |
| Usage | lire ce que l'utilisateur a envoyé | passer des données préparées à la JSP |

### Le `LoginServlet`, version minimale (`servlets/LoginServlet.java`)
À étudier car court et complet :
- `doGet` → affiche `login.jsp`.
- `doPost` → lit `login`+`password`, appelle `authService.authenticate(...)`. Si OK : crée la session (`getSession(true)`), y stocke `user` et `role`, redirige vers `/dashboard`. Sinon : remet le message d'erreur en attribut et ré-affiche `login.jsp`.

### Questions de jury — chap. 6
- *Combien d'instances d'un servlet existe-t-il ?* → une seule, partagée → ne pas y stocker d'état par requête.
- *Différence forward/redirect ?* → voir le tableau du chap. 3.
- *Pourquoi `"add".equals(action)` et pas `action.equals("add")` ?* → éviter le NPE si `action` est null.
- *Comment un servlet passe-t-il des données à une JSP ?* → `setAttribute` + `forward`.

---

<a name="7"></a>
## 7. Les Filtres (Filters)

### Concept
Un **filtre** intercepte **toutes** (ou certaines) les requêtes **avant** qu'elles n'atteignent le servlet, et peut aussi agir sur la réponse au retour. C'est un *coupe-circuit* idéal pour les préoccupations transversales : sécurité, authentification, logs, compression. Un filtre implémente l'interface `Filter` et sa méthode centrale `doFilter(request, response, chain)`. **La ligne magique est `chain.doFilter(request, response)`** : elle dit « laisse passer vers le filtre/servlet suivant ». Si on ne l'appelle **pas**, la requête est **bloquée** ici.

Le projet a deux filtres, tous deux mappés sur `/*` (toutes les URL), dans l'ordre fixé par `web.xml` :

### 1) `SecurityHeaderFilter` (`filters/SecurityHeaderFilter.java`)
S'exécute en premier. Il ne bloque jamais : il **ajoute des en-têtes HTTP de sécurité** sur chaque réponse puis appelle `chain.doFilter`. Les en-têtes (`:33-59`) :
- `X-Frame-Options: DENY` → empêche d'afficher le site dans une `<iframe>` (anti **clickjacking**).
- `X-Content-Type-Options: nosniff` → empêche le navigateur de « deviner » le type d'un fichier (anti MIME-sniffing).
- `X-XSS-Protection` → filtre XSS du navigateur.
- `Strict-Transport-Security` (HSTS) → force HTTPS.
- `Content-Security-Policy` → restreint d'où viennent scripts/styles/images (anti **XSS**).
- `Referrer-Policy`, `Permissions-Policy` → limitent les fuites d'info et l'accès caméra/micro/géoloc.

À l'oral : « ce filtre durcit chaque réponse contre les attaques web courantes ; il est passif, il n'interrompt jamais la chaîne. »

### 2) `AuthenticationFilter` (`filters/AuthenticationFilter.java`) — le videur
C'est le **garde du corps** de l'application. Logique de `doFilter` (`:36-68`) :

```java
String path = requestURI - contextPath;        // ex: "/etudiants"
if (isPublicPath(path)) { chain.doFilter(...); return; }   // login, css, js → libre

HttpSession session = httpRequest.getSession(false);       // false = ne crée PAS
if (session != null && session.getAttribute("user") != null) {
    String role = (String) session.getAttribute("role");
    if (hasPermission(path, role, queryString))
        chain.doFilter(...);                    // autorisé → on continue
    else
        httpResponse.sendError(403, "Accès refusé pour votre rôle");
} else {
    httpResponse.sendRedirect(contextPath + "/login");      // pas connecté → login
}
```

Deux décisions distinctes, à bien séparer dans ta tête :
1. **Authentification** = « es-tu connecté ? » → présence d'un `user` en session.
2. **Autorisation** = « as-tu le droit d'aller là ? » → `hasPermission(path, role, query)`.

**Les chemins publics** (`PUBLIC_PATHS`, `:19-26`) : `/login`, `/css/`, `/js/`, `/assets/`… La méthode `isPublicPath` (`:115-134`) fait du *préfixe* pour ceux qui finissent par `/` et de l'*égalité exacte* sinon.

**`hasPermission` (`:73-105`)** = le cœur du **RBAC** (contrôle d'accès basé sur les rôles) :
- `CHEF_DEPT` → `return true` (accès total).
- `ENSEIGNANT` → tout sauf : ajouter/éditer/supprimer un étudiant, et ajouter/publier une délibération (il inspecte la `queryString` pour repérer `action=add/edit/delete/publish`).
- `ETUDIANT` → liste blanche stricte : seulement `/dashboard`, `/bulletins`, `/statistiques` (+ ressources statiques).

**Défense en profondeur** : remarque que les servlets re-vérifient *aussi* le rôle (ex. `EtudiantServlet.java:35`, `:92`). On ne fait jamais confiance à une seule barrière. Si quelqu'un contourne le filtre, le servlet bloque encore.

### Ordre d'exécution & schéma
```
Requête → [SecurityHeaderFilter] → [AuthenticationFilter] → Servlet → réponse
              (ajoute en-têtes)       (vérifie session+rôle)
```

### Questions de jury — chap. 7
- *Que se passe-t-il si on oublie `chain.doFilter` ?* → la requête est bloquée, le servlet n'est jamais atteint.
- *Différence authentification / autorisation ?* → connecté vs autorisé ; ici session vs `hasPermission`.
- *Pourquoi `getSession(false)` dans le filtre ?* → pour **ne pas créer** de session involontairement à un visiteur non connecté.
- *Qu'est-ce que le RBAC ?* → droits attribués selon le rôle ; implémenté dans `hasPermission`.

---

<a name="8"></a>
## 8. Les Sessions & l'authentification

### Le problème : HTTP est sans mémoire
HTTP est **stateless** : chaque requête est indépendante, le serveur ne « se souvient » de rien. Pour garder un utilisateur connecté entre deux pages, on utilise une **session**.

### Comment ça marche ici
1. À la connexion réussie, `LoginServlet.doPost` fait `req.getSession(true)` → Tomcat crée une session côté serveur et renvoie au navigateur un **cookie `JSESSIONID`**.
2. On y stocke l'utilisateur : `session.setAttribute(Constants.SESSION_USER, user)` et `session.setAttribute(Constants.SESSION_ROLE, role)` (`LoginServlet.java:31-32`). Les clés `"user"`/`"role"` sont des constantes (`Constants.java:19-20`).
3. À chaque requête suivante, le navigateur renvoie le cookie. Tomcat retrouve la session. Le `AuthenticationFilter` lit `session.getAttribute("user")` pour savoir qui c'est.
4. À la déconnexion, `LogoutServlet` invalide la session (`session.invalidate()`), le cookie ne sert plus.

### Sécurité de la session (config `web.xml:11-18`)
- `<http-only>true` → le cookie `JSESSIONID` est **inaccessible au JavaScript** (anti-vol par XSS).
- `<secure>true` → cookie envoyé seulement en HTTPS.
- `<tracking-mode>COOKIE` → pas d'ID de session dans l'URL (plus sûr).
- `<timeout>30` → expiration après 30 min d'inactivité.

### `getSession(true)` vs `getSession(false)` (à savoir)
- `getSession(true)` (ou sans argument) → renvoie la session existante **ou en crée une**.
- `getSession(false)` → renvoie la session existante **ou `null`** (ne crée rien). Utilisé dans le filtre et les servlets pour *tester* sans créer.

### Questions de jury — chap. 8
- *Comment l'appli sait qui est connecté entre deux pages ?* → cookie `JSESSIONID` + session serveur.
- *Pourquoi `HttpOnly` ?* → empêcher un script malveillant de lire le cookie.
- *Où est stocké le rôle ?* → en session, clé `Constants.SESSION_ROLE`.

---

<a name="9"></a>
## 9. JSP, JSTL et EL (la couche Vue)

### JSP — c'est un servlet déguisé
Une **JSP** (*JavaServer Page*) est un fichier HTML qui peut contenir des morceaux dynamiques. À la première requête, Tomcat la **traduit en un vrai servlet Java** puis l'exécute. Donc : *écrire une JSP = écrire un générateur de HTML côté serveur*. Le HTML final est calculé sur le serveur, le navigateur ne reçoit que du HTML pur.

Toutes les vues sont dans `webapp/WEB-INF/views/` (donc protégées, voir chap. 4).

### Les directives en haut de chaque JSP
Regarde `etudiants/list.jsp:1-3` :
```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
```
- `<%@ page %>` configure la page (type MIME, encodage).
- `<%@ taglib %>` importe une **bibliothèque de balises** (JSTL). `prefix="c"` → on pourra écrire `<c:if>`, `<c:forEach>`… `fmt` sert au formatage, `fn` aux fonctions sur chaînes (voir `sidebar.jsp:3`).

### EL — Expression Language `${…}`
`${etudiants}`, `${e.nom}`, `${sessionScope.user.role}` : c'est de l'**EL**. Ça lit des données sans écrire de Java. Règles :
- `${e.nom}` appelle en réalité `e.getNom()` (convention JavaBean : `.nom` → `getNom()`).
- **Scopes** consultés dans l'ordre : `pageScope` → `requestScope` → `sessionScope` → `applicationScope`. Donc `${etudiants}` trouve l'attribut que le servlet a déposé avec `req.setAttribute("etudiants", …)`.
- `${sessionScope.user.role}` lit explicitement dans la session → l'objet `User` mis à la connexion.
- `${pageContext.request.contextPath}` → le préfixe d'URL de l'appli (`/NotesSup`), pour construire des liens portables.

### JSTL — les balises logiques (pas de `<% … %>` Java !)
Le projet utilise JSTL pour garder les JSP propres (pas de code Java mêlé au HTML). Les balises rencontrées :

| Balise | Rôle | Exemple dans le projet |
|---|---|---|
| `<c:if test="…">` | condition simple | `list.jsp:26` n'affiche « + Ajouter » que si `role == 'CHEF_DEPT'` |
| `<c:choose>/<c:when>/<c:otherwise>` | if/else if/else | `list.jsp:98-105` traduit l'année 1→L1, 3→L3, 4→M1… |
| `<c:forEach var="e" items="${etudiants}">` | boucle | `list.jsp:80` une ligne `<tr>` par étudiant |
| `<c:set>` | variable locale | `sidebar.jsp:6-7` calcule `userName`, `userRole` |
| `<c:redirect>` | redirection | `index.jsp:15` redirige vers `/dashboard` ou `/login` |
| `<jsp:include page="…"/>` | inclure une autre JSP | `list.jsp:13` inclut la `sidebar.jsp` |
| `${fn:toUpperCase(...)}` | fonction chaîne | `sidebar.jsp:171` initiale de l'avatar |

### Étude de cas : `etudiants/list.jsp`
- `:13` inclut la barre latérale partagée (`<jsp:include>`), un composant réutilisé par toutes les pages → évite la duplication.
- `:26-30` : le bouton « Ajouter » n'apparaît **que** pour le chef (`<c:if test="${sessionScope.user.role == 'CHEF_DEPT'}">`). La vue s'adapte au rôle.
- `:42-58` : un formulaire GET de recherche (champ `search` + sélecteur de filière).
- `:78-130` : `<c:choose>` → si la liste a des éléments, `<c:forEach>` génère les lignes ; sinon affiche « Aucun étudiant trouvé ».
- `:136-160` : la pagination, construite à partir des attributs `currentPage`, `totalPages`, `pageSize` déposés par le servlet.

### `login.jsp` & `sidebar.jsp`
- `login.jsp` : page sans sidebar (on n'est pas connecté). Le bloc `<c:if test="${error != null}">` (`:265`) affiche le message d'erreur déposé par le servlet. Les boutons « démo » remplissent le formulaire via un petit script `fillDemo()`.
- `sidebar.jsp` : exemple de **menu qui dépend du rôle** — un `<c:choose>` (`:63-163`) affiche un jeu de liens différent pour `CHEF_DEPT`, `ENSEIGNANT`, `ETUDIANT`. Il détecte aussi la page active en comparant l'URI courante.

### `app.js` — le peu de JavaScript côté client
`webapp/js/app.js` est du JS **vanilla** (sans framework). Il gère : validation des formulaires avant envoi, fenêtres modales, confirmation avant suppression, auto-submit de recherche avec *debounce*, export CSV côté client, impression. C'est du **progressive enhancement** : l'appli marche sans, le JS améliore le confort. À noter : l'essentiel de la logique est côté serveur (JSP), le JS reste léger.

### Questions de jury — chap. 9
- *Une JSP, ça s'exécute où ?* → côté serveur ; elle est compilée en servlet ; le client ne reçoit que du HTML.
- *`${e.nom}` fait quoi exactement ?* → appelle `e.getNom()`.
- *Pourquoi JSTL plutôt que `<% %>` ?* → séparer la logique de présentation du code Java, lisibilité, pas de Java dans la vue.
- *Comment la vue connaît le rôle ?* → via `${sessionScope.user.role}`.

---

<a name="10"></a>
## 10. Les Models (POJO / JavaBeans) et les DTO

### POJO / JavaBean
Un **modèle** est une classe Java qui ne contient **que des données** : des champs privés + des getters/setters + un constructeur. On parle de **POJO** (*Plain Old Java Object*) ou **JavaBean** quand il respecte la convention getter/setter (indispensable pour que l'EL `${…}` fonctionne).

Exemple `models/User.java` :
```java
public class User {
    private Long id;
    private String login, password, role, nom, filiere;
    private Long etudiantId;
    public User() {}                                  // constructeur vide OBLIGATOIRE pour un bean
    public User(String login, String password, String role, String nom) { … }  // pratique
    public String getLogin() { return login; }        // getter
    public void setLogin(String login) { this.login = login; }  // setter
    // … etc
}
```
Le **constructeur vide** est requis par la convention JavaBean (et utilisé partout dans les DAO : `new User()` puis on remplit avec les setters).

Les modèles du projet (`models/`) reflètent les tables de la base :
- `User` ↔ table `user`
- `Etudiant` ↔ table `etudiant`
- `Matiere` ↔ table `matiere`
- `Note` ↔ table `note`
- `Deliberation` ↔ table `deliberation`

### Relations objets « à la main »
`models/Note.java` montre une finesse : en plus des **clés étrangères** (`etudiantId`, `matiereId` — de simples `Long`), il a aussi des **références objets** :
```java
private Long etudiantId;     // la FK brute lue en base
private Long matiereId;
private Etudiant etudiant;   // l'objet complet, rempli APRÈS coup
private Matiere matiere;
```
La base ne stocke que les `id`. C'est le service qui « branche » les objets complets ensuite (méthode `populateNoteRelations`, voir chap. 12). Sans ORM, c'est nous qui faisons le travail qu'Hibernate ferait automatiquement.

### Les `BigDecimal` pour les notes
`Note` utilise `BigDecimal` (et non `double`) pour `noteCC`, `noteExam`, `noteFinale`. **Pourquoi ?** Parce que `double` fait des erreurs d'arrondi binaires (`0.1 + 0.2 != 0.3`). Pour de l'argent ou des notes, on utilise `BigDecimal` qui est exact. À retenir absolument pour le jury.

### DTO — `models/DeliberationDTO.java`
Un **DTO** (*Data Transfer Object*) est un objet qui **regroupe/enrichit** des données pour la vue, sans correspondre à une table. `DeliberationDTO` enveloppe une `Deliberation` et y ajoute des champs **calculés** : `nbEtudiants`, `nbAdmis`, `moyenne`. Ces valeurs ne sont pas en base ; elles sont calculées par `DeliberationServlet.enrichDeliberations()` (`:271-305`) puis passées à la JSP. Le DTO existe pour ne pas polluer le modèle `Deliberation` avec des données d'affichage.

> **Model vs DTO** : le *Model* mappe une table ; le *DTO* sert à transporter un agrégat pratique vers la vue.

### Questions de jury — chap. 10
- *Pourquoi un constructeur vide ?* → convention JavaBean, requise par l'EL et utilisée par les DAO.
- *Pourquoi `BigDecimal` et pas `double` pour les notes ?* → précision exacte, pas d'erreur d'arrondi.
- *Quelle différence entre `etudiantId` et `etudiant` dans `Note` ?* → l'un est la FK brute, l'autre l'objet complet rempli après par le service.
- *Qu'est-ce qu'un DTO ?* → objet d'agrégation/transport pour la vue, ex. `DeliberationDTO` avec `nbAdmis`.

---

<a name="11"></a>
## 11. JDBC et la couche DAO

### JDBC, c'est quoi ?
**JDBC** (*Java DataBase Connectivity*) est l'**API standard Java pour parler à une base SQL**. Toutes les classes sont dans `java.sql.*`. Les objets fondamentaux :

| Objet JDBC | Rôle |
|---|---|
| `Connection` | une connexion ouverte à la base |
| `PreparedStatement` | une requête SQL **paramétrée** (`?`), pré-compilée |
| `ResultSet` | le **curseur** sur les lignes résultat d'un `SELECT` |
| `SQLException` | l'exception levée si quelque chose tourne mal |

### La connexion : `utils/DBConnection.java`
```java
public class DBConnection {
    static {                                            // bloc statique : exécuté UNE fois
        try { Class.forName("com.mysql.cj.jdbc.Driver"); }   // charge le driver MySQL
        catch (ClassNotFoundException e) { throw new ExceptionInInitializerError(e); }
    }
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(Constants.DB_URL, Constants.DB_USER, Constants.DB_PASSWORD);
    }
}
```
- Le **bloc `static`** charge la classe du driver une fois au démarrage. (Sur les drivers modernes c'est optionnel grâce au *Service Provider*, mais c'est resté ici par clarté pédagogique.)
- `DriverManager.getConnection(url, user, password)` ouvre une connexion. L'URL est construite dans `Constants.java:10-11` :
  `jdbc:mysql://localhost:3306/notessup_db?useSSL=false&serverTimezone=UTC&...`
- Les identifiants (`notessup_user` / `notessup_pass`) sont dans `Constants.java:8-9`. **Critique honnête à savoir formuler** : mettre des identifiants en dur dans le code est une mauvaise pratique ; en production on les passerait par variables d'environnement (comme c'est fait pour le SMS).

> **Limite assumée** : il n'y a **pas de pool de connexions** ici. Chaque appel DAO ouvre puis ferme une connexion. Un *connection pool* (HikariCP, ou le `DataSource` de Tomcat) réutiliserait les connexions — plus performant. À citer comme « amélioration possible ».

### La classe mère : `dao/BaseDAO.java`
Classe **abstraite générique** qui impose le contrat CRUD à tous les DAO :
```java
public abstract class BaseDAO<T> {
    public abstract List<T> findAll(int limit, int offset) throws SQLException;
    public abstract T    findById(Long id) throws SQLException;
    public abstract void insert(T entity)  throws SQLException;
    public abstract void update(T entity)  throws SQLException;
    public abstract void delete(Long id)   throws SQLException;
    protected Connection getConnection() throws SQLException { return DBConnection.getConnection(); }
    protected void close(Connection, PreparedStatement, ResultSet) { … }
}
```
- `<T>` est un **générique** : `EtudiantDAO extends BaseDAO<Etudiant>` → `findById` renvoie un `Etudiant`. Type-safe.
- **CRUD** = Create (`insert`), Read (`findAll`/`findById`), Update, Delete : les 4 opérations de base.
- `close(...)` existe pour fermer proprement, mais les DAO modernes du projet préfèrent le **try-with-resources** (voir ci-dessous), qui ferme automatiquement.

### Étude détaillée : `dao/EtudiantDAO.java`

**Un SELECT paginé (`findAll`, `:14-28`)** — modèle à connaître par cœur :
```java
public List<Etudiant> findAll(int limit, int offset) throws SQLException {
    List<Etudiant> etudiants = new ArrayList<>();
    String sql = "SELECT * FROM etudiant ORDER BY nom LIMIT ? OFFSET ?";
    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {   // try-with-resources
        pstmt.setInt(1, limit);     // remplit le 1er ?
        pstmt.setInt(2, offset);    // remplit le 2e ?
        try (ResultSet rs = pstmt.executeQuery()) {  // executeQuery pour un SELECT
            while (rs.next()) {                       // avance ligne par ligne
                etudiants.add(mapEtudiant(rs));       // convertit la ligne en objet
            }
        }
    }
    return etudiants;
}
```
Points à expliquer au jury :
1. **`try (… ) { }` = try-with-resources** : tout ce qui est ouvert dans les parenthèses (`Connection`, `PreparedStatement`, `ResultSet`) est **fermé automatiquement** à la fin, même en cas d'exception. Évite les fuites de connexions. C'est la bonne pratique moderne.
2. **`PreparedStatement` avec `?`** : on ne **jamais** concatène les valeurs dans le SQL. On met des `?` puis `setInt/setString`. Ça donne deux bénéfices : (a) ça **empêche l'injection SQL**, (b) la requête est pré-compilée.
3. **`executeQuery()`** pour un `SELECT` (renvoie un `ResultSet`) — vs **`executeUpdate()`** pour `INSERT/UPDATE/DELETE` (renvoie le nombre de lignes affectées).
4. **`rs.next()`** avance le curseur ; il renvoie `false` quand il n'y a plus de ligne. La boucle `while` lit tout.
5. **`mapEtudiant(rs)`** : la méthode de *mapping* ligne→objet.

**Le mapping (`mapEtudiant`, `:177-188`)** — l'inverse : du `ResultSet` vers l'objet :
```java
private Etudiant mapEtudiant(ResultSet rs) throws SQLException {
    Etudiant e = new Etudiant();
    e.setId(rs.getLong("id"));
    e.setMatricule(rs.getString("matricule"));
    e.setNom(rs.getString("nom"));
    // … rs.getInt("annee"), rs.getString("telephone")…
    return e;
}
```
On lit chaque colonne par son nom avec `getLong/getString/getInt/getBigDecimal`. C'est **manuellement** ce qu'un ORM ferait pour nous.

**Un INSERT avec récupération de l'id auto-généré (`insert`, `:130-149`)** :
```java
PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
… pstmt.executeUpdate();
try (ResultSet keys = pstmt.getGeneratedKeys()) {
    if (keys.next()) etudiant.setId(keys.getLong(1));   // récupère l'AUTO_INCREMENT
}
```
Important quand on doit ensuite utiliser l'id (ici pour créer le compte `User` lié à l'étudiant).

**La recherche (`search`, `:66-84`)** utilise `LIKE ?` avec `"%" + query + "%"` côté Java (toujours via `setString`, donc sûr).

**Méthodes spécifiques au métier** ajoutées en plus du CRUD : `findByMatricule`, `findByFiliere`, `count`, `countByFiliere`, `countSearch`… Chaque écran a les requêtes dont il a besoin.

### `dao/NoteDAO.java` — les requêtes avec jointures
`NoteDAO` est plus riche car les notes relient plusieurs tables :
- `findByEtudiantSessionAnnee` (`:217`) : `JOIN matiere` pour trier par intitulé de matière.
- `findByFiliereSessionAnnee` (`:197`) : `JOIN etudiant` pour filtrer par filière.
- `findByEnseignant` (`:65`) : `JOIN matiere` pour ne ramener que les notes des matières d'un prof.
- `getStatsPerFiliere` (`:237`) : une **requête d'agrégation** avancée — `AVG(note_finale)`, `COUNT(DISTINCT …)`, et un calcul de taux de réussite avec `SUM(CASE WHEN note_finale >= 10 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)`. À savoir lire : c'est du SQL qui calcule les stats directement en base (plus efficace que de tout ramener en Java).
- `insert` (`:155`) écrit aussi `note_finale` déjà calculée (le calcul vient du service, pas du DAO).

> **Frontière nette** : le DAO **ne calcule rien** métier. Il lit/écrit. Le calcul de la moyenne, des mentions, c'est le **Service**. C'est exactement la séparation des responsabilités.

### Pourquoi les DAO lèvent `SQLException` au lieu de la traiter ?
Chaque méthode DAO déclare `throws SQLException`. L'erreur **remonte** jusqu'au servlet, qui décide quoi en faire (afficher `error.jsp`). C'est correct : le DAO ne sait pas comment réagir à l'utilisateur, ce n'est pas son rôle. (Le `BaseDAO.close()` fait un `printStackTrace()`, ce qui est rudimentaire — en prod on logguerait via SLF4J.)

### Questions de jury — chap. 11
- *Qu'est-ce qu'un `PreparedStatement` et pourquoi pas concaténer le SQL ?* → requête paramétrée `?`, empêche l'injection SQL, pré-compilée.
- *`executeQuery` vs `executeUpdate` ?* → SELECT (ResultSet) vs INSERT/UPDATE/DELETE (nb lignes).
- *Le try-with-resources sert à quoi ?* → fermer automatiquement Connection/Statement/ResultSet, éviter les fuites.
- *Que fait `mapEtudiant` ?* → convertit une ligne `ResultSet` en objet `Etudiant`.
- *Pourquoi le DAO ne calcule pas la moyenne ?* → séparation des responsabilités, c'est le rôle du Service.
- *Faiblesse de `DBConnection` ?* → pas de pool, identifiants en dur.

---

<a name="12"></a>
## 12. La couche Service (logique métier)

Les services contiennent **les règles du métier** : ils orchestrent les DAO et font les calculs. Ils ne touchent ni au HTTP (pas de `req`/`resp`) ni au HTML. On pourrait les réutiliser dans une application non-web.

### `services/AuthService.java` — authentification
Petit mais central. Il enveloppe `UserDAO` + jBCrypt :
- `hashPassword(pwd)` → `BCrypt.hashpw(pwd, BCrypt.gensalt())` : produit un hash salé.
- `validatePassword(pwd, hash)` → `BCrypt.checkpw(pwd, hash)` : compare un mot de passe en clair au hash stocké (renvoie true/false).
- `authenticate(login, pwd)` (`:45-51`) : `userDAO.findByLogin(login)` puis vérifie le mot de passe. Renvoie le `User` si OK, sinon `null`.
- `createUser(...)` : crée un utilisateur avec mot de passe haché.

> **Jamais** on ne stocke un mot de passe en clair, ni on ne le « déchiffre ». BCrypt est une fonction **à sens unique** : on ne peut que **re-hacher et comparer**. (Détails BCrypt au chap. 14.)

### `services/NoteService.java` — le cœur académique
C'est le service le plus important. Tout est en `BigDecimal` (précision).

**Calcul de la note finale (`calcNoteFinale`, `:45-54`)** — la formule officielle du projet :
```
note_finale = noteCC × 0,4 + noteExam × 0,6
```
arrondie à 2 décimales (`RoundingMode.HALF_UP`). C'est la règle « 40 % contrôle continu, 60 % examen » annoncée dans le README.

**Les mentions (`getMention`, `:61-77`)** par seuils :
- ≥ 16 → « Très Bien », ≥ 14 → « Bien », ≥ 12 → « Assez Bien », ≥ 10 → « Passable », sinon « Insuffisant ».
Comparaison avec `compareTo` (jamais `==` sur des `BigDecimal`).

**Admission (`isAdmis`, `:109-111`)** : `note ≥ 10`.

**Moyenne pondérée (`calcMoyennePonderee`, `:118-135`)** :
```
moyenne = Σ(note_finale_i × coefficient_i) / Σ(coefficient_i)
```
Chaque matière a un coefficient ; les matières lourdes (ex. Projet, coeff 6) pèsent plus.

**Taux de réussite (`calcTauxReussite`, `:162-175`)** : `(nb matières ≥ 10 / nb total) × 100`, calculé avec un **stream** Java (`.filter(...).count()`).

**`populateNoteRelations` (`:180-200`)** — un bijou à comprendre. Les objets `Note` n'ont que des `id` ; cette méthode va chercher les `Etudiant` et `Matiere` complets et les « branche » dans chaque `Note`. **Optimisation clé** : elle utilise un **cache `Map`** pour ne charger chaque étudiant/matière **qu'une fois**, même s'il revient dans 10 notes. C'est une parade au **problème N+1** (faire N requêtes au lieu de quelques-unes). À citer : « j'ai mis en cache les entités déjà chargées pour éviter les requêtes redondantes ».

### `services/PDFService.java` — génération de bulletins (iText 8)
Construit un PDF **en mémoire** et renvoie un `byte[]` (voir chap. 15). Il **réutilise** `NoteService` pour les moyennes/mentions et les DAO pour les données → bel exemple de couche service qui en orchestre d'autres.

### `services/SMSService.java` + `services/sms/` — notifications
Service métier qui **délègue** l'envoi réel à une passerelle (patron Strategy, chap. 15). Il choisit le bon message (« vos notes sont disponibles » si admis, sinon « alerte »), formate avec `String.format(Locale.US, …)`, et appelle `gateway.send(tel, message)`. Méthode `sendBulkPublicationAlert` pour envoyer en masse lors d'une délibération.

### Comment les services sont-ils utilisés ?
Les servlets les instancient en champ (`new NoteService()`, etc.) et les appellent. Exemple, `NoteServlet.doPost` (`:199`) :
```java
BigDecimal noteFinale = noteService.calcNoteFinale(note.getNoteCC(), note.getNoteExam());
note.setNoteFinale(noteFinale);   // calcul AVANT d'enregistrer
noteDAO.insert(note);
```
Le servlet ne calcule pas lui-même : il **demande** au service. Frontière respectée.

### Questions de jury — chap. 12
- *Donne la formule de la note finale et de la moyenne pondérée.* → 0,4·CC + 0,6·Exam ; Σ(note·coeff)/Σ(coeff).
- *Pourquoi `compareTo` et pas `==` sur BigDecimal ?* → `==` compare les références ; `compareTo` compare les valeurs.
- *C'est quoi le problème N+1 et comment il est évité ?* → trop de requêtes ; évité par le cache `Map` dans `populateNoteRelations`.
- *Qui calcule la note finale, le servlet, le DAO ou le service ?* → le service (`NoteService`).

---

<a name="13"></a>
## 13. La base de données MySQL

Le schéma complet est dans `db/schema.sql`. Cinq tables. Le `docker-compose.yml` charge automatiquement ce script au démarrage du conteneur MySQL.

### Les tables et leurs relations
```
  user ──(etudiant_id)──▶ etudiant ◀──(etudiant_id)── note ──(matiere_id)──▶ matiere
                              │                          
  deliberation (filiere, session, annee)  ── relie logiquement les notes d'une filière
```

- **`user`** (`schema.sql:19-28`) : login (unique), password (hash BCrypt), role (`ENUM('CHEF_DEPT','ENSEIGNANT','ETUDIANT')`), nom, filiere, `etudiant_id` (lien optionnel vers la fiche étudiant).
- **`etudiant`** (`:34-44`) : matricule (unique), nom, prénom, filiere, annee (CHECK 1–5), telephone, photo_path.
- **`matiere`** (`:50-59`) : code (unique), intitule, coefficient (CHECK 1–6), enseignant (le **nom**, pas un id), semestre (1 ou 2), filiere.
- **`note`** (`:65-79`) : `etudiant_id` (FK), `matiere_id` (FK), note_cc, note_exam, note_finale (`DECIMAL(5,2)` → correspond à `BigDecimal`), session (`ENUM('NORMALE','RATTRAPAGE')`), annee_academique, saisie_par.
- **`deliberation`** (`:85-94`) : filiere, session, annee, date_publication, publiee (booléen), publiee_par.

### Notions SQL à savoir défendre
- **Clé primaire** `id BIGINT AUTO_INCREMENT PRIMARY KEY` : identifiant unique auto-incrémenté.
- **Clé étrangère** : `FOREIGN KEY (etudiant_id) REFERENCES etudiant(id) ON DELETE CASCADE` (`:77`). Le `ON DELETE CASCADE` signifie : **si on supprime un étudiant, ses notes sont supprimées automatiquement**. (D'où le fait que `EtudiantDAO.delete` n'a pas à supprimer les notes à la main.)
- **Contrainte d'unicité métier** : `UNIQUE KEY uk_note (etudiant_id, matiere_id, session, annee_academique)` (`:76`) → un étudiant ne peut avoir **qu'une** note par matière/session/année. Empêche les doublons au niveau base.
- **`CHECK`** : `annee BETWEEN 1 AND 5`, `coefficient BETWEEN 1 AND 6` → validations au niveau base (en plus de `ValidationUtils` côté Java).
- **`ENUM`** : restreint une colonne à une liste de valeurs (`role`, `session`).
- **`ENGINE=InnoDB`** : le moteur MySQL qui supporte les clés étrangères et les transactions.
- **Charset `utf8mb4`** : Unicode complet (accents, emojis) — important pour les noms français.

### Les données de démo
`schema.sql` insère des utilisateurs, étudiants, matières, notes et 2 délibérations (une publiée pour Informatique, une non publiée pour Réseaux). **Tous les mots de passe** sont `root123`, stockés sous forme du même hash BCrypt (`:101`). C'est pratique pour tester les 3 rôles.

### Questions de jury — chap. 13
- *À quoi sert `ON DELETE CASCADE` ici ?* → supprimer un étudiant supprime ses notes.
- *Pourquoi `DECIMAL(5,2)` pour les notes ?* → précision exacte, correspond au `BigDecimal` Java.
- *Comment empêche-t-on deux fois la même note ?* → contrainte `UNIQUE` composite `uk_note`.
- *Pourquoi `utf8mb4` ?* → support Unicode complet (accents).

---

<a name="14"></a>
## 14. Sécurité : BCrypt, RBAC, en-têtes HTTP

Récapitulatif transversal — la sécurité touche plusieurs couches.

### 1. Mots de passe — BCrypt (`AuthService` + `pom.xml` jbcrypt)
- Un mot de passe n'est **jamais** stocké en clair. On stocke `BCrypt.hashpw(pwd, gensalt())`.
- BCrypt intègre un **sel** (salt) aléatoire → deux utilisateurs avec le même mot de passe ont des hash différents. Le sel est inclus dans le hash lui-même (le préfixe `$2a$10$…`, où `10` est le **coût**, c.-à-d. le nombre de tours = lenteur volontaire pour résister au brute-force).
- Vérification = `BCrypt.checkpw(saisi, hashStocké)`. On **ne déchiffre jamais** (sens unique).
- Voir le hash de démo dans `schema.sql:101` : `$2a$10$7UHsBi…`.

### 2. Contrôle d'accès — RBAC (à deux niveaux)
- **Niveau filtre** : `AuthenticationFilter.hasPermission()` filtre par rôle sur l'URL.
- **Niveau servlet** : chaque servlet re-vérifie (`if (!Constants.ROLE_CHEF.equals(role)) sendError(403)`). En plus, des règles **fines** : un `ENSEIGNANT` ne peut modifier que les notes de **ses** matières — vérifié dans `NoteServlet.doPost` (`:177-186`) en comparant `matiere.getEnseignant()` au nom du prof connecté.
- **Niveau vue** : la JSP cache les boutons interdits (`<c:if test="${… role == 'CHEF_DEPT'}">`).
→ Trois barrières = **défense en profondeur**.

### 3. Données métier verrouillées par la délibération
Un étudiant ne voit son bulletin **que si la délibération de sa session est publiée** : `BulletinServlet` (`:91-103`) cherche la délibération et, si elle n'est pas `publiee`, affiche un état « verrouillé » à l'étudiant. La publication est un acte réservé au chef (`DeliberationServlet.doPost` action `publish`).

### 4. Injection SQL — neutralisée
Toutes les requêtes passent par `PreparedStatement` avec `?` (chap. 11). Aucune valeur utilisateur n'est concaténée dans une chaîne SQL → pas d'injection.

### 5. XSS / clickjacking — en-têtes (`SecurityHeaderFilter`)
Voir chap. 7 : CSP, X-Frame-Options, nosniff, HSTS. En complément, `ValidationUtils.sanitize()` retire `< > " '` d'une saisie. Note : l'EL `${…}` n'échappe **pas** le HTML par défaut — une vraie appli utiliserait `<c:out>` ou `fn:escapeXml` ; à mentionner comme amélioration possible.

### 6. Session durcie
Cookie `HttpOnly` + `Secure`, timeout 30 min, ID en cookie seulement (chap. 8).

### Questions de jury — chap. 14
- *Peut-on retrouver le mot de passe depuis le hash ?* → non, BCrypt est à sens unique ; on re-hache et compare.
- *C'est quoi le « coût » dans `$2a$10$` ?* → le facteur de travail (2^10 tours), ralentit le brute-force.
- *Cite 3 niveaux où le rôle est vérifié.* → filtre, servlet, vue.
- *Comment l'appli empêche l'injection SQL ?* → `PreparedStatement` paramétrés.

---

<a name="15"></a>
## 15. Fonctions transversales

### A. Génération PDF avec iText 8 (`PDFService` + `BulletinServlet`)
**Principe** : on construit un document PDF en mémoire et on l'envoie en téléchargement.

Côté service (`PDFService.generateBulletinPDF`, `:51-87`) :
```java
ByteArrayOutputStream baos = new ByteArrayOutputStream();   // buffer mémoire
PdfWriter writer = new PdfWriter(baos);
PdfDocument pdf = new PdfDocument(writer);
Document document = new Document(pdf);
// … on ajoute en-tête, tableau de notes, bannière de résultat, signatures, pied de page …
document.close();
return baos.toByteArray();                                  // le PDF en octets
```
On compose le document avec des objets iText : `Table`, `Cell`, `Paragraph`, couleurs `DeviceRgb`. La couleur d'une note dépend de sa valeur (`getNoteColor`, `:263-275`). Le service réutilise `NoteService` pour la moyenne et la mention.

Côté servlet (`BulletinServlet.doGet`, `:105-114`), pour **envoyer un binaire** :
```java
byte[] pdf = pdfService.generateBulletinPDF(id, session, annee);
resp.setContentType("application/pdf");
resp.setHeader("Content-Disposition", "attachment; filename=bulletin_….pdf");  // force le téléchargement
resp.getOutputStream().write(pdf);
resp.getOutputStream().flush();
```
`Content-Disposition: attachment` dit au navigateur « télécharge le fichier » plutôt que l'afficher. On écrit dans le **flux binaire** `getOutputStream()` (≠ `getWriter()` pour le texte).

### B. Passerelle SMS — patron **Strategy / Factory** (`services/sms/`)
C'est le plus beau morceau de *design* du projet. Problème : on veut envoyer des SMS, mais le **moyen** d'envoi varie (API web, modem GSM, ou juste un log en dev). Solution : une **interface** + plusieurs implémentations interchangeables.

- **L'interface** `SmsGateway` (`sms/SmsGateway.java`) : un contrat `boolean send(phone, message)` + `String name()`.
- **Les implémentations** (les « stratégies ») :
  - `ConsoleSmsGateway` → écrit le SMS dans les logs (par défaut, marche partout, idéal en dev).
  - `AfricasTalkingGateway` → appelle l'**API REST** d'Africa's Talking via `java.net.http.HttpClient` (aucune dépendance Maven en plus). Lis `AfricasTalkingGateway.send()` : il construit un corps `x-www-form-urlencoded`, envoie un POST, et considère le statut `201` comme succès.
  - `SmslibGateway` → envoi réel par modem GSM (désactivé tant que la lib SMSLib n'est pas installée — voir le bloc commenté du `pom.xml`).
- **La fabrique** `SmsGatewayFactory` (`sms/SmsGatewayFactory.java`) : choisit l'implémentation selon `Constants.SMS_GATEWAY` (configurable par variable d'environnement `SMS_GATEWAY`). Elle renvoie une **instance unique** (singleton) construite avec le **double-checked locking** (`if null → synchronized → if null → build`) pour être correcte en multithread.

**Pourquoi ce patron est bon** (réponse jury) : le `SMSService` ne connaît que l'**interface** ; on peut changer de fournisseur SMS **sans toucher** au code métier. C'est le principe **« programmer vers une interface, pas une implémentation »** et le principe ouvert/fermé.

```
SMSService ──▶ SmsGateway (interface) ──┬─ ConsoleSmsGateway
                       ▲                ├─ AfricasTalkingGateway
              SmsGatewayFactory.get()   └─ SmslibGateway
              (choisit selon config)
```

### C. Export CSV (`ExportServlet`)
Pour renvoyer du **texte**, on utilise `resp.getWriter()` (≠ binaire) :
```java
resp.setContentType("text/csv; charset=UTF-8");
resp.setHeader("Content-Disposition", "attachment; filename=export_notes.csv");
PrintWriter writer = resp.getWriter();
writer.println("MATRICULE,NOM,…");          // l'en-tête CSV
for (Note note : notes) { … writer.println(...); }
```
La méthode `escapeCsv` (`:130-138`) protège les valeurs contenant virgule/guillemet en les entourant de `"`. Deux exports : `type=csv` (notes détaillées) et `type=stats` (moyennes par étudiant).

### D. Upload de fichier (photo étudiant) — `EtudiantServlet`
- L'annotation `@MultipartConfig` (`:20-24`) active le support `multipart/form-data` et fixe les tailles max.
- Dans `doPost` (`:114-124`) : `Part photoPart = req.getPart("photo")`. Si un fichier est présent, on génère un nom unique avec `UUID.randomUUID()` (évite les collisions de noms), on crée le dossier `/uploads/` si besoin, on écrit le fichier avec `photoPart.write(...)`, et on stocke le chemin relatif dans `etudiant.photoPath`. En édition, si aucune nouvelle photo, on garde l'ancienne.

### E. Pagination (partout)
Patron récurrent : le servlet lit `?page=N`, calcule `offset = (page-1) * PAGE_SIZE`, demande au DAO `findAll(PAGE_SIZE, offset)` **et** `count()`, puis `totalPages = ceil(total / pageSize)`. La JSP affiche les numéros de page (`list.jsp:136-160`). `PAGE_SIZE` vaut `Constants.DEFAULT_PAGE_SIZE = 6`. En SQL, la pagination se fait avec `LIMIT ? OFFSET ?`.

### Questions de jury — chap. 15
- *`getWriter()` vs `getOutputStream()` ?* → texte vs binaire ; CSV vs PDF.
- *À quoi sert `Content-Disposition: attachment` ?* → forcer le téléchargement avec un nom de fichier.
- *Explique le patron des passerelles SMS.* → Strategy (interface + implémentations) + Factory (choix selon config) + singleton.
- *Pourquoi `UUID` pour les noms de photos ?* → garantir l'unicité, éviter d'écraser un fichier existant.
- *Comment marche la pagination en SQL ?* → `LIMIT taille OFFSET (page-1)×taille`.

---

<a name="16"></a>
## 16. Carte mentale finale & questions de synthèse

### Le schéma à savoir redessiner les yeux fermés
```
NAVIGATEUR
   │  GET /NotesSup/notes?action=grille
   ▼
[SecurityHeaderFilter]   ajoute en-têtes sécurité, laisse passer
   ▼
[AuthenticationFilter]   connecté ? rôle autorisé ? sinon 403 / redirect login
   ▼
NoteServlet.doGet()      lit params, vérifie rôle
   │   appelle ↓
   ├─▶ MatiereDAO.findByEnseignant()  ── JDBC ──▶ MySQL
   ├─▶ EtudiantDAO.findAll()          ── JDBC ──▶ MySQL
   ├─▶ NoteService.populateNoteRelations()  (logique + cache)
   │   setAttribute("etudiants", …), setAttribute("matieres", …)
   ▼
forward → notes/grille.jsp
   │  EL ${…} + JSTL <c:forEach> lisent les attributs, génèrent le HTML
   ▼
HTML  →  NAVIGATEUR
```

### Tableau « une techno = un rôle = un fichier exemple »
| Techno | Rôle en une phrase | Fichier à citer |
|---|---|---|
| Servlet | Contrôleur HTTP (reçoit/répond) | `servlets/EtudiantServlet.java` |
| Filter | Coupe-circuit avant les servlets (sécurité/auth) | `filters/AuthenticationFilter.java` |
| Session | Mémoriser l'utilisateur entre les requêtes | `LoginServlet.java` + `web.xml` |
| JSP/JSTL/EL | Générer le HTML côté serveur | `views/etudiants/list.jsp` |
| Model/JavaBean | Données pures | `models/Etudiant.java` |
| DTO | Agrégat enrichi pour la vue | `models/DeliberationDTO.java` |
| DAO + JDBC | Lire/écrire en base via SQL | `dao/EtudiantDAO.java` |
| Service | Logique métier (calcul, PDF, SMS, auth) | `services/NoteService.java` |
| BCrypt | Hacher les mots de passe | `services/AuthService.java` |
| iText | Générer des PDF | `services/PDFService.java` |
| Strategy/Factory | Passerelle SMS enfichable | `services/sms/` |
| MySQL/JDBC driver | Stockage | `db/schema.sql`, `utils/DBConnection.java` |
| Maven | Build → WAR | `pom.xml` |

### 20 questions « pièges » de synthèse (entraîne-toi à l'oral)
1. Décris le trajet complet d'un clic « Saisir une note » de l'URL au HTML.
2. Pourquoi les JSP sont-elles sous `WEB-INF/` ?
3. Forward ou redirect après un POST de création ? Pourquoi ?
4. Que se passe-t-il si `AuthenticationFilter` n'appelle pas `chain.doFilter` ?
5. Différence authentification / autorisation, avec le code correspondant.
6. Pourquoi une seule instance de servlet ? Quelle règle ça impose ?
7. Donne la formule note finale + moyenne pondérée + le seuil d'admission.
8. Pourquoi `BigDecimal` et pas `double` ? Pourquoi `compareTo` et pas `==` ?
9. Qu'est-ce qu'un `PreparedStatement` ? Quel risque il neutralise ?
10. À quoi sert le try-with-resources dans les DAO ?
11. `executeQuery` vs `executeUpdate`.
12. Comment récupère-t-on l'`id` auto-généré après un INSERT ?
13. Explique `populateNoteRelations` et le problème N+1.
14. Qui calcule `note_finale` : servlet, service ou DAO ?
15. Comment BCrypt vérifie un mot de passe sans le déchiffrer ? C'est quoi le sel et le coût ?
16. Cite les trois niveaux de contrôle de rôle (défense en profondeur).
17. Comment un étudiant est-il empêché de voir un bulletin non délibéré ?
18. Explique le patron Strategy+Factory des passerelles SMS et son intérêt.
19. `getWriter()` vs `getOutputStream()` : quel cas pour CSV, lequel pour PDF ?
20. Que fait `ON DELETE CASCADE` sur la table `note` ?

### Faiblesses connues (savoir les nommer = montre de la maturité)
- Identifiants DB en dur dans `Constants.java` (devraient être des variables d'env).
- Pas de **pool de connexions** (une connexion ouverte/fermée par appel).
- EL non échappée → risque XSS résiduel ; utiliser `<c:out>`/`fn:escapeXml`.
- Une clé API SMS de démo traîne dans `Constants.java:38` (à ne jamais faire en vrai).
- Gestion d'erreurs DAO rudimentaire (`printStackTrace`), à remplacer par du logging SLF4J.
- `enseignant` stocké comme **nom** (texte) dans `matiere` plutôt qu'une FK vers `user` → fragile si un nom change.

---

<a name="17"></a>
## 17. Glossaire

- **Conteneur de servlets** : serveur (Tomcat) qui exécute les servlets et gère leur cycle de vie, les sessions, les filtres.
- **WAR** : archive de déploiement d'une appli web Java.
- **Servlet** : classe Java qui traite une requête HTTP (le Contrôleur).
- **Filter** : intercepteur exécuté avant/après les servlets.
- **Session** : mémoire serveur associée à un utilisateur via le cookie `JSESSIONID`.
- **JSP** : page HTML dynamique compilée en servlet, génère le HTML (la Vue).
- **JSTL** : bibliothèque de balises (`<c:if>`, `<c:forEach>`…) pour la logique de présentation.
- **EL** : *Expression Language* `${…}` pour lire les données dans les JSP.
- **POJO / JavaBean** : objet de données avec getters/setters et constructeur vide.
- **DTO** : objet d'agrégation/transport vers la vue.
- **DAO** : *Data Access Object*, encapsule l'accès aux données (SQL/JDBC).
- **JDBC** : API Java standard pour les bases SQL (`Connection`, `PreparedStatement`, `ResultSet`).
- **PreparedStatement** : requête SQL paramétrée (`?`), protège contre l'injection.
- **Service** : couche de logique métier (calculs, orchestration).
- **CRUD** : Create, Read, Update, Delete.
- **RBAC** : *Role-Based Access Control*, droits selon le rôle.
- **BCrypt** : algorithme de hachage de mots de passe avec sel et coût.
- **MVC (modèle 2)** : Model–View–Controller appliqué au web (servlet = C, JSP = V, model = M).
- **Strategy / Factory** : patrons de conception (algorithme interchangeable / fabrique d'objets).
- **N+1** : anti-patron où l'on fait N requêtes au lieu de quelques-unes.
- **Pagination** : découpage des résultats en pages (`LIMIT`/`OFFSET`).

---

*Fin du manuel. Conseil : relis chaque section « Questions de jury » à voix haute, puis ouvre le fichier source cité et retrouve la ligne. Quand tu peux faire l'aller-retour concept ⇄ code sans hésiter, c'est maîtrisé.*
