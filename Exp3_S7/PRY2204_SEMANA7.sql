/*
CASO 0: LIMPIEZA DE TABLAS
Limpieza de tablas para ejecucion limpia del script, el bloque begin/end ignora los 'DROP TABLE'
si es que la tabla no existe por lo que evita errores al utilizar el script por primera vez
*/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DOMINIO CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE TITULACION CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE PERSONAL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE COMPANIA CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE COMUNA CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE REGION CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE GENERO CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE ESTADO_CIVIL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE TITULO CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE IDIOMA CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Eliminar secuencias si ya existen
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_COMUNA_ID';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_COMPANIA_ID';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

/*
CASO 1: IMPLEMENTACION DEL MODELO
*/

--Paso 1: creacion de tablas
CREATE TABLE REGION (
    id_region      NUMBER(2) GENERATED ALWAYS AS IDENTITY (START WITH 7 INCREMENT BY 2),
    nombre_region  VARCHAR2(25) NOT NULL,
    CONSTRAINT REGION_PK PRIMARY KEY (id_region)
);

-- COMUNA: depende de REGION
CREATE TABLE COMUNA (
    id_comuna      NUMBER(5) NOT NULL,
    comuna_nombre  VARCHAR2(25) NOT NULL,
    cod_region     NUMBER(2) NOT NULL,
    CONSTRAINT COMUNA_PK PRIMARY KEY (id_comuna, cod_region)
);

CREATE TABLE GENERO (
    id_genero          VARCHAR2(3) NOT NULL,
    descripcion_genero VARCHAR2(25) NOT NULL,
    CONSTRAINT GENERO_PK PRIMARY KEY (id_genero)
);

CREATE TABLE ESTADO_CIVIL (
    id_estado_civil        VARCHAR2(2) NOT NULL,
    descripcion_est_civil  VARCHAR2(25) NOT NULL,
    CONSTRAINT ESTADO_CIVIL_PK PRIMARY KEY (id_estado_civil)
);

CREATE TABLE IDIOMA (
    id_idioma      NUMBER(3) GENERATED ALWAYS AS IDENTITY (START WITH 25 INCREMENT BY 3),
    nombre_idioma  VARCHAR2(30) NOT NULL,
    CONSTRAINT IDIOMA_PK PRIMARY KEY (id_idioma)
);

CREATE TABLE TITULO (
    id_titulo           VARCHAR2(3) NOT NULL,
    descripcion_titulo  VARCHAR2(60) NOT NULL,
    CONSTRAINT TITULO_PK PRIMARY KEY (id_titulo)
);

-- COMPANIA: depende de COMUNA
CREATE TABLE COMPANIA (
    id_empresa      NUMBER(2) NOT NULL,
    nombre_empresa  VARCHAR2(25) NOT NULL,
    calle           VARCHAR2(50),
    numeracion      NUMBER(5),
    renta_promedio  NUMBER(10),
    pct_aumento     NUMBER(4,3),
    cod_comuna      NUMBER(5),
    cod_region      NUMBER(2),
    CONSTRAINT COMPANIA_PK PRIMARY KEY (id_empresa),
    CONSTRAINT COMPANIA_UN_NOMBRE UNIQUE (nombre_empresa)
);

-- PERSONAL: depende de varias tablas
CREATE TABLE PERSONAL (
    rut_persona        NUMBER(8) NOT NULL,
    dv_persona         CHAR(1) NOT NULL,
    primer_nombre      VARCHAR2(25) NOT NULL,
    segundo_nombre     VARCHAR2(25),
    primer_apellido    VARCHAR2(25) NOT NULL,
    segundo_apellido   VARCHAR2(25) NOT NULL,
    fecha_contratacion DATE NOT NULL,
    fecha_nacimiento   DATE NOT NULL,
    email              VARCHAR2(100),
    calle              VARCHAR2(50) NOT NULL,
    numeracion         NUMBER(5) NOT NULL,
    sueldo             NUMBER(8) NOT NULL,
    cod_comuna         NUMBER(5) NOT NULL,
    cod_region         NUMBER(2) NOT NULL,
    cod_genero         VARCHAR2(3),
    cod_estado_civil   VARCHAR2(2),
    cod_empresa        NUMBER(2) NOT NULL,
    encargado_rut      NUMBER(8),
    CONSTRAINT PERSONAL_PK PRIMARY KEY (rut_persona)
);

