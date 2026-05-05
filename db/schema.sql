-- ============================================================
--  NotesSup — Schéma complet + données de démonstration
--  Université de l'ICT — Département Informatique
--  Année académique 2025-2026
-- ============================================================

DROP DATABASE IF EXISTS notessup_db;
CREATE DATABASE notessup_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE notessup_db;

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
--  TABLE: user
-- ============================================================
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id`          BIGINT AUTO_INCREMENT PRIMARY KEY,
  `login`       VARCHAR(50)  NOT NULL UNIQUE,
  `password`    TEXT         NOT NULL,
  `role`        ENUM('CHEF_DEPT','ENSEIGNANT','ETUDIANT') NOT NULL,
  `nom`         VARCHAR(100) NOT NULL,
  `filiere`     VARCHAR(80),
  `etudiant_id` BIGINT,
  `created_at`  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
--  TABLE: etudiant
-- ============================================================
DROP TABLE IF EXISTS `etudiant`;
CREATE TABLE `etudiant` (
  `id`          BIGINT AUTO_INCREMENT PRIMARY KEY,
  `matricule`   VARCHAR(20)  NOT NULL UNIQUE,
  `nom`         VARCHAR(100) NOT NULL,
  `prenom`      VARCHAR(100) NOT NULL,
  `filiere`     VARCHAR(80)  NOT NULL,
  `annee`       INT          NOT NULL CHECK (annee BETWEEN 1 AND 5),
  `telephone`   VARCHAR(20),
  `created_at`  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
--  TABLE: matiere
-- ============================================================
DROP TABLE IF EXISTS `matiere`;
CREATE TABLE `matiere` (
  `id`          BIGINT AUTO_INCREMENT PRIMARY KEY,
  `code`        VARCHAR(15)  NOT NULL UNIQUE,
  `intitule`    VARCHAR(150) NOT NULL,
  `coefficient` INT          NOT NULL CHECK (coefficient BETWEEN 1 AND 6),
  `enseignant`  VARCHAR(100),
  `semestre`    INT          NOT NULL CHECK (semestre IN (1, 2)),
  `filiere`     VARCHAR(80)  NOT NULL,
  `created_at`  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
--  TABLE: note
-- ============================================================
DROP TABLE IF EXISTS `note`;
CREATE TABLE `note` (
  `id`              BIGINT AUTO_INCREMENT PRIMARY KEY,
  `etudiant_id`     BIGINT           NOT NULL,
  `matiere_id`      BIGINT           NOT NULL,
  `note_cc`         DECIMAL(5,2),
  `note_exam`       DECIMAL(5,2),
  `note_finale`     DECIMAL(5,2),
  `session`         ENUM('NORMALE','RATTRAPAGE') DEFAULT 'NORMALE',
  `annee_academique` VARCHAR(9),
  `saisie_par`      VARCHAR(100),
  `created_at`      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_note` (etudiant_id, matiere_id, session, annee_academique),
  FOREIGN KEY (etudiant_id) REFERENCES etudiant(id) ON DELETE CASCADE,
  FOREIGN KEY (matiere_id)  REFERENCES matiere(id)  ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
