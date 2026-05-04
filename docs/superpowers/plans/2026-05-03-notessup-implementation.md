# NotesSup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implémentation complète application Jakarta EE de gestion des notes & bulletins (16 features requis, design high-fidelity, déploiement production-ready).

**Architecture:** Vertical par entité — Model → DAO → Service → Servlet → JSP. BaseDAO réutilisable, pattern reproductible. JDBC PreparedStatement strict, BCrypt, PDF/SMS, filtres sécurité.

**Tech Stack:** Jakarta EE 11, MySQL 8 (Docker), iText 7, SMSLib, jBCrypt, JSTL, Apache Commons FileUpload.

---

## Phase 1: Fondations

### Task 1: Docker MySQL setup

**Files:**
- Create: `docker-compose.yml`
- Create: `db/schema.sql`

- [ ] **Step 1: docker-compose.yml**

```yaml
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: notessup_db
      MYSQL_USER: notessup_user
      MYSQL_PASSWORD: notessup_pass
    ports:
      - "3306:3306"
    volumes:
      - ./db/schema.sql:/docker-entrypoint-initdb.d/1-schema.sql
      - mysql_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  mysql_data:
```

- [ ] **Step 2: Create db/schema.sql — tables**

```sql
CREATE DATABASE IF NOT EXISTS notessup_db;
USE notessup_db;

CREATE TABLE `user` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `login` VARCHAR(50) NOT NULL UNIQUE,
  `password` TEXT NOT NULL,
  `role` ENUM('CHEF_DEPT', 'ENSEIGNANT', 'ETUDIANT') NOT NULL,
  `nom` VARCHAR(100) NOT NULL,
  `filiere` VARCHAR(80),
  `etudiant_id` BIGINT,
  CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE `etudiant` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `matricule` VARCHAR(20) NOT NULL UNIQUE,
  `nom` VARCHAR(100) NOT NULL,
  `prenom` VARCHAR(100) NOT NULL,
  `filiere` VARCHAR(80) NOT NULL,
  `annee` INT NOT NULL CHECK (annee BETWEEN 1 AND 5),
  `telephone` VARCHAR(20),
  CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE `matiere` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(15) NOT NULL UNIQUE,
  `intitule` VARCHAR(150) NOT NULL,
  `coefficient` INT NOT NULL CHECK (coefficient BETWEEN 1 AND 6),
  `enseignant` VARCHAR(100),
  `semestre` INT NOT NULL CHECK (semestre IN (1, 2)),
  `filiere` VARCHAR(80) NOT NULL,
  CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE `note` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `etudiant_id` BIGINT NOT NULL,
  `matiere_id` BIGINT NOT NULL,
  `note_cc` DECIMAL(5,2),
  `note_exam` DECIMAL(5,2),
  `note_finale` DECIMAL(5,2),
  `session` ENUM('NORMALE', 'RATTRAPAGE') DEFAULT 'NORMALE',
  `annee_academique` VARCHAR(9),
  `saisie_par` VARCHAR(100),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_note` (etudiant_id, matiere_id, session, annee_academique),
  FOREIGN KEY (etudiant_id) REFERENCES etudiant(id) ON DELETE CASCADE,
  FOREIGN KEY (matiere_id) REFERENCES matiere(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `deliberation` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `filiere` VARCHAR(80) NOT NULL,
  `session` ENUM('NORMALE', 'RATTRAPAGE') DEFAULT 'NORMALE',
  `annee_academique` VARCHAR(9),
  `date_publication` DATE,
  `publiee` BOOLEAN DEFAULT FALSE,
  `publiee_par` VARCHAR(100),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

- [ ] **Step 3: Seed data — demo users + étudiants + matières**

```sql
-- Users demo
INSERT INTO `user` (login, password, role, nom, filiere) VALUES
('chef', '$2a$10$...hashed_root123', 'CHEF_DEPT', 'Chef Département', 'Informatique'),
('prof1', '$2a$10$...hashed_root123', 'ENSEIGNANT', 'Prof Dupont', 'Informatique'),
('etud1', '$2a$10$...hashed_root123', 'ETUDIANT', 'Etudiant Un', 'Informatique');

-- Étudiants
INSERT INTO `etudiant` (matricule, nom, prenom, filiere, annee, telephone) VALUES
('MAT001', 'Dupont', 'Alice', 'Informatique', 3, '+33612345678'),
('MAT002', 'Martin', 'Bob', 'Informatique', 3, '+33687654321'),
('MAT003', 'Garcia', 'Carol', 'Informatique', 3, '+33656565656');

-- Matières
INSERT INTO `matiere` (code, intitule, coefficient, enseignant, semestre, filiere) VALUES
('INFO301', 'Architecture Logicielle', 3, 'Prof Dupont', 1, 'Informatique'),
('INFO302', 'Base de Données Avancées', 4, 'Prof Martin', 1, 'Informatique'),
('INFO303', 'Programmation Web', 3, 'Prof Dupont', 1, 'Informatique');
```

- [ ] **Step 4: Start Docker**

```bash
cd /path/to/NotesSup
docker-compose up -d
# Verify: docker ps should show mysql running
# Test connection: mysql -h 127.0.0.1 -u notessup_user -p notessup_db
```

---

### Task 2: pom.xml — dépendances

**Files:**
- Modify: `pom.xml`

- [ ] **Step 1: Update pom.xml avec toutes dépendances**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.ict4d</groupId>
    <artifactId>NotesSup</artifactId>
    <version>1.0-SNAPSHOT</version>
    <name>NotesSup</name>
    <packaging>war</packaging>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.target>11</maven.compiler.target>
        <maven.compiler.source>11</maven.compiler.source>
    </properties>

    <dependencies>
        <!-- Jakarta EE 11 -->
        <dependency>
            <groupId>jakarta.platform</groupId>
            <artifactId>jakarta.jakartaee-web-api</artifactId>
            <version>11.0.0</version>
            <scope>provided</scope>
        </dependency>

        <!-- JSTL -->
        <dependency>
            <groupId>org.apache.taglibs</groupId>
            <artifactId>taglibs-standard-impl</artifactId>
            <version>1.2.5</version>
        </dependency>

        <!-- MySQL JDBC Driver -->
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
            <version>8.0.33</version>
            <scope>runtime</scope>
        </dependency>

        <!-- jBCrypt -->
        <dependency>
            <groupId>org.mindrot</groupId>
            <artifactId>jbcrypt</artifactId>
            <version>0.4</version>
        </dependency>

        <!-- iText 7 (PDF) -->
        <dependency>
            <groupId>com.itextpdf</groupId>
            <artifactId>itext-core</artifactId>
            <version>8.0.3</version>
        </dependency>

        <!-- SMSLib (SMS) -->
        <dependency>
            <groupId>org.smslib</groupId>
            <artifactId>smslib</artifactId>
            <version>3.5.4</version>
        </dependency>

        <!-- Apache Commons FileUpload -->
        <dependency>
            <groupId>commons-fileupload</groupId>
            <artifactId>commons-fileupload</artifactId>
            <version>1.5</version>
        </dependency>

        <!-- Jackson (JSON) -->
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>2.15.2</version>
        </dependency>

        <!-- Logging -->
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>2.0.7</version>
        </dependency>
        <dependency>
            <groupId>ch.qos.logback</groupId>
            <artifactId>logback-classic</artifactId>
            <version>1.4.11</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
                <configuration>
                    <source>11</source>
                    <target>11</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.4.0</version>
                <configuration>
                    <failOnMissingWebXml>false</failOnMissingWebXml>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

- [ ] **Step 2: mvn clean package**

```bash
cd /path/to/NotesSup
mvn clean package
# Expected: BUILD SUCCESS, target/NotesSup-1.0-SNAPSHOT.war created
```

---

### Task 3: Utilitaires & Constantes

**Files:**
- Create: `src/main/java/org/ict4d/notessup/utils/Constants.java`
- Create: `src/main/java/org/ict4d/notessup/utils/DBConnection.java`
- Create: `src/main/java/org/ict4d/notessup/utils/ValidationUtils.java`

- [ ] **Step 1: Constants.java**

```java
package org.ict4d.notessup.utils;

public class Constants {
    // Database
    public static final String DB_HOST = "localhost";
    public static final String DB_PORT = "3306";
    public static final String DB_NAME = "notessup_db";
    public static final String DB_USER = "notessup_user";
    public static final String DB_PASSWORD = "notessup_pass";
    public static final String DB_URL = "jdbc:mysql://" + DB_HOST + ":" + DB_PORT + "/" + DB_NAME 
        + "?useSSL=false&serverTimezone=UTC";

    // Roles
    public static final String ROLE_CHEF = "CHEF_DEPT";
    public static final String ROLE_ENSEIGNANT = "ENSEIGNANT";
    public static final String ROLE_ETUDIANT = "ETUDIANT";

    // Sessions
    public static final String SESSION_USER = "user";
    public static final String SESSION_ROLE = "role";

    // File paths
    public static final String UPLOAD_DIR = "/tmp/notessup/uploads";

    // Pagination
    public static final int DEFAULT_PAGE_SIZE = 6;
}
```

- [ ] **Step 2: DBConnection.java (pool JDBC simple)**

```java
package org.ict4d.notessup.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(Constants.DB_URL, Constants.DB_USER, Constants.DB_PASSWORD);
    }
}
```

- [ ] **Step 3: ValidationUtils.java**

```java
package org.ict4d.notessup.utils;

public class ValidationUtils {
    public static boolean isValidEmail(String email) {
        return email != null && email.matches("^[A-Za-z0-9+_.-]+@(.+)$");
    }

    public static boolean isValidPhone(String phone) {
        return phone != null && phone.matches("^\\+?[0-9\\s\\-()]{10,}$");
    }

    public static boolean isValidAnnee(int annee) {
        return annee >= 1 && annee <= 5;
    }

    public static boolean isValidCoeff(int coeff) {
        return coeff >= 1 && coeff <= 6;
    }

    public static boolean isValidNote(double note) {
        return note >= 0 && note <= 20;
    }

    public static String sanitize(String input) {
        if (input == null) return "";
        return input.replaceAll("[<>\"']", "");
    }
}
```

---

## Phase 2: Models & DAOs

### Task 4: Models (5 classes simples)

**Files:**
- Create: `src/main/java/org/ict4d/notessup/models/User.java`
- Create: `src/main/java/org/ict4d/notessup/models/Etudiant.java`
- Create: `src/main/java/org/ict4d/notessup/models/Matiere.java`
- Create: `src/main/java/org/ict4d/notessup/models/Note.java`
- Create: `src/main/java/org/ict4d/notessup/models/Deliberation.java`

- [ ] **Step 1: User.java**

```java
package org.ict4d.notessup.models;

public class User {
    private Long id;
    private String login;
    private String password;
    private String role;
    private String nom;
    private String filiere;
    private Long etudiantId;

    public User() {}

    public User(String login, String password, String role, String nom) {
        this.login = login;
        this.password = password;
        this.role = role;
        this.nom = nom;
    }

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getLogin() { return login; }
    public void setLogin(String login) { this.login = login; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getFiliere() { return filiere; }
    public void setFiliere(String filiere) { this.filiere = filiere; }

    public Long getEtudiantId() { return etudiantId; }
    public void setEtudiantId(Long etudiantId) { this.etudiantId = etudiantId; }
}
```

- [ ] **Step 2: Etudiant.java**

```java
package org.ict4d.notessup.models;

public class Etudiant {
    private Long id;
    private String matricule;
    private String nom;
    private String prenom;
    private String filiere;
    private Integer annee;
    private String telephone;

    public Etudiant() {}

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getMatricule() { return matricule; }
    public void setMatricule(String matricule) { this.matricule = matricule; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }

    public String getFiliere() { return filiere; }
    public void setFiliere(String filiere) { this.filiere = filiere; }

    public Integer getAnnee() { return annee; }
    public void setAnnee(Integer annee) { this.annee = annee; }

    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }
}
```

- [ ] **Step 3: Matiere.java**

```java
package org.ict4d.notessup.models;

public class Matiere {
    private Long id;
    private String code;
    private String intitule;
    private Integer coefficient;
    private String enseignant;
    private Integer semestre;
    private String filiere;

    public Matiere() {}

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getIntitule() { return intitule; }
    public void setIntitule(String intitule) { this.intitule = intitule; }

    public Integer getCoefficient() { return coefficient; }
    public void setCoefficient(Integer coefficient) { this.coefficient = coefficient; }

    public String getEnseignant() { return enseignant; }
    public void setEnseignant(String enseignant) { this.enseignant = enseignant; }

    public Integer getSemestre() { return semestre; }
    public void setSemestre(Integer semestre) { this.semestre = semestre; }

    public String getFiliere() { return filiere; }
    public void setFiliere(String filiere) { this.filiere = filiere; }
}
```

- [ ] **Step 4: Note.java**

```java
package org.ict4d.notessup.models;

import java.math.BigDecimal;

public class Note {
    private Long id;
    private Long etudiantId;
    private Long matiereId;
    private BigDecimal noteCC;
    private BigDecimal noteExam;
    private BigDecimal noteFinale;
    private String session;
    private String anneeAcademique;
    private String saisiePar;

    public Note() {}

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getEtudiantId() { return etudiantId; }
    public void setEtudiantId(Long etudiantId) { this.etudiantId = etudiantId; }

    public Long getMatiereId() { return matiereId; }
    public void setMatiereId(Long matiereId) { this.matiereId = matiereId; }

    public BigDecimal getNoteCC() { return noteCC; }
    public void setNoteCC(BigDecimal noteCC) { this.noteCC = noteCC; }

    public BigDecimal getNoteExam() { return noteExam; }
    public void setNoteExam(BigDecimal noteExam) { this.noteExam = noteExam; }

    public BigDecimal getNoteFinale() { return noteFinale; }
    public void setNoteFinale(BigDecimal noteFinale) { this.noteFinale = noteFinale; }

    public String getSession() { return session; }
    public void setSession(String session) { this.session = session; }

    public String getAnneeAcademique() { return anneeAcademique; }
    public void setAnneeAcademique(String anneeAcademique) { this.anneeAcademique = anneeAcademique; }

    public String getSaisiePar() { return saisiePar; }
    public void setSaisiePar(String saisiePar) { this.saisiePar = saisiePar; }
}
```

- [ ] **Step 5: Deliberation.java**

```java
package org.ict4d.notessup.models;

import java.time.LocalDate;

public class Deliberation {
    private Long id;
    private String filiere;
    private String session;
    private String anneeAcademique;
    private LocalDate datePublication;
    private Boolean publiee;
    private String publiePar;

    public Deliberation() {}

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getFiliere() { return filiere; }
    public void setFiliere(String filiere) { this.filiere = filiere; }

    public String getSession() { return session; }
    public void setSession(String session) { this.session = session; }

    public String getAnneeAcademique() { return anneeAcademique; }
    public void setAnneeAcademique(String anneeAcademique) { this.anneeAcademique = anneeAcademique; }

    public LocalDate getDatePublication() { return datePublication; }
    public void setDatePublication(LocalDate datePublication) { this.datePublication = datePublication; }

    public Boolean getPubliee() { return publiee; }
    public void setPubliee(Boolean publiee) { this.publiee = publiee; }

    public String getPubliePar() { return publiePar; }
    public void setPubliePar(String publiePar) { this.publiePar = publiePar; }
}
```

---

### Task 5: BaseDAO (abstraction réutilisable)

**Files:**
- Create: `src/main/java/org/ict4d/notessup/dao/BaseDAO.java`

- [ ] **Step 1: BaseDAO.java (interface + abstract implementation)**

```java
package org.ict4d.notessup.dao;

import org.ict4d.notessup.utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public abstract class BaseDAO<T> {
    public abstract List<T> findAll(int limit, int offset) throws SQLException;
    public abstract T findById(Long id) throws SQLException;
    public abstract void insert(T entity) throws SQLException;
    public abstract void update(T entity) throws SQLException;
    public abstract void delete(Long id) throws SQLException;

    protected Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    protected void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    protected void close(Connection conn, PreparedStatement pstmt) {
        close(conn, pstmt, null);
    }
}
```

---

### Task 6: UserDAO

**Files:**
- Create: `src/main/java/org/ict4d/notessup/dao/UserDAO.java`

- [ ] **Step 1: UserDAO.java**

```java
package org.ict4d.notessup.dao;

import org.ict4d.notessup.models.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAO extends BaseDAO<User> {

    @Override
    public List<User> findAll(int limit, int offset) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM user LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    users.add(mapUser(rs));
                }
            }
        }
        return users;
    }

    @Override
    public User findById(Long id) throws SQLException {
        String sql = "SELECT * FROM user WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }

    public User findByLogin(String login) throws SQLException {
        String sql = "SELECT * FROM user WHERE login = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, login);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }

    @Override
    public void insert(User user) throws SQLException {
        String sql = "INSERT INTO user (login, password, role, nom, filiere) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, user.getLogin());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getRole());
            pstmt.setString(4, user.getNom());
            pstmt.setString(5, user.getFiliere());
            pstmt.executeUpdate();
        }
    }

    @Override
    public void update(User user) throws SQLException {
        String sql = "UPDATE user SET password = ?, role = ?, nom = ?, filiere = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, user.getPassword());
            pstmt.setString(2, user.getRole());
            pstmt.setString(3, user.getNom());
            pstmt.setString(4, user.getFiliere());
            pstmt.setLong(5, user.getId());
            pstmt.executeUpdate();
        }
    }

    @Override
    public void delete(Long id) throws SQLException {
        String sql = "DELETE FROM user WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            pstmt.executeUpdate();
        }
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getLong("id"));
        user.setLogin(rs.getString("login"));
        user.setPassword(rs.getString("password"));
        user.setRole(rs.getString("role"));
        user.setNom(rs.getString("nom"));
        user.setFiliere(rs.getString("filiere"));
        user.setEtudiantId(rs.getObject("etudiant_id") != null ? rs.getLong("etudiant_id") : null);
        return user;
    }
}
```

---

### Task 7: EtudiantDAO

**Files:**
- Create: `src/main/java/org/ict4d/notessup/dao/EtudiantDAO.java`

- [ ] **Step 1: EtudiantDAO.java (CRUD + search)**

```java
package org.ict4d.notessup.dao;

import org.ict4d.notessup.models.Etudiant;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class EtudiantDAO extends BaseDAO<Etudiant> {

    @Override
    public List<Etudiant> findAll(int limit, int offset) throws SQLException {
        List<Etudiant> etudiants = new ArrayList<>();
        String sql = "SELECT * FROM etudiant ORDER BY nom LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    etudiants.add(mapEtudiant(rs));
                }
            }
        }
        return etudiants;
    }

    public List<Etudiant> findByFiliere(String filiere, int limit, int offset) throws SQLException {
        List<Etudiant> etudiants = new ArrayList<>();
        String sql = "SELECT * FROM etudiant WHERE filiere = ? ORDER BY nom LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, filiere);
            pstmt.setInt(2, limit);
            pstmt.setInt(3, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    etudiants.add(mapEtudiant(rs));
                }
            }
        }
        return etudiants;
    }

    public List<Etudiant> search(String query, int limit, int offset) throws SQLException {
        List<Etudiant> etudiants = new ArrayList<>();
        String sql = "SELECT * FROM etudiant WHERE matricule LIKE ? OR nom LIKE ? OR prenom LIKE ? ORDER BY nom LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String searchTerm = "%" + query + "%";
            pstmt.setString(1, searchTerm);
            pstmt.setString(2, searchTerm);
            pstmt.setString(3, searchTerm);
            pstmt.setInt(4, limit);
            pstmt.setInt(5, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    etudiants.add(mapEtudiant(rs));
                }
            }
        }
        return etudiants;
    }

    @Override
    public Etudiant findById(Long id) throws SQLException {
        String sql = "SELECT * FROM etudiant WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapEtudiant(rs);
                }
            }
        }
        return null;
    }

    public Etudiant findByMatricule(String matricule) throws SQLException {
        String sql = "SELECT * FROM etudiant WHERE matricule = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, matricule);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapEtudiant(rs);
                }
            }
        }
        return null;
    }

    @Override
    public void insert(Etudiant etudiant) throws SQLException {
        String sql = "INSERT INTO etudiant (matricule, nom, prenom, filiere, annee, telephone) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, etudiant.getMatricule());
            pstmt.setString(2, etudiant.getNom());
            pstmt.setString(3, etudiant.getPrenom());
            pstmt.setString(4, etudiant.getFiliere());
            pstmt.setInt(5, etudiant.getAnnee());
            pstmt.setString(6, etudiant.getTelephone());
            pstmt.executeUpdate();
        }
    }

    @Override
    public void update(Etudiant etudiant) throws SQLException {
        String sql = "UPDATE etudiant SET nom = ?, prenom = ?, filiere = ?, annee = ?, telephone = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, etudiant.getNom());
            pstmt.setString(2, etudiant.getPrenom());
            pstmt.setString(3, etudiant.getFiliere());
            pstmt.setInt(4, etudiant.getAnnee());
            pstmt.setString(5, etudiant.getTelephone());
            pstmt.setLong(6, etudiant.getId());
            pstmt.executeUpdate();
        }
    }

    @Override
    public void delete(Long id) throws SQLException {
        String sql = "DELETE FROM etudiant WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            pstmt.executeUpdate();
        }
    }

    private Etudiant mapEtudiant(ResultSet rs) throws SQLException {
        Etudiant etudiant = new Etudiant();
        etudiant.setId(rs.getLong("id"));
        etudiant.setMatricule(rs.getString("matricule"));
        etudiant.setNom(rs.getString("nom"));
        etudiant.setPrenom(rs.getString("prenom"));
        etudiant.setFiliere(rs.getString("filiere"));
        etudiant.setAnnee(rs.getInt("annee"));
        etudiant.setTelephone(rs.getString("telephone"));
        return etudiant;
    }
}
```

---

### Task 8: MatiereDAO, NoteDAO, DeliberationDAO (CRUD répétitif)

**Files:**
- Create: `src/main/java/org/ict4d/notessup/dao/MatiereDAO.java`
- Create: `src/main/java/org/ict4d/notessup/dao/NoteDAO.java`
- Create: `src/main/java/org/ict4d/notessup/dao/DeliberationDAO.java`

*(Code complet pour chaque DAO, pattern identique à EtudiantDAO — search, findByFiliere, find par attribut unique, CRUD)*

[Chaque DAO ~80-120 lignes, même structure]

---

## Phase 3: Services

### Task 9: AuthService (BCrypt + validation)

**Files:**
- Create: `src/main/java/org/ict4d/notessup/services/AuthService.java`

- [ ] **Step 1: AuthService.java**

```java
package org.ict4d.notessup.services;

import org.ict4d.notessup.dao.UserDAO;
import org.ict4d.notessup.models.User;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.SQLException;

public class AuthService {
    private static final UserDAO userDAO = new UserDAO();

    public static User authenticate(String login, String password) throws SQLException {
        User user = userDAO.findByLogin(login);
        if (user != null && BCrypt.checkpw(password, user.getPassword())) {
            return user;
        }
        return null;
    }

    public static String hashPassword(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt(10));
    }

    public static boolean validatePassword(String plainPassword, String hashedPassword) {
        return BCrypt.checkpw(plainPassword, hashedPassword);
    }

    public static void createUser(String login, String plainPassword, String role, String nom) throws SQLException {
        User user = new User(login, hashPassword(plainPassword), role, nom);
        userDAO.insert(user);
    }
}
```

---

### Task 10: NoteService (calculs métier)

**Files:**
- Create: `src/main/java/org/ict4d/notessup/services/NoteService.java`

- [ ] **Step 1: NoteService.java**

```java
package org.ict4d.notessup.services;

import java.math.BigDecimal;
import java.math.RoundingMode;

public class NoteService {

    public static BigDecimal calcNoteFinale(BigDecimal cc, BigDecimal exam) {
        if (cc == null || exam == null) return null;
        BigDecimal coefficient_cc = new BigDecimal("0.4");
        BigDecimal coefficient_exam = new BigDecimal("0.6");
        return cc.multiply(coefficient_cc)
            .add(exam.multiply(coefficient_exam))
            .setScale(2, RoundingMode.HALF_UP);
    }

    public static String getMention(BigDecimal noteFinale) {
        if (noteFinale == null) return "N/A";
        if (noteFinale.compareTo(new BigDecimal("16")) >= 0) return "Très Bien";
        if (noteFinale.compareTo(new BigDecimal("14")) >= 0) return "Bien";
        if (noteFinale.compareTo(new BigDecimal("12")) >= 0) return "Assez Bien";
        if (noteFinale.compareTo(new BigDecimal("10")) >= 0) return "Passable";
        return "Ajourné";
    }

    public static String getMentionColor(BigDecimal noteFinale) {
        if (noteFinale == null) return "gray";
        if (noteFinale.compareTo(new BigDecimal("16")) >= 0) return "#059669";
        if (noteFinale.compareTo(new BigDecimal("14")) >= 0) return "#0891b2";
        if (noteFinale.compareTo(new BigDecimal("12")) >= 0) return "#7c3aed";
        if (noteFinale.compareTo(new BigDecimal("10")) >= 0) return "#d97706";
        return "#dc2626";
    }

    public static boolean isAdmis(BigDecimal noteFinale) {
        return noteFinale != null && noteFinale.compareTo(new BigDecimal("10")) >= 0;
    }

    public static double calcMoyennePonderee(java.util.List<Object[]> notesAvecCoeff) {
        // Object[] = [noteFinale, coefficient]
        double totalPoints = 0;
        int totalCoeffs = 0;
        for (Object[] item : notesAvecCoeff) {
            BigDecimal note = (BigDecimal) item[0];
            Integer coeff = (Integer) item[1];
            if (note != null && coeff != null) {
                totalPoints += note.doubleValue() * coeff;
                totalCoeffs += coeff;
            }
        }
        return totalCoeffs > 0 ? totalPoints / totalCoeffs : 0;
    }

    public static double calcTauxReussite(int admis, int total) {
        return total > 0 ? (double) admis / total * 100 : 0;
    }
}
```

---

### Task 11: PDFService (iText 7)

**Files:**
- Create: `src/main/java/org/ict4d/notessup/services/PDFService.java`

- [ ] **Step 1: PDFService.java (bulletin template)**

```java
package org.ict4d.notessup.services;

import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.kernel.colors.ColorConstants;
import org.ict4d.notessup.models.Etudiant;
import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.util.List;

public class PDFService {

    public static byte[] generateBulletinPDF(Etudiant etudiant, List<Object[]> notes, double moyenneFinale, String mention) {
        try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
            PdfWriter writer = new PdfWriter(baos);
            PdfDocument pdf = new PdfDocument(writer);
            Document doc = new Document(pdf);

            // Header
            Paragraph title = new Paragraph("BULLETIN DE NOTES")
                .setTextAlignment(TextAlignment.CENTER)
                .setBold()
                .setFontSize(20);
            doc.add(title);

            Paragraph university = new Paragraph("Université ICT4D — Département Informatique")
                .setTextAlignment(TextAlignment.CENTER)
                .setFontSize(12);
            doc.add(university);

            // Student info
            doc.add(new Paragraph("Étudiant: " + etudiant.getNom() + " " + etudiant.getPrenom()));
            doc.add(new Paragraph("Matricule: " + etudiant.getMatricule()));
            doc.add(new Paragraph("Filière: " + etudiant.getFiliere()));
            doc.add(new Paragraph("Année: " + etudiant.getAnnee()));

            // Grades table
            Table table = new Table(7);
            table.addHeaderCell(new Cell().add(new Paragraph("Code").setBold()));
            table.addHeaderCell(new Cell().add(new Paragraph("Matière").setBold()));
            table.addHeaderCell(new Cell().add(new Paragraph("Coeff").setBold()));
            table.addHeaderCell(new Cell().add(new Paragraph("CC").setBold()));
            table.addHeaderCell(new Cell().add(new Paragraph("Exam").setBold()));
            table.addHeaderCell(new Cell().add(new Paragraph("Finale").setBold()));
            table.addHeaderCell(new Cell().add(new Paragraph("Mention").setBold()));

            for (Object[] row : notes) {
                table.addCell(new Cell().add(new Paragraph((String) row[0])));
                table.addCell(new Cell().add(new Paragraph((String) row[1])));
                table.addCell(new Cell().add(new Paragraph(row[2].toString())));
                table.addCell(new Cell().add(new Paragraph(row[3].toString())));
                table.addCell(new Cell().add(new Paragraph(row[4].toString())));
                table.addCell(new Cell().add(new Paragraph(row[5].toString())));
                table.addCell(new Cell().add(new Paragraph((String) row[6])));
            }
            doc.add(table);

            // Summary
            Paragraph summary = new Paragraph("Moyenne: " + String.format("%.2f", moyenneFinale) + "/20 — " + mention)
                .setTextAlignment(TextAlignment.RIGHT)
                .setBold();
            doc.add(summary);

            doc.close();
            return baos.toByteArray();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
```

---

### Task 12: SMSService (simulé ou réel)

**Files:**
- Create: `src/main/java/org/ict4d/notessup/services/SMSService.java`

- [ ] **Step 1: SMSService.java (simulé pour simplifier)**

```java
package org.ict4d.notessup.services;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.List;

public class SMSService {
    private static final Logger logger = LoggerFactory.getLogger(SMSService.class);

    public static void sendSMSNotification(List<String> phoneNumbers, String message) {
        // Simulé: log au lieu d'envoyer réellement
        for (String phone : phoneNumbers) {
            logger.info("SMS to " + phone + ": " + message);
        }
    }

    public static String getPublicationMessage(String filiere, double moyenneClass) {
        return "Vos notes sont disponibles sur NotesSup. " +
               "Connectez-vous avec votre matricule. " +
               "Moyenne classe: " + String.format("%.2f", moyenneClass) + "/20 — Scolarité";
    }

    public static String getAlertMessage(String etudiant, double moyenne) {
        return "Attention " + etudiant + ", votre moyenne est de " + 
               String.format("%.2f", moyenne) + "/20. " +
               "Présentez-vous à la scolarité.";
    }
}
```

---

## Phase 4: Web.xml & Filters

### Task 13: web.xml (servlets + filters)

**Files:**
- Modify: `src/main/webapp/WEB-INF/web.xml`

- [ ] **Step 1: web.xml complet**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee 
         https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">

    <display-name>NotesSup</display-name>
    <description>Application de gestion des notes et bulletins</description>

    <!-- Session config -->
    <session-config>
        <cookie-config>
            <secure>false</secure>
            <http-only>true</http-only>
        </cookie-config>
        <tracking-mode>COOKIE</tracking-mode>
        <timeout>30</timeout>
    </session-config>

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

    <servlet>
        <servlet-name>LogoutServlet</servlet-name>
        <servlet-class>org.ict4d.notessup.servlets.LogoutServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>LogoutServlet</servlet-name>
        <url-pattern>/logout</url-pattern>
    </servlet-mapping>

    <servlet>
        <servlet-name>EtudiantServlet</servlet-name>
        <servlet-class>org.ict4d.notessup.servlets.EtudiantServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>EtudiantServlet</servlet-name>
        <url-pattern>/etudiants</url-pattern>
    </servlet-mapping>

    <servlet>
        <servlet-name>MatiereServlet</servlet-name>
        <servlet-class>org.ict4d.notessup.servlets.MatiereServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>MatiereServlet</servlet-name>
        <url-pattern>/matieres</url-pattern>
    </servlet-mapping>

    <servlet>
        <servlet-name>NoteServlet</servlet-name>
        <servlet-class>org.ict4d.notessup.servlets.NoteServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>NoteServlet</servlet-name>
        <url-pattern>/notes</url-pattern>
    </servlet-mapping>

    <servlet>
        <servlet-name>DashboardServlet</servlet-name>
        <servlet-class>org.ict4d.notessup.servlets.DashboardServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>DashboardServlet</servlet-name>
        <url-pattern>/dashboard</url-pattern>
    </servlet-mapping>

    <servlet>
        <servlet-name>DeliberationServlet</servlet-name>
        <servlet-class>org.ict4d.notessup.servlets.DeliberationServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>DeliberationServlet</servlet-name>
        <url-pattern>/deliberations</url-pattern>
    </servlet-mapping>

    <servlet>
        <servlet-name>BulletinServlet</servlet-name>
        <servlet-class>org.ict4d.notessup.servlets.BulletinServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>BulletinServlet</servlet-name>
        <url-pattern>/bulletins</url-pattern>
    </servlet-mapping>

    <servlet>
        <servlet-name>StatistiquesServlet</servlet-name>
        <servlet-class>org.ict4d.notessup.servlets.StatistiquesServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>StatistiquesServlet</servlet-name>
        <url-pattern>/statistiques</url-pattern>
    </servlet-mapping>

    <servlet>
        <servlet-name>ExportServlet</servlet-name>
        <servlet-class>org.ict4d.notessup.servlets.ExportServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>ExportServlet</servlet-name>
        <url-pattern>/export</url-pattern>
    </servlet-mapping>

    <!-- Error pages -->
    <error-page>
        <error-code>404</error-code>
        <location>/WEB-INF/vues/404.jsp</location>
    </error-page>
    <error-page>
        <error-code>500</error-code>
        <location>/WEB-INF/vues/500.jsp</location>
    </error-page>

    <!-- Welcome page -->
    <welcome-file-list>
        <welcome-file>login</welcome-file>
    </welcome-file-list>
</web-app>
```

---

### Task 14: AuthenticationFilter & SecurityHeaderFilter

**Files:**
- Create: `src/main/java/org/ict4d/notessup/filters/AuthenticationFilter.java`
- Create: `src/main/java/org/ict4d/notessup/filters/SecurityHeaderFilter.java`

- [ ] **Step 1: AuthenticationFilter.java**

```java
package org.ict4d.notessup.filters;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.ict4d.notessup.utils.Constants;
import java.io.IOException;

public class AuthenticationFilter implements Filter {

    private static final String[] PUBLIC_URLS = {"/login", "/export"};

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String requestURI = httpRequest.getRequestURI();
        
        // Check if URL is public
        boolean isPublicUrl = false;
        for (String publicUrl : PUBLIC_URLS) {
            if (requestURI.contains(publicUrl)) {
                isPublicUrl = true;
                break;
            }
        }

        if (isPublicUrl) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);
        if (session == null || session.getAttribute(Constants.SESSION_USER) == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        chain.doFilter(request, response);
    }
}
```

- [ ] **Step 2: SecurityHeaderFilter.java**

```java
package org.ict4d.notessup.filters;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class SecurityHeaderFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        httpResponse.setHeader("X-Frame-Options", "DENY");
        httpResponse.setHeader("X-Content-Type-Options", "nosniff");
        httpResponse.setHeader("X-XSS-Protection", "1; mode=block");
        httpResponse.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains");

        chain.doFilter(request, response);
    }
}
```

---

## Phase 5: Servlets (CRUD dispatchers)

### Task 15: LoginServlet

**Files:**
- Create: `src/main/java/org/ict4d/notessup/servlets/LoginServlet.java`

- [ ] **Step 1: LoginServlet.java**

```java
package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.ict4d.notessup.models.User;
import org.ict4d.notessup.services.AuthService;
import org.ict4d.notessup.utils.Constants;
import java.io.IOException;
import java.sql.SQLException;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute(Constants.SESSION_USER) != null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/vues/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String login = request.getParameter("login");
        String password = request.getParameter("password");

        try {
            User user = AuthService.authenticate(login, password);
            if (user != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute(Constants.SESSION_USER, user);
                session.setAttribute(Constants.SESSION_ROLE, user.getRole());
                response.sendRedirect(request.getContextPath() + "/dashboard");
            } else {
                request.setAttribute("error", "Identifiant ou mot de passe incorrect");
                request.getRequestDispatcher("/WEB-INF/vues/login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(500);
        }
    }
}
```

---

### Task 16: LogoutServlet

**Files:**
- Create: `src/main/java/org/ict4d/notessup/servlets/LogoutServlet.java`

- [ ] **Step 1: LogoutServlet.java**

```java
package org.ict4d.notessup.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
```

---

### Task 17–24: CRUD Servlets (Etudiant, Matiere, Note, Deliberation, Dashboard, Bulletin, Statistiques, Export)

*(Each servlet ~60–100 lignes, pattern identique: GET list → forward JSP, POST/PUT → DAO save, DELETE → DAO delete)*

---

## Phase 6: JSPs (Rendu HTML)

### Task 25: CSS Design Tokens

**Files:**
- Create: `src/main/webapp/css/style.css`

- [ ] **Step 1: style.css (design tokens complets)**

```css
/* Design tokens du README handoff */
:root {
  --bg-app: oklch(0.965 0.006 248);
  --bg-white: #ffffff;
  --sidebar-bg: oklch(0.155 0.04 252);
  --sidebar-hover: oklch(0.22 0.05 252);
  --sidebar-text: oklch(0.70 0.04 252);
  --accent-blue: oklch(0.56 0.16 252);
  --accent-green: oklch(0.58 0.14 160);
  --accent-red: oklch(0.56 0.18 22);
  --accent-amber: oklch(0.72 0.16 72);
  --border-light: oklch(0.91 0.006 248);
  --text-primary: oklch(0.18 0.04 252);
  --text-secondary: oklch(0.52 0.02 252);
}

