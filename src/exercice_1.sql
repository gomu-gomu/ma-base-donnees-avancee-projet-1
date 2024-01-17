-- Projet 1
-- 1 - En utilisant « Oracle SQL data Modeler », introduire le schéma de la base de donnée en dessous.
-- 2 - Générer le code qui correspond à la création de ce shéma.

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
);

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
);

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
);

CREATE TABLE FOURNISSEURS (
    NO_FOURNISSEUR      NUMBER(6)                                     NOT NULL,
    SOCIETE             NVARCHAR2(40)                                 NOT NULL,
    ADRESSE             NVARCHAR2(60)                                 NOT NULL,
    VILLE               VARCHAR2(30)                                  NOT NULL,
    CODE_POSTAL         VARCHAR2(10)                                  NOT NULL,
    PAYS                VARCHAR2(15)                                  NOT NULL,
    TELEPHONE           VARCHAR2(24)                                  NOT NULL,
    FAX                 VARCHAR2(24),                                 NULL,

    PRIMARY KEY (NO_FOURNISSEUR)
);

CREATE TABLE CATEGORIES (
    CODE_CATEGORIE      NUMBER(6)                                     NOT NULL,
    NOM_CATEGORIE       VARCHAR2(25)                                  NOT NULL,
    DESCRIPTION         VARCHAR2(100)                                 NOT NULL,

    PRIMARY KEY (CODE_CATEGORIE)
);

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
);

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
);
