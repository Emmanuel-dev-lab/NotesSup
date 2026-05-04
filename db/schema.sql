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
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE `etudiant` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `matricule` VARCHAR(20) NOT NULL UNIQUE,
  `nom` VARCHAR(100) NOT NULL,
  `prenom` VARCHAR(100) NOT NULL,
  `filiere` VARCHAR(80) NOT NULL,
  `annee` INT NOT NULL CHECK (annee BETWEEN 1 AND 5),
  `telephone` VARCHAR(20),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE `matiere` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(15) NOT NULL UNIQUE,
  `intitule` VARCHAR(150) NOT NULL,
  `coefficient` INT NOT NULL CHECK (coefficient BETWEEN 1 AND 6),
  `enseignant` VARCHAR(100),
  `semestre` INT NOT NULL CHECK (semestre IN (1, 2)),
  `filiere` VARCHAR(80) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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

-- Users demo (BCrypt hashed "root123" with salt=10)
-- Hash: $2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe
INSERT INTO `user` (login, password, role, nom, filiere) VALUES
('chef', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'CHEF_DEPT', 'Chef Département', 'Informatique'),
('prof1', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ENSEIGNANT', 'Prof Dupont', 'Informatique'),
('etud1', '$2a$10$7UHsBiwjnzeNKmW7Lpq0ZOCLlDxHEm069aDe.oCGEK.cFlsxEHppe', 'ETUDIANT', 'Etudiant Un', 'Informatique');

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
