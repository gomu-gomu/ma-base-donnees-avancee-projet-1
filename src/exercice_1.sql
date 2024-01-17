-- Projet 1
-- 1 - En utilisant « Oracle SQL data Modeler », introduire le schéma de la base de donnée en dessous.
-- 2 - Générer le code qui correspond à la création de ce shéma.

-- 3 - Créer des tablespaces (Nombre de votre choix) pour gérer les tables. Créer aussi un tablespace Undo.
CREATE TABLESPACE TS_PERSONNE
DATAFILE 'ts_personne.dbf' SIZE 100M
AUTOEXTEND ON 
NEXT 10M MAXSIZE UNLIMITED;

CREATE TABLESPACE TS_PRODUIT
DATAFILE 'ts_produit.dbf' SIZE 100M
AUTOEXTEND ON 
NEXT 10M MAXSIZE UNLIMITED;

CREATE TABLESPACE TS_COMMANDE
DATAFILE 'ts_commande.dbf' SIZE 100M
AUTOEXTEND ON 
NEXT 10M MAXSIZE UNLIMITED;

CREATE UNDO TABLESPACE TS_UNDO
DATAFILE 'ts_undo.dbf' SIZE 300M
AUTOEXTEND ON
NEXT 10M MAXSIZE UNLIMITED;

-- 4 - Créer les tables qui correspondent à ce schéma en les assignant aux tablespaces correspondants.
CREATE TABLE CLIENTS (
    CODE_CLIENT         CHAR(5)                                         NOT NULL,
    SOCIETE             NVARCHAR2(40)                                   NOT NULL,
    ADRESSE             NVARCHAR2(60)                                   NOT NULL,
    VILLE               VARCHAR2(30)                                    NOT NULL,
    CODE_POSTAL         VARCHAR2(10)                                    NOT NULL,
    PAYS                VARCHAR2(15)                                    NOT NULL,
    TELEPHONE           VARCHAR2(24)                                    NOT NULL,
    FAX                 VARCHAR2(24)                                    NULL,

    PRIMARY KEY (CODE_CLIENT)
) TABLESPACE TS_PERSONNE;

CREATE TABLE EMPLOYES (
    NO_EMPLOYE          NUMBER(6)                                       NOT NULL,
    REND_COMPTE         NUMBER(6)                                       NULL,
    NOM                 NVARCHAR2(40)                                   NOT NULL,
    PRENOM              NVARCHAR2(30)                                   NOT NULL,
    FONCTION            VARCHAR2(30)                                    NOT NULL,
    TITRE               VARCHAR2(5)                                     NOT NULL,
    DATE_NAISSANCE      DATE                                            NOT NULL,
    DATE_EMBAUCHE       DATE                                            NOT NULL,
    SALAIRE             NUMBER(8, 2)                                    NOT NULL,
    COMMISSION          NUMBER(8, 2)                                    NULL,
    PAYS                VARCHAR2(20)                                    NULL,
    REGION              VARCHAR2(50)                                    NULL,
  
    PRIMARY KEY (NO_EMPLOYE),
    FOREIGN KEY (REND_COMPTE) REFERENCES EMPLOYES(NO_EMPLOYE)
) TABLESPACE TS_PERSONNE;

CREATE TABLE COMMANDES (
    NO_COMMANDE         NUMBER(6)                                     NOT NULL,
    CODE_CLIENT         CHAR(5)                                       NOT NULL,
    NO_EMPLOYE          NUMBER(6)                                     NOT NULL,
    DATE_COMMANDE       DATE                                          NOT NULL,
    DATE_ENVOI          DATE                                          NULL,
    PORT                NUMBER(8, 2)                                  NULL,
    LIVREE              NUMBER(1)                                     NOT NULL,
    ACQUITEE            NUMBER(1)                                     NOT NULL,
    ANNULEE             NUMBER(1)                                     NOT NULL,
    ANNEE               AS (EXTRACT(YEAR FROM DATE_COMMANDE))         NOT NULL,
    TRIMESTRE           AS (TO_NUMBER(TO_CHAR(DATE_COMMANDE, 'Q')))   NOT NULL,
    MOIS                AS (EXTRACT(MONTH FROM DATE_COMMANDE))        NOT NULL,

    PRIMARY KEY (NO_COMMANDE),
    FOREIGN KEY (CODE_CLIENT) REFERENCES CLIENTS(CODE_CLIENT),
    FOREIGN KEY (NO_EMPLOYE) REFERENCES EMPLOYES(NO_EMPLOYE)
) TABLESPACE TS_COMMANDE;