CREATE TABLE TITULACION (
    cod_titulo        VARCHAR2(3) NOT NULL,
    persona_rut       NUMBER(8) NOT NULL,
    fecha_titulacion  DATE,
    CONSTRAINT TITULACION_PK PRIMARY KEY (cod_titulo, persona_rut)
);

CREATE TABLE DOMINIO (
    id_idioma     NUMBER(3) NOT NULL,
    persona_rut   NUMBER(8) NOT NULL,
    nivel         VARCHAR2(25),
    CONSTRAINT DOMINIO_PK PRIMARY KEY (id_idioma, persona_rut)
);

--paso 2: creacion de relaciones
-- COMUNA -> REGION
ALTER TABLE COMUNA 
    ADD CONSTRAINT COMUNA_FK_REGION FOREIGN KEY (cod_region) 
    REFERENCES REGION(id_region);

-- COMPANIA -> COMUNA
ALTER TABLE COMPANIA 
    ADD CONSTRAINT COMPANIA_FK_COMUNA FOREIGN KEY (cod_comuna, cod_region) 
    REFERENCES COMUNA(id_comuna, cod_region);

-- PERSONAL -> COMPANIA
ALTER TABLE PERSONAL 
    ADD CONSTRAINT PERSONAL_FK_COMPANIA FOREIGN KEY (cod_empresa) 
    REFERENCES COMPANIA(id_empresa);

-- PERSONAL -> COMUNA
ALTER TABLE PERSONAL 
    ADD CONSTRAINT PERSONAL_FK_COMUNA FOREIGN KEY (cod_comuna, cod_region) 
    REFERENCES COMUNA(id_comuna, cod_region);

-- PERSONAL -> GENERO
ALTER TABLE PERSONAL 
    ADD CONSTRAINT PERSONAL_FK_GENERO FOREIGN KEY (cod_genero) 
    REFERENCES GENERO(id_genero);

-- PERSONAL -> ESTADO_CIVIL
ALTER TABLE PERSONAL 
    ADD CONSTRAINT PERSONAL_FK_ESTADO_CIVIL FOREIGN KEY (cod_estado_civil) 
    REFERENCES ESTADO_CIVIL(id_estado_civil);

-- PERSONAL -> PERSONAL (autorreferencia)
ALTER TABLE PERSONAL 
    ADD CONSTRAINT PERSONAL_FK_ENCARGADO FOREIGN KEY (encargado_rut) 
    REFERENCES PERSONAL(rut_persona);

-- TITULACION -> TITULO
ALTER TABLE TITULACION 
    ADD CONSTRAINT TITULACION_FK_TITULO FOREIGN KEY (cod_titulo) 
    REFERENCES TITULO(id_titulo);

-- TITULACION -> PERSONAL
ALTER TABLE TITULACION 
    ADD CONSTRAINT TITULACION_FK_PERSONAL FOREIGN KEY (persona_rut) 
    REFERENCES PERSONAL(rut_persona);

-- DOMINIO -> IDIOMA
ALTER TABLE DOMINIO 
    ADD CONSTRAINT DOMINIO_FK_IDIOMA FOREIGN KEY (id_idioma) 
    REFERENCES IDIOMA(id_idioma);

-- DOMINIO -> PERSONAL
ALTER TABLE DOMINIO 
    ADD CONSTRAINT DOMINIO_FK_PERSONAL FOREIGN KEY (persona_rut) 
    REFERENCES PERSONAL(rut_persona);
    
/*
CASO 2: MODIFICACION DEL MODELO
*/
-- 1. Email único
ALTER TABLE PERSONAL ADD CONSTRAINT PERSONAL_UN_EMAIL
    UNIQUE (email);

-- 2. Dígito verificador restringido a 0–9 y 'K'
ALTER TABLE PERSONAL ADD CONSTRAINT PERSONAL_CK_DV
    CHECK (dv_persona IN ('0','1','2','3','4','5','6','7','8','9','K'));

-- 3. Sueldo mínimo de $450.000
ALTER TABLE PERSONAL ADD CONSTRAINT PERSONAL_CK_SUELDO_MINIMO
    CHECK (sueldo >= 450000);
    
/*
CASO 3: POBLAMIENTO DEL MODELO
*/

-- Secuencia para COMUNA: inicia en 1101, incrementa en 6
CREATE SEQUENCE SEQ_COMUNA_ID
    START WITH 1101
    INCREMENT BY 6
    NOCACHE
    NOCYCLE;
    