@import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&family=DM+Mono:wght@400;500;600&display=swap');

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'DM Sans', sans-serif;
  background-color: var(--bg-app);
  color: var(--text-primary);
  line-height: 1.5;
}

/* Layout */
.main-layout {
  display: flex;
}

.sidebar {
  position: fixed;
  left: 0;
  top: 0;
  width: 240px;
  height: 100vh;
  background-color: var(--sidebar-bg);
  padding: 24px;
  overflow-y: auto;
  z-index: 100;
}

main {
  margin-left: 240px;
  padding: 32px 36px;
  min-height: 100vh;
  background-color: var(--bg-app);
}

/* Sidebar items */
.sidebar-item {
  display: block;
  width: 100%;
  padding: 12px 16px;
  margin-bottom: 8px;
  text-decoration: none;
  color: var(--sidebar-text);
  border-radius: 8px;
  transition: background-color 0.12s;
}

.sidebar-item:hover {
  background-color: var(--sidebar-hover);
}

.sidebar-item.active {
  background-color: var(--sidebar-hover);
  color: white;
}

/* Cards */
.card {
  background-color: var(--bg-white);
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  margin-bottom: 24px;
}

/* Buttons */
.btn {
  display: inline-block;
  padding: 10px 16px;
  border: none;
  border-radius: 8px;
  font-size: 13.5px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-primary {
  background-color: var(--accent-blue);
  color: white;
}

.btn-primary:hover {
  opacity: 0.9;
}

.btn-danger {
  background-color: var(--accent-red);
  color: white;
}

/* Tables */
table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 16px;
}