CREATE TABLE FOURNISSEURS (
    NO_FOURNISSEUR      NUMBER(6)                                     NOT NULL,
    SOCIETE             NVARCHAR2(40)                                 NOT NULL,
    ADRESSE             NVARCHAR2(60)                                 NOT NULL,
    VILLE               VARCHAR2(30)                                  NOT NULL,
    CODE_POSTAL         VARCHAR2(10)                                  NOT NULL,
    PAYS                VARCHAR2(15)                                  NOT NULL,
    TELEPHONE           VARCHAR2(24)                                  NOT NULL,
    FAX                 VARCHAR2(24)                                  NULL,

    PRIMARY KEY (NO_FOURNISSEUR)
) TABLESPACE TS_PERSONNE;

CREATE TABLE CATEGORIES (
    CODE_CATEGORIE      NUMBER(6)                                     NOT NULL,
    NOM_CATEGORIE       VARCHAR2(25)                                  NOT NULL,
    DESCRIPTION         VARCHAR2(100)                                 NOT NULL,

    PRIMARY KEY (CODE_CATEGORIE)
) TABLESPACE TS_PRODUIT;

CREATE TABLE PRODUITS (
    REF_PRODUIT         NUMBER(6)                                     NOT NULL,
    NOM_PRODUIT         NVARCHAR2(50)                                 NOT NULL,
    NO_FOURNISSEUR      NUMBER(6)                                     NOT NULL,
    CODE_CATEGORIE      NUMBER(6)                                     NOT NULL,
    QUANTITE            VARCHAR2(30)                                  NULL,
    PRIX_UNITAIRE       NUMBER(8, 2)                                  NOT NULL,
    UNITES_STOCK        NUMBER(5)                                     NULL,
    UNITES_COMMANDEES   NUMBER(5)                                     NULL,
    INDISPONIBLE        NUMBER(1)                                     NOT NULL,

    PRIMARY KEY (REF_PRODUIT),
    FOREIGN KEY (NO_FOURNISSEUR) REFERENCES FOURNISSEURS(NO_FOURNISSEUR),
    FOREIGN KEY (CODE_CATEGORIE) REFERENCES CATEGORIES(CODE_CATEGORIE)
) TABLESPACE TS_PRODUIT;

CREATE TABLE DETAILS_COMMANDES (
    NO_COMMANDE         NUMBER(6)                                     NOT NULL,
    REF_PRODUIT         NUMBER(6)                                     NOT NULL,
    PRIX_UNITAIRE       NUMBER(8, 2)                                  NOT NULL,
    QUANTITE            NUMBER(5)                                     NOT NULL,
    REMISE              NUMBER(8, 2)                                  NOT NULL,
    RETOURNE            NUMBER(1)                                     NOT NULL,
    ECHANGE             NUMBER(1)                                     NOT NULL,

    PRIMARY KEY (NO_COMMANDE, REF_PRODUIT),
    FOREIGN KEY (NO_COMMANDE) REFERENCES COMMANDES(NO_COMMANDE),
    FOREIGN KEY (REF_PRODUIT) REFERENCES PRODUITS(REF_PRODUIT)
) TABLESPACE TS_COMMANDE;

ALTER SYSTEM SET UNDO_TABLESPACE = TS_UNDO;

-- 5 - Créer 3 utilisateurs avec trois rôles distincts.
CREATE ROLE ROLE_USER; -- Utilisateur
CREATE ROLE ROLE_MODR; -- Modérateur
CREATE ROLE ROLE_ADMN; -- Admin

GRANT SELECT ON CLIENTS TO ROLE_USER;
GRANT SELECT ON FOURNISSEURS TO ROLE_USER;
GRANT SELECT ON CATEGORIES TO ROLE_USER;

GRANT INSERT, UPDATE ON COMMANDES TO ROLE_MODR;
GRANT INSERT, UPDATE ON PRODUITS TO ROLE_MODR;

GRANT ALL PRIVILEGES TO ROLE_ADMN;

-- 6 - Créer différents profils et assigner les aux différents utilisateurs.
CREATE PROFILE PROFILE_LIMITEE LIMIT PASSWORD_LIFE_TIME 30 FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1;
CREATE PROFILE PROFILE_INTER LIMIT SESSIONS_PER_USER UNLIMITED CPU_PER_SESSION UNLIMITED CONNECT_TIME 120;
CREATE PROFILE PROFILE_ILLIMITEE LIMIT SESSIONS_PER_USER UNLIMITED CPU_PER_SESSION UNLIMITED;