-- Crear secuencia para COMPAÑÍA 
CREATE SEQUENCE SEQ_COMPANIA_ID
    START WITH 10
    INCREMENT BY 5
    NOCACHE
    NOCYCLE;

-- Poblamiento automático de IDIOMA
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Ingles');
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Chino');
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Aleman');
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Espanol');
INSERT INTO IDIOMA (nombre_idioma) VALUES ('Frances');

-- Poblamiento automático de REGION
INSERT INTO REGION (nombre_region) VALUES ('ARICA Y PARINACOTA');
INSERT INTO REGION (nombre_region) VALUES ('METROPOLITANA');
INSERT INTO REGION (nombre_region) VALUES ('LA ARAUCANIA');

-- Poblamiento de COMUNA usando secuencia
INSERT INTO COMUNA (id_comuna, comuna_nombre, cod_region)
VALUES (SEQ_COMUNA_ID.NEXTVAL, 'Arica', 7);

INSERT INTO COMUNA (id_comuna, comuna_nombre, cod_region)
VALUES (SEQ_COMUNA_ID.NEXTVAL, 'Santiago', 9);

INSERT INTO COMUNA (id_comuna, comuna_nombre, cod_region)
VALUES (SEQ_COMUNA_ID.NEXTVAL, 'Temuco', 11);


-- Poblamiento de COMPAÑÍA 
INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region) 
VALUES (SEQ_COMPANIA_ID.NEXTVAL, 'CCyRojas', 'Amapolas', 506, 1857000, 0.5, 1101, 7);

INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region) 
VALUES (SEQ_COMPANIA_ID.NEXTVAL, 'SenTTV', 'Los Alamos', 3490, 897000, 0.025, 1101, 7);

INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region) 
VALUES (SEQ_COMPANIA_ID.NEXTVAL, 'Praxia LTDA', 'Las Camelias', 11098, 2157000, 0.035, 1107, 9);

INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region) 
VALUES (SEQ_COMPANIA_ID.NEXTVAL, 'TIC spa', 'FLORES S.A.', 4357, 857000, NULL, 1107, 9);

INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region) 
VALUES (SEQ_COMPANIA_ID.NEXTVAL, 'SANTANA LTDA', 'AVDA VIC. MACKENA', 106, 757000, 0.015, 1101, 7);

INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region) 
VALUES (SEQ_COMPANIA_ID.NEXTVAL, 'FLORES Y ASOCIADOS', 'PEDRO LATORRE', 557, 589000, 0.015, 1107, 9);

INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region) 
VALUES (SEQ_COMPANIA_ID.NEXTVAL, 'J.A. HOFFMAN', 'LATINA D.32', 509, 1857000, 0.025, 1113, 11);

INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region) 
VALUES (SEQ_COMPANIA_ID.NEXTVAL, 'CAGLIARI D.', 'ALAMEDA', 206, 1857000, NULL, 1107, 9);

INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region) 
VALUES (SEQ_COMPANIA_ID.NEXTVAL, 'Rojas HNOS LTDA', 'SUCRE', 106, 957000, 0.005, 1113, 11);

INSERT INTO COMPANIA (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region) 
VALUES (SEQ_COMPANIA_ID.NEXTVAL, 'FRIENDS P. S A', 'SUECIA', 506, 857000, 0.015, 1113, 11);

COMMIT;

/*
CASO 4: RECUPERACION DE DATOS
*/

-- informe 1
SELECT
    nombre_empresa AS "Nombre Empresa",
    calle || ' ' || numeracion AS "Dirección",
    renta_promedio AS "Renta Promedio",
    ROUND(renta_promedio * (1 + pct_aumento), 0) AS "Simulación de Renta"
FROM
    COMPANIA
ORDER BY
    renta_promedio DESC,
    nombre_empresa ASC;
    
    
-- informe 2
SELECT 
    c.id_empresa AS "ID Empresa",
    c.nombre_empresa AS "Nombre Empresa", 
    c.renta_promedio AS "Renta Promedio Actual",
    CASE 
        WHEN c.pct_aumento IS NULL THEN NULL
        ELSE ROUND((c.pct_aumento + 0.15) * 100, 1)
    END AS "Porcentaje Aumentado",
    CASE 
        WHEN c.pct_aumento IS NULL THEN NULL
        ELSE ROUND(c.renta_promedio * (1 + c.pct_aumento + 0.15), 0)
    END AS "Renta Promedio Incrementada"
FROM COMPANIA c
ORDER BY 
    c.renta_promedio ASC,
    c.nombre_empresa DESC;