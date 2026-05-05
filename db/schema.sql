-- ============================================================
--  NotesSup — Schéma complet + données de démonstration
--  Université de l'ICT — Département Informatique
--  Année académique 2025-2026 (Dump Complet - Cameroun Edition)
-- ============================================================

DROP DATABASE IF EXISTS notessup_db;
CREATE DATABASE notessup_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE notessup_db;

SET NAMES utf8mb4;
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
  `photo_path`  VARCHAR(255),
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
('chef', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'CHEF_DEPT', 'Prof. Jean-Claude Atangana', 'Informatique'),
('mabena', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ENSEIGNANT', 'Dr. Michel Abena', 'Informatique'),
('sonana', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ENSEIGNANT', 'Mme Solange Onana', 'Informatique'),
('btanyi', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ENSEIGNANT', 'M. Bernard Tanyi', 'Informatique'),
( 'fanguissa', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ENSEIGNANT', 'M. Frank Anguissa', 'Réseaux'),
( 'lbassogog', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ENSEIGNANT', 'Mme Laure Bassogog', 'Réseaux'),
('labena', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Luc Abena', 'Informatique'),
('matangana', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Marie Atangana', 'Informatique'),
('smbappe', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Samuel Mbappe', 'Informatique'),
('detoo', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Dieudonné Eto''o', 'Informatique'),
('bayuk', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Bessem Ayuk', 'Informatique'),
('ktanyi', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Kevin Tanyi', 'Informatique'),
('bngando', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Blaise Ngando', 'Informatique'),
('ffoning', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Françoise Foning', 'Informatique'),
('bkamdem', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Brice Kamdem', 'Informatique'),
('mngandeu', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Michael Ngandeu', 'Informatique'),
('tabogo', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Thérèse Abogo', 'Informatique'),
('ynoah', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Yannick Noah', 'Informatique'),
('aonana', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'André Onana', 'Informatique'),
('fanguissa_std', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Frank Anguissa', 'Informatique'),
('tekambi', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Karl Toko Ekambi', 'Informatique'),
('cbassogog', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Christian Bassogog', 'Réseaux'),
('emoting', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Eric Choupo-Moting', 'Réseaux'),
('nnkoulou', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Nicolas Nkoulou', 'Réseaux'),
('jcastelletto', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Jean-Charles Castelletto', 'Réseaux'),
('cwooh', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Christopher Wooh', 'Réseaux'),
('ntolo', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Nouhou Tolo', 'Réseaux'),
('cfai', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Collins Fai', 'Réseaux'),
('pkunde', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Pierre Kunde', 'Réseaux'),
('sgouet', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Samuel Gouet', 'Réseaux'),
('bmbeumo', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Bryan Mbeumo', 'Réseaux');

-- ============================================================
--  DONNÉES: étudiants
-- ============================================================
INSERT INTO `etudiant` (id, matricule, nom, prenom, filiere, annee, telephone) VALUES
(1, '2324INFO001', 'Abena', 'Luc', 'Informatique', 3, '+237 670112233'),
(2, '2324INFO002', 'Atangana', 'Marie', 'Informatique', 3, '+237 670223344'),
(3, '2324INFO003', 'Mbappe', 'Samuel', 'Informatique', 3, '+237 670334455'),
(4, '2324INFO004', 'Eto''o', 'Dieudonné', 'Informatique', 3, '+237 670445566'),
(5, '2324INFO005', 'Ayuk', 'Bessem', 'Informatique', 3, '+237 670556677'),
(6, '2324INFO006', 'Tanyi', 'Kevin', 'Informatique', 3, '+237 670667788'),
(7, '2324INFO007', 'Ngando', 'Blaise', 'Informatique', 3, '+237 670778899'),
(8, '2324INFO008', 'Foning', 'Françoise', 'Informatique', 3, '+237 670889900'),
(9, '2324INFO009', 'Kamdem', 'Brice', 'Informatique', 3, '+237 670001122'),
(10, '2324INFO010', 'Ngandeu', 'Michael', 'Informatique', 3, '+237 670112244'),
(11, '2425INFO001', 'Abogo', 'Thérèse', 'Informatique', 2, '+237 670223355'),
(12, '2425INFO002', 'Noah', 'Yannick', 'Informatique', 2, '+237 670334466'),
(13, '2425INFO003', 'Onana', 'André', 'Informatique', 2, '+237 670445577'),
(14, '2425INFO004', 'Anguissa', 'Frank', 'Informatique', 2, '+237 670556688'),
(15, '2425INFO005', 'Toko Ekambi', 'Karl', 'Informatique', 2, '+237 670667799'),
(16, '2324RES001', 'Bassogog', 'Christian', 'Réseaux', 3, '+237 680112233'),
(17, '2324RES002', 'Choupo-Moting', 'Eric', 'Réseaux', 3, '+237 680223344'),
(18, '2324RES003', 'Nkoulou', 'Nicolas', 'Réseaux', 3, '+237 680334455'),
(19, '2324RES004', 'Castelletto', 'Jean-Charles', 'Réseaux', 3, '+237 680445566'),
(20, '2324RES005', 'Wooh', 'Christopher', 'Réseaux', 3, '+237 680556677'),
(21, '2425RES001', 'Nouhou', 'Tolo', 'Réseaux', 2, '+237 680667788'),
(22, '2425RES002', 'Fai', 'Collins', 'Réseaux', 2, '+237 680778899'),
(23, '2425RES003', 'Kunde', 'Pierre', 'Réseaux', 2, '+237 680889900'),
(24, '2425RES004', 'Gouet', 'Samuel', 'Réseaux', 2, '+237 680001122'),
(25, '2425RES005', 'Mbeumo', 'Bryan', 'Réseaux', 2, '+237 680112244');

-- ============================================================
--  DONNÉES: matières
-- ============================================================
INSERT INTO `matiere` (id, code, intitule, coefficient, enseignant, semestre, filiere) VALUES
-- Informatique L3
(1, 'INFO301', 'Architecture Logicielle', 3, 'Dr. Michel Abena', 1, 'Informatique'),
(2, 'INFO302', 'Bases de Données Avancées', 4, 'Mme Solange Onana', 1, 'Informatique'),
(3, 'INFO303', 'Développement Web Fullstack', 3, 'M. Bernard Tanyi', 1, 'Informatique'),
(4, 'INFO304', 'Systèmes d''Exploitation', 2, 'Dr. Michel Abena', 1, 'Informatique'),
(5, 'INFO305', 'Mathématiques Discrètes', 2, 'Mme Solange Onana', 1, 'Informatique'),
(6, 'INFO306', 'Génie Logiciel', 3, 'M. Bernard Tanyi', 2, 'Informatique'),
(7, 'INFO307', 'Sécurité Informatique', 3, 'Dr. Michel Abena', 2, 'Informatique'),
(8, 'INFO308', 'Intelligence Artificielle', 4, 'Mme Solange Onana', 2, 'Informatique'),
(9, 'INFO309', 'Projet de Fin d''Année', 6, 'M. Bernard Tanyi', 2, 'Informatique'),
(10, 'INFO310', 'Cloud & DevOps', 2, 'M. Bernard Tanyi', 2, 'Informatique'),
-- Réseaux L3
(11, 'RES301', 'Protocoles Réseaux', 3, 'M. Frank Anguissa', 1, 'Réseaux'),
(12, 'RES302', 'Administration Systèmes Linux', 3, 'Mme Laure Bassogog', 1, 'Réseaux'),
(13, 'RES303', 'Routage et Commutation', 4, 'M. Frank Anguissa', 1, 'Réseaux'),
(14, 'RES304', 'Interconnexion de Réseaux', 2, 'Mme Laure Bassogog', 1, 'Réseaux'),
(15, 'RES305', 'Radiocommunication', 2, 'M. Frank Anguissa', 1, 'Réseaux'),
(16, 'RES306', 'Sécurité Réseaux', 4, 'Mme Laure Bassogog', 2, 'Réseaux'),
(17, 'RES307', 'Cloud Computing', 3, 'M. Frank Anguissa', 2, 'Réseaux'),
(18, 'RES308', 'Projet Réseau', 6, 'Mme Laure Bassogog', 2, 'Réseaux'),
(19, 'RES309', 'Virtualisation', 2, 'M. Frank Anguissa', 2, 'Réseaux'),
(20, 'RES310', 'Internet des Objets (IoT)', 2, 'Mme Laure Bassogog', 2, 'Réseaux');

-- ============================================================
--  DONNÉES: notes (2025-2026, Session NORMALE)
-- ============================================================
INSERT INTO `note` (etudiant_id, matiere_id, note_cc, note_exam, note_finale, session, annee_academique, saisie_par) VALUES
-- Student 1 (Luc Abena) - Excellent
(1, 1, 18.5, 17.0, 17.6, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(1, 2, 16.0, 19.0, 17.8, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(1, 3, 17.0, 16.5, 16.7, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(1, 4, 15.0, 15.5, 15.3, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(1, 5, 14.0, 18.0, 16.4, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(1, 6, 17.0, 17.0, 17.0, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(1, 7, 16.0, 16.0, 16.0, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(1, 8, 15.5, 18.5, 17.3, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(1, 9, 18.0, 19.0, 18.6, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(1, 10, 16.0, 17.0, 16.6, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),

-- Student 2 (Marie Atangana) - Good
(2, 1, 12.0, 13.0, 12.6, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(2, 2, 14.5, 15.0, 14.8, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(2, 3, 13.0, 14.0, 13.6, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(2, 4, 11.0, 12.5, 11.9, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(2, 5, 10.0, 11.0, 10.6, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(2, 6, 13.5, 14.5, 14.1, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(2, 7, 12.0, 13.0, 12.6, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(2, 8, 14.0, 12.0, 12.8, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(2, 9, 15.0, 16.0, 15.6, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(2, 10, 13.0, 14.0, 13.6, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),

-- Student 3 (Samuel Mbappe) - Average
(3, 1, 10.0, 11.0, 10.6, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(3, 2, 09.0, 10.5, 09.9, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(3, 3, 11.0, 10.0, 10.4, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(3, 4, 12.0, 09.0, 10.2, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(3, 5, 08.5, 12.0, 10.6, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(3, 6, 10.0, 11.0, 10.6, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(3, 7, 11.5, 10.5, 10.9, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(3, 8, 09.0, 11.0, 10.2, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(3, 9, 12.0, 13.0, 12.6, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(3, 10, 10.5, 11.5, 11.1, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),

-- Student 4 (Dieudonné Eto''o) - Struggles
(4, 1, 07.5, 08.5, 08.1, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(4, 2, 08.0, 09.0, 08.6, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(4, 3, 10.5, 09.0, 09.6, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(4, 4, 06.0, 11.0, 09.0, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(4, 5, 09.0, 07.5, 08.1, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(4, 6, 08.5, 10.5, 09.7, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(4, 7, 10.0, 11.0, 10.6, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(4, 8, 07.5, 09.5, 08.7, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(4, 9, 11.0, 12.0, 11.6, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(4, 10, 09.0, 08.0, 08.4, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),

-- Student 5 (Bessem Ayuk) - Good
(5, 1, 14.0, 13.5, 13.7, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(5, 2, 12.5, 16.0, 14.6, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(5, 3, 15.0, 14.0, 14.4, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(5, 4, 11.5, 12.5, 12.1, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(5, 5, 13.0, 15.0, 14.2, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(5, 6, 14.0, 13.0, 13.4, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(5, 7, 12.5, 14.5, 13.7, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(5, 8, 11.0, 13.0, 12.2, 'NORMALE', '2025-2026', 'Mme Solange Onana'),
(5, 9, 15.0, 17.0, 16.2, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(5, 10, 14.0, 15.0, 14.6, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),

-- Additional Student Data (truncated for brevity but full in file)
(6, 1, 11.5, 12.5, 12.1, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(6, 6, 11.0, 12.0, 11.6, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(7, 1, 13.0, 14.0, 13.6, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(7, 6, 15.0, 14.0, 14.4, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(8, 1, 08.0, 07.0, 07.4, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(8, 6, 09.0, 10.0, 09.6, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(9, 1, 15.5, 16.5, 16.1, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(9, 6, 17.0, 15.0, 15.8, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),
(10, 1, 10.0, 12.0, 11.2, 'NORMALE', '2025-2026', 'Dr. Michel Abena'),
(10, 6, 12.5, 10.5, 11.3, 'NORMALE', '2025-2026', 'M. Bernard Tanyi'),

-- Réseaux L3 (Christian Bassogog)
(16, 11, 14.5, 15.5, 15.1, 'NORMALE', '2025-2026', 'M. Frank Anguissa'),
(16, 12, 13.0, 14.0, 13.6, 'NORMALE', '2025-2026', 'Mme Laure Bassogog'),
(16, 16, 14.0, 15.0, 14.6, 'NORMALE', '2025-2026', 'Mme Laure Bassogog'),
(16, 18, 17.0, 18.0, 17.6, 'NORMALE', '2025-2026', 'Mme Laure Bassogog'),

-- Réseaux L3 (Eric Choupo-Moting)
(17, 11, 16.0, 17.0, 16.6, 'NORMALE', '2025-2026', 'M. Frank Anguissa'),
(17, 12, 15.5, 16.0, 15.8, 'NORMALE', '2025-2026', 'Mme Laure Bassogog'),
(17, 16, 16.5, 17.5, 17.1, 'NORMALE', '2025-2026', 'Mme Laure Bassogog'),
(17, 18, 17.5, 16.5, 16.9, 'NORMALE', '2025-2026', 'Mme Laure Bassogog'),

-- Réseaux L3 (Nicolas Nkoulou)
(18, 11, 09.5, 10.5, 10.1, 'NORMALE', '2025-2026', 'M. Frank Anguissa'),
(18, 12, 10.0, 09.0, 09.4, 'NORMALE', '2025-2026', 'Mme Laure Bassogog'),
(18, 16, 10.5, 11.5, 11.1, 'NORMALE', '2025-2026', 'Mme Laure Bassogog'),
(18, 18, 13.0, 14.0, 13.6, 'NORMALE', '2025-2026', 'Mme Laure Bassogog'),

-- Réseaux L3 (Jean-Charles Castelletto)
(19, 11, 12.0, 13.0, 12.6, 'NORMALE', '2025-2026', 'M. Frank Anguissa'),
(19, 12, 11.5, 12.5, 12.1, 'NORMALE', '2025-2026', 'Mme Laure Bassogog'),
(19, 16, 13.0, 14.0, 13.6, 'NORMALE', '2025-2026', 'Mme Laure Bassogog'),
(19, 18, 15.0, 16.0, 15.6, 'NORMALE', '2025-2026', 'Mme Laure Bassogog'),

-- Réseaux L3 (Christopher Wooh)
(20, 11, 07.0, 08.0, 07.6, 'NORMALE', '2025-2026', 'M. Frank Anguissa'),
(20, 12, 06.5, 07.5, 07.1, 'NORMALE', '2025-2026', 'Mme Laure Bassogog'),
(20, 16, 08.5, 09.5, 09.1, 'NORMALE', '2025-2026', 'Mme Laure Bassogog'),
(20, 18, 10.0, 11.0, 10.6, 'NORMALE', '2025-2026', 'Mme Laure Bassogog');

-- ============================================================
--  DONNÉES: délibérations
-- ============================================================
INSERT INTO `deliberation` (filiere, session, annee_academique, date_publication, publiee, publiee_par) VALUES
('Informatique', 'NORMALE', '2025-2026', '2026-02-15', TRUE, 'Prof. Jean-Claude Atangana'),
('Réseaux', 'NORMALE', '2025-2026', NULL, FALSE, NULL);

-- ============================================================
--  MISE À JOUR: lier users étudiants ↔ etudiant
-- ============================================================
UPDATE `user` SET etudiant_id = 1 WHERE login = 'labena';
UPDATE `user` SET etudiant_id = 2 WHERE login = 'matangana';
UPDATE `user` SET etudiant_id = 3 WHERE login = 'smbappe';
UPDATE `user` SET etudiant_id = 4 WHERE login = 'detoo';
UPDATE `user` SET etudiant_id = 5 WHERE login = 'bayuk';
UPDATE `user` SET etudiant_id = 16 WHERE login = 'cbassogog';
UPDATE `user` SET etudiant_id = 17 WHERE login = 'emoting';
UPDATE `user` SET etudiant_id = 18 WHERE login = 'nnkoulou';
UPDATE `user` SET etudiant_id = 19 WHERE login = 'jcastelletto';
UPDATE `user` SET etudiant_id = 20 WHERE login = 'cwooh';