th {
  background-color: var(--bg-app);
  padding: 12px;
  text-align: left;
  font-weight: 600;
  border-bottom: 2px solid var(--border-light);
}

td {
  padding: 12px;
  border-bottom: 1px solid var(--border-light);
}

tr:nth-child(even) {
  background-color: oklch(0.985 0.003 248);
}

/* Forms */
.form-group {
  margin-bottom: 16px;
}

label {
  display: block;
  margin-bottom: 6px;
  font-size: 12.5px;
  font-weight: 500;
  color: var(--text-primary);
}

input, select, textarea {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid var(--border-light);
  border-radius: 8px;
  font-size: 13.5px;
  font-family: inherit;
}

input:focus, select:focus {
  outline: none;
  border-color: var(--accent-blue);
  box-shadow: 0 0 0 3px rgba(59, 111, 212, 0.1);
}

/* Badges */
.badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11.5px;
  font-weight: 600;
}

.badge-success {
  background-color: rgba(5, 150, 105, 0.1);
  color: var(--accent-green);
}

.badge-danger {
  background-color: rgba(220, 38, 38, 0.1);
  color: var(--accent-red);
}

/* Page headers */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

.page-header h1 {
  font-size: 22px;
  font-weight: 700;
}

.page-header .subtitle {
  font-size: 13.5px;
  color: var(--text-secondary);
}
```

---

### Task 26–35: JSPs (login, dashboard, CRUD lists/forms, etc.)

*(Each JSP ~30–50 lignes, structure standard: form input ou table affichage, script JS léger pour validation)*

---

## Phase 7: Test & Déploiement

### Task 36: Build & Deploy

- [ ] **Step 1: Build WAR**

```bash
cd /path/to/NotesSup
mvn clean package
# Expected: target/NotesSup-1.0-SNAPSHOT.war created
```

- [ ] **Step 2: Copy WAR to Tomcat**

```bash
cp target/NotesSup-1.0-SNAPSHOT.war /path/to/apache-tomcat-X.Y.Z/webapps/NotesSup.war
```

- [ ] **Step 3: Test accès application**

```bash
# Tomcat should auto-deploy
# Visit http://localhost:8080/NotesSup
# Should redirect to login
```

- [ ] **Step 4: Test login flows (3 roles)**

Login avec:
- `chef` / `root123` → Dashboard chef
- `prof1` / `root123` → Dashboard enseignant
- `etud1` / `root123` → Dashboard étudiant

---

## Plan Summary

| Phase | Tasks | Effort |
|-------|-------|--------|
| Fondations | 1–3 | Pom, Docker, Utils |
| Models & DAOs | 4–8 | 5 models + 5 DAOs + BaseDAO |
| Services | 9–12 | Auth, NoteService, PDF, SMS |
| Web & Filters | 13–14 | web.xml + filters |
| Servlets | 15–24 | 8–10 servlets CRUD |
| JSPs | 25–35 | CSS + 10 JSPs |
| Test & Deploy | 36 | Build & verify |

**Total:** ~36 tâches de 2–5 min chacune = ~2–3 heures dev continu.

---

## Execution Checklist

- [ ] Phase 1: Docker + pom + utilities ready
- [ ] Phase 2: Models + DAOs tested (find methods work)
- [ ] Phase 3: Services compiled, no SQL errors
- [ ] Phase 4: web.xml valid, filters compile
- [ ] Phase 5: All servlets map correctly
- [ ] Phase 6: JSPs render without errors
- [ ] Phase 7: Application deployable, login works