--  TABLE: deliberation
-- ============================================================
DROP TABLE IF EXISTS `deliberation`;
CREATE TABLE `deliberation` (
  `id`               BIGINT AUTO_INCREMENT PRIMARY KEY,
  `filiere`          VARCHAR(80)  NOT NULL,
  `session`          ENUM('NORMALE','RATTRAPAGE') DEFAULT 'NORMALE',
  `annee_academique` VARCHAR(9),
  `date_publication` DATE,
  `publiee`          BOOLEAN DEFAULT FALSE,
  `publiee_par`      VARCHAR(100),
  `created_at`       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
--  DONNÉES: users
--  Mot de passe pour tous: "root123"
--  Hash BCrypt (cost=10): $2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe
-- ============================================================
INSERT INTO `user` (login, password, role, nom, filiere) VALUES
-- Administration
('chef',       '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'CHEF_DEPT',  'Dr. Amadou Diallo',      'Informatique'),

-- Enseignants Informatique
('mdiop',      '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ENSEIGNANT', 'M. Moussa Diop',         'Informatique'),
('fname',      '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ENSEIGNANT', 'Mme Fatou Ndiaye',        'Informatique'),
('ifall',      '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ENSEIGNANT', 'M. Ibrahima Fall',        'Informatique'),

-- Enseignants Réseaux
('abalde',     '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ENSEIGNANT', 'M. Aliou Baldé',          'Réseaux'),
('mba',        '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ENSEIGNANT', 'Mme Mariama Ba',          'Réseaux'),

-- Étudiants Informatique L3
('akonare',    '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT',   'Aminata Konaré',         'Informatique'),
('sthiam',     '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT',   'Seydou Thiam',           'Informatique'),
('rcoulibaly', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT',   'Rokhaya Coulibaly',      'Informatique'),
('mbaldé',    '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT',   'Mamadou Baldé',          'Informatique'),
('adembele',   '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT',   'Aïssatou Dembélé',      'Informatique'),

-- Étudiants Réseaux L3
('odiallo',    '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT',   'Oumar Diallo',           'Réseaux'),
('ksiss',      '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT',   'Kadiatou Sissoko',       'Réseaux');


-- ============================================================
--  DONNÉES: étudiants
-- ============================================================
INSERT INTO `etudiant` (matricule, nom, prenom, filiere, annee, telephone) VALUES
-- Informatique — L3 (année 3)
('2122INFO001', 'Konaré',    'Aminata',    'Informatique', 3, '+221 77 123 45 67'),
('2122INFO002', 'Thiam',     'Seydou',     'Informatique', 3, '+221 78 234 56 78'),
('2122INFO003', 'Coulibaly', 'Rokhaya',    'Informatique', 3, '+221 76 345 67 89'),
('2122INFO004', 'Baldé',     'Mamadou',    'Informatique', 3, '+221 77 456 78 90'),
('2122INFO005', 'Dembélé',  'Aïssatou',  'Informatique', 3, '+221 78 567 89 01'),
('2122INFO006', 'Camara',    'Lamine',     'Informatique', 3, '+221 76 678 90 12'),
('2122INFO007', 'Traoré',   'Mariama',    'Informatique', 3, '+221 77 789 01 23'),
('2122INFO008', 'Sow',       'Ibrahima',   'Informatique', 3, '+221 78 890 12 34'),
('2122INFO009', 'Barry',     'Fatoumata',  'Informatique', 3, '+221 76 901 23 45'),
('2122INFO010', 'Ndiaye',    'Cheikh',     'Informatique', 3, '+221 77 012 34 56'),

-- Informatique — L2 (année 2)
('2223INFO001', 'Keïta',    'Ousmane',    'Informatique', 2, '+221 78 111 22 33'),
('2223INFO002', 'Diarra',   'Néné',       'Informatique', 2, '+221 76 222 33 44'),
('2223INFO003', 'Touré',    'Abdoulaye',  'Informatique', 2, '+221 77 333 44 55'),

-- Réseaux — L3 (année 3)
('2122RES001', 'Diallo',    'Oumar',      'Réseaux',      3, '+221 78 444 55 66'),
('2122RES002', 'Sissoko',   'Kadiatou',   'Réseaux',      3, '+221 76 555 66 77'),
('2122RES003', 'Kouyaté',  'Bouba',      'Réseaux',      3, '+221 77 666 77 88'),
('2122RES004', 'Bah',       'Hawa',       'Réseaux',      3, '+221 78 777 88 99'),
('2122RES005', 'Sanogo',    'Drissa',     'Réseaux',      3, '+221 76 888 99 00');


-- ============================================================
--  DONNÉES: matières
-- ============================================================
INSERT INTO `matiere` (code, intitule, coefficient, enseignant, semestre, filiere) VALUES
-- Informatique — Semestre 1
('INFO301', 'Architecture Logicielle',        3, 'M. Moussa Diop',   1, 'Informatique'),
('INFO302', 'Bases de Données Avancées',      4, 'Mme Fatou Ndiaye', 1, 'Informatique'),
('INFO303', 'Développement Web Fullstack',    3, 'M. Ibrahima Fall', 1, 'Informatique'),
('INFO304', 'Systèmes d''Exploitation',       2, 'M. Moussa Diop',   1, 'Informatique'),
('INFO305', 'Mathématiques Discrètes',        2, 'Mme Fatou Ndiaye', 1, 'Informatique'),

-- Informatique — Semestre 2
('INFO306', 'Génie Logiciel',                 3, 'M. Ibrahima Fall', 2, 'Informatique'),
('INFO307', 'Sécurité Informatique',          3, 'M. Moussa Diop',   2, 'Informatique'),
('INFO308', 'Intelligence Artificielle',      4, 'Mme Fatou Ndiaye', 2, 'Informatique'),
('INFO309', 'Projet de Fin d''Année',         6, 'M. Ibrahima Fall', 2, 'Informatique'),

-- Réseaux — Semestre 1
('RES301', 'Protocoles Réseaux',              3, 'M. Aliou Baldé',   1, 'Réseaux'),
('RES302', 'Administration Systèmes Linux',   3, 'Mme Mariama Ba',   1, 'Réseaux'),
('RES303', 'Routage et Commutation',          4, 'M. Aliou Baldé',   1, 'Réseaux'),

-- Réseaux — Semestre 2
('RES304', 'Sécurité Réseaux',                4, 'Mme Mariama Ba',   2, 'Réseaux'),
('RES305', 'Cloud Computing',                 3, 'M. Aliou Baldé',   2, 'Réseaux'),
('RES306', 'Projet Réseau',                   6, 'Mme Mariama Ba',   2, 'Réseaux');


-- ============================================================
--  DONNÉES: notes (session NORMALE, 2025-2026)
--  note_finale = (note_cc * 0.4) + (note_exam * 0.6)
-- ============================================================
INSERT INTO `note`
  (etudiant_id, matiere_id, note_cc, note_exam, note_finale, session, annee_academique, saisie_par)
VALUES
-- ── Aminata Konaré (id=1) — très bonne étudiante ──────────────────────
(1, 1, 17.00, 18.00, 17.60, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(1, 2, 16.00, 17.50, 16.90, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(1, 3, 18.00, 16.50, 17.10, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(1, 4, 15.00, 16.00, 15.60, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(1, 5, 14.00, 15.00, 14.60, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(1, 6, 17.00, 18.50, 17.90, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(1, 7, 15.50, 16.00, 15.80, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(1, 8, 16.00, 17.00, 16.60, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),

-- ── Seydou Thiam (id=2) — étudiant solide ────────────────────────────
(2, 1, 13.00, 14.50, 13.90, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(2, 2, 12.50, 13.00, 12.80, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(2, 3, 14.00, 12.50, 13.10, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(2, 4, 11.00, 12.00, 11.60, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(2, 5, 10.50, 11.00, 10.80, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(2, 6, 13.00, 14.00, 13.60, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(2, 7, 12.00, 11.50, 11.70, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(2, 8, 13.50, 12.00, 12.60, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),

-- ── Rokhaya Coulibaly (id=3) — moyenne ──────────────────────────────
(3, 1, 10.00, 11.00, 10.60, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(3, 2, 11.00, 10.00, 10.40, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(3, 3, 12.00, 10.50, 11.10, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(3, 4,  9.50, 10.50, 10.10, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(3, 5, 10.00,  9.50,  9.70, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(3, 6, 11.50, 10.00, 10.60, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(3, 7,  9.00, 10.00,  9.60, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(3, 8, 10.00, 11.50, 10.90, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),

-- ── Mamadou Baldé (id=4) — quelques difficultés ─────────────────────
(4, 1,  8.00, 10.00,  9.20, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(4, 2,  7.50,  9.00,  8.40, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(4, 3,  9.00,  8.50,  8.70, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(4, 4, 10.00,  9.00,  9.40, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(4, 5,  8.50,  7.50,  7.90, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(4, 6,  9.50, 11.00, 10.40, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(4, 7,  8.00,  9.00,  8.60, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(4, 8,  7.00,  8.50,  7.90, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),

-- ── Aïssatou Dembélé (id=5) — bonne étudiante ──────────────────────
(5, 1, 14.00, 15.50, 14.90, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(5, 2, 15.00, 14.00, 14.40, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(5, 3, 13.50, 15.00, 14.40, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(5, 4, 12.00, 14.00, 13.20, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(5, 5, 13.00, 12.50, 12.70, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(5, 6, 14.50, 15.00, 14.80, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(5, 7, 13.00, 14.50, 13.90, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(5, 8, 14.00, 13.50, 13.70, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),

-- ── Lamine Camara (id=6) ─────────────────────────────────────────────
(6, 1, 11.00, 12.50, 11.90, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(6, 2, 10.50, 11.00, 10.80, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(6, 3, 12.00, 11.00, 11.40, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(6, 4, 10.00, 11.50, 10.90, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(6, 5,  9.50, 10.00,  9.80, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(6, 6, 11.00, 12.00, 11.60, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(6, 7, 10.50, 10.00, 10.20, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(6, 8, 11.50, 12.00, 11.80, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),

-- ── Mariama Traoré (id=7) ────────────────────────────────────────────
(7, 1, 15.00, 14.00, 14.40, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(7, 2, 13.50, 14.50, 14.10, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(7, 3, 14.50, 15.50, 15.10, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(7, 4, 12.00, 13.00, 12.60, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(7, 5, 11.00, 12.00, 11.60, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(7, 6, 14.00, 13.50, 13.70, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(7, 7, 13.00, 14.00, 13.60, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(7, 8, 15.00, 14.00, 14.40, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),

-- ── Ibrahima Sow (id=8) ──────────────────────────────────────────────
(8, 1,  6.00,  7.50,  6.90, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(8, 2,  7.00,  6.00,  6.40, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(8, 3,  5.50,  7.00,  6.40, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(8, 4,  8.00,  7.00,  7.40, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(8, 5,  6.50,  5.00,  5.60, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(8, 6,  7.50,  8.00,  7.80, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(8, 7,  6.00,  7.00,  6.60, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(8, 8,  7.00,  6.50,  6.70, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),

-- ── Fatoumata Barry (id=9) ───────────────────────────────────────────
(9, 1, 16.50, 15.00, 15.60, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(9, 2, 14.00, 15.50, 14.90, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(9, 3, 15.00, 14.00, 14.40, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(9, 4, 13.00, 14.00, 13.60, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(9, 5, 12.50, 13.00, 12.80, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(9, 6, 15.00, 16.00, 15.60, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(9, 7, 14.50, 13.50, 13.90, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(9, 8, 15.50, 14.50, 14.90, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),

-- ── Cheikh Ndiaye (id=10) ────────────────────────────────────────────
(10, 1,  9.00, 10.00,  9.60, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(10, 2, 10.50,  9.50,  9.90, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(10, 3, 11.00, 10.00, 10.40, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(10, 4,  8.50, 10.00,  9.40, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(10, 5,  9.00,  8.00,  8.40, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),
(10, 6, 10.00, 11.00, 10.60, 'NORMALE', '2025-2026', 'M. Ibrahima Fall'),
(10, 7,  9.50,  9.00,  9.20, 'NORMALE', '2025-2026', 'M. Moussa Diop'),
(10, 8, 10.00, 10.50, 10.30, 'NORMALE', '2025-2026', 'Mme Fatou Ndiaye'),

-- ── Oumar Diallo (id=14 = Réseaux) ───────────────────────────────────
(14, 10, 14.00, 15.00, 14.60, 'NORMALE', '2025-2026', 'M. Aliou Baldé'),
(14, 11, 13.00, 12.00, 12.40, 'NORMALE', '2025-2026', 'Mme Mariama Ba'),
(14, 12, 15.50, 14.50, 14.90, 'NORMALE', '2025-2026', 'M. Aliou Baldé'),
(14, 13, 12.00, 13.50, 12.90, 'NORMALE', '2025-2026', 'Mme Mariama Ba'),
(14, 14, 11.50, 13.00, 12.40, 'NORMALE', '2025-2026', 'M. Aliou Baldé'),

-- ── Kadiatou Sissoko (id=15) ─────────────────────────────────────────
(15, 10, 16.00, 17.00, 16.60, 'NORMALE', '2025-2026', 'M. Aliou Baldé'),
(15, 11, 15.50, 16.00, 15.80, 'NORMALE', '2025-2026', 'Mme Mariama Ba'),
(15, 12, 17.00, 16.00, 16.40, 'NORMALE', '2025-2026', 'M. Aliou Baldé'),
(15, 13, 14.50, 16.00, 15.40, 'NORMALE', '2025-2026', 'Mme Mariama Ba'),
(15, 14, 13.00, 14.50, 13.90, 'NORMALE', '2025-2026', 'M. Aliou Baldé'),

-- ── Bouba Kouyaté (id=16) ───────────────────────────────────────────
(16, 10,  9.50, 10.50, 10.10, 'NORMALE', '2025-2026', 'M. Aliou Baldé'),
(16, 11, 10.00,  9.00,  9.40, 'NORMALE', '2025-2026', 'Mme Mariama Ba'),
(16, 12,  8.00,  9.50,  8.90, 'NORMALE', '2025-2026', 'M. Aliou Baldé'),
(16, 13, 11.00, 10.00, 10.40, 'NORMALE', '2025-2026', 'Mme Mariama Ba'),
(16, 14,  9.00, 10.00,  9.60, 'NORMALE', '2025-2026', 'M. Aliou Baldé'),

-- ── Hawa Bah (id=17) ─────────────────────────────────────────────────
(17, 10, 12.00, 13.00, 12.60, 'NORMALE', '2025-2026', 'M. Aliou Baldé'),
(17, 11, 11.50, 12.50, 12.10, 'NORMALE', '2025-2026', 'Mme Mariama Ba'),
(17, 12, 13.50, 12.00, 12.60, 'NORMALE', '2025-2026', 'M. Aliou Baldé'),
(17, 13, 10.50, 12.00, 11.40, 'NORMALE', '2025-2026', 'Mme Mariama Ba'),
(17, 14, 12.00, 11.00, 11.40, 'NORMALE', '2025-2026', 'M. Aliou Baldé'),

-- ── Drissa Sanogo (id=18) — en difficulté ────────────────────────────
(18, 10,  7.00,  8.00,  7.60, 'NORMALE', '2025-2026', 'M. Aliou Baldé'),
(18, 11,  6.50,  7.50,  7.10, 'NORMALE', '2025-2026', 'Mme Mariama Ba'),
(18, 12,  5.00,  6.00,  5.60, 'NORMALE', '2025-2026', 'M. Aliou Baldé'),
(18, 13,  8.00,  7.00,  7.40, 'NORMALE', '2025-2026', 'Mme Mariama Ba'),
(18, 14,  6.00,  7.50,  6.90, 'NORMALE', '2025-2026', 'M. Aliou Baldé');


-- ============================================================
--  DONNÉES: délibérations
-- ============================================================
INSERT INTO `deliberation` (filiere, session, annee_academique, date_publication, publiee, publiee_par) VALUES
('Informatique', 'NORMALE',    '2025-2026', '2026-02-15', TRUE,  'Dr. Amadou Diallo'),
('Réseaux',      'NORMALE',    '2025-2026', NULL,         FALSE, NULL);


-- ============================================================
--  MISE À JOUR: lier users étudiants ↔ etudiant
-- ============================================================
UPDATE `user` SET etudiant_id = (SELECT id FROM etudiant WHERE matricule = '2122INFO001') WHERE login = 'akonare';
UPDATE `user` SET etudiant_id = (SELECT id FROM etudiant WHERE matricule = '2122INFO002') WHERE login = 'sthiam';
UPDATE `user` SET etudiant_id = (SELECT id FROM etudiant WHERE matricule = '2122INFO003') WHERE login = 'rcoulibaly';
UPDATE `user` SET etudiant_id = (SELECT id FROM etudiant WHERE matricule = '2122INFO004') WHERE login = 'mbaldé';
UPDATE `user` SET etudiant_id = (SELECT id FROM etudiant WHERE matricule = '2122INFO005') WHERE login = 'adembele';
UPDATE `user` SET etudiant_id = (SELECT id FROM etudiant WHERE matricule = '2122RES001')  WHERE login = 'odiallo';
UPDATE `user` SET etudiant_id = (SELECT id FROM etudiant WHERE matricule = '2122RES002')  WHERE login = 'ksiss';