-- 7 - Remplir la base de données avec 4 enregistrements.
INSERT INTO CLIENTS (CODE_CLIENT, SOCIETE, ADRESSE, VILLE, CODE_POSTAL, PAYS, TELEPHONE, FAX) VALUES ('C0001', 'Société A', '123 rue de la Paix', 'Paris', '75001', 'France', '0123456789', '9876543210');
INSERT INTO FOURNISSEURS (NO_FOURNISSEUR, SOCIETE, ADRESSE, VILLE, CODE_POSTAL, PAYS, TELEPHONE, FAX) VALUES (1, 'Fournisseur X', '789 boulevard Liberté', 'Marseille', '13000', 'France', '0345678912', '0615678912');
INSERT INTO CATEGORIES (CODE_CATEGORIE, NOM_CATEGORIE, DESCRIPTION) VALUES (1, 'Électronique', 'Appareils et dispositifs électroniques.');
INSERT INTO EMPLOYES (NO_EMPLOYE, NOM, PRENOM, FONCTION, TITRE, DATE_NAISSANCE, DATE_EMBAUCHE, SALAIRE, PAYS, REGION) VALUES (1, 'Dupont', 'Jean', 'Vendeur', 'M.', TO_DATE('1980-02-20','YYYY-MM-DD'), TO_DATE('2010-06-01','YYYY-MM-DD'), 2500, 'France', 'Île-de-France');

-- 8 - Vérifier les mémoires SGA et PGA après l’insertion de ces enregistrements
SELECT * FROM V$SGA;
SELECT * FROM V$PGASTAT;

-- 9 - Calculer le rapport qui correspond au Database Buffer cache.
SELECT (1 - (PHY.value - LOB.value - DIR.value) / SES.value) * 100 AS BUFFER_CACHE_RAPPORT
FROM v$sysstat SES, v$sysstat LOB, v$sysstat DIR, v$sysstat PHY
WHERE  SES.name = 'session logical reads'
AND    DIR.name = 'physical reads direct'
AND    LOB.name = 'physical reads direct (lob)'
AND    PHY.name = 'physical reads';

-- 10 - Vérifier s’il faut augmenter la taille du Library cache.
Select SUM(RELOADS) / (SUM(RELOADS) + Sum(PINS)) * 100 "Rapport" FROM V$librarycache;
-- Reloads: Nombre de demandes infructueuses
-- Pins : Nombre d’exécutions sans défaut de cache
-- il faut augmenter la taille si le résultant est >= 1%

-- Affichier les tablespaces.
SELECT TABLESPACE_NAME FROM DBA_TABLESPACES;

-- Afficher l'emplacement des fichiers de stockage.
SELECT FILE_NAME, TABLESPACE_NAME FROM DBA_DATA_FILES;

-- Augmenter la taille des segments.
ALTER TABLE EMPLOYES ALLOCATE EXTENT (SIZE 10M);
ALTER TABLE CLIENTS ALLOCATE EXTENT (SIZE 10M);
ALTER TABLE EMPLOYES ALLOCATE EXTENT (SIZE 10M);
ALTER TABLE COMMANDES ALLOCATE EXTENT (SIZE 10M);
ALTER TABLE FOURNISSEURS ALLOCATE EXTENT (SIZE 10M);
ALTER TABLE CATEGORIES ALLOCATE EXTENT (SIZE 10M);
ALTER TABLE PRODUITS ALLOCATE EXTENT (SIZE 10M);
ALTER TABLE DETAILS_COMMANDES ALLOCATE EXTENT (SIZE 10M);

-- Mettre un tablespace en mode offline.
ALTER TABLESPACE TS_COMMANDE OFFLINE;

-- Afficher les utilisateurs de ce shema.
SELECT USERNAME FROM DBA_USERS WHERE DEFAULT_TABLESPACE = 'TS_PERSONNE';

-- Affichier les roles associes a chaque utilisateur.
SELECT GRANTEE, GRANTED_ROLE FROM DBA_ROLE_PRIVS;

-- Affichier les profils.
SELECT profile FROM DBA_PROFILES;

-- Modifier les rôles.
DROP ROLE ROLE_ADMN;
CREATE ROLE ROLE_ADMN;
GRANT SELECT ON CLIENTS TO ROLE_ADMN;

-- Changer les privileges.
REVOKE SELECT ON CLIENTS FROM ROLE_ADMN;
GRANT INSERT ON CLIENTS TO ROLE_ADMN;