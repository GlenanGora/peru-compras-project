CREATE SCHEMA pc;
CREATE SEQUENCE "pc".ID_OC_SEQ;
CREATE TABLE "pc".stg_ocompras
(
ID_OC INTEGER NOT NULL DEFAULT NEXTVAL('ID_OC_SEQ')
, FECHA_PROCESO TIMESTAMP
, RUC_PROVEEDOR BIGINT
, PROVEEDOR VARCHAR(200)
, RUC_ENTIDAD BIGINT
, ENTIDAD VARCHAR(200)
, TIPO_PROCEDIMIENTO VARCHAR(100)
, ORDEN_ELECTRONICA VARCHAR(22)
, ORDEN_ELECTRONICA_GENERADA VARCHAR(110)
, ESTADO_ORDEN_ELECTRONICA VARCHAR(8)
, DOCUMENTO_ESTADO_OCAM VARCHAR(104)
, FECHA_FORMALIZACION TIMESTAMP
, FECHA_ULTIMO_ESTADO TIMESTAMP
, SUB_TOTAL NUMERIC(11, 2)
, IGV NUMERIC(10, 2)
, TOTAL NUMERIC(11, 2)
, ORDEN_DIGITALIZADA VARCHAR(200)
, DESCRIPCION_ESTADO VARCHAR(200)
, ACUERDO_MARCO VARCHAR(100)
, FECHA_CARGA DATE DEFAULT CURRENT_DATE;
)
;
ALTER SEQUENCE "pc".ID_OC_SEQ owned by "pc".stg_ocompras.ID_OC;
-------------------------------------------------------------------------------------
CREATE SEQUENCE "pc".id_os_seq;
CREATE TABLE IF NOT EXISTS pc.stg_oservicio
(
    id_os integer NOT NULL DEFAULT nextval('pc.id_os_seq'::regclass),
    fecha_proceso date,
    ruc_proveedor bigint,
    proveedor character varying(200) COLLATE pg_catalog."default",
    ruc_entidad bigint,
    entidad character varying(200) COLLATE pg_catalog."default",
    orden_electronica character varying(100) COLLATE pg_catalog."default",
    orden_electronica_generada character varying(200) COLLATE pg_catalog."default",
    estado_orden_electronica character varying(200) COLLATE pg_catalog."default",
    fecha_ultimo_estado timestamp without time zone,
    total numeric(11,2),
    orden_publicada character varying(200) COLLATE pg_catalog."default",
    acuerdo_marco character varying(100) COLLATE pg_catalog."default",
    fecha_carga date DEFAULT CURRENT_DATE,
    tipo integer DEFAULT 2
)
ALTER SEQUENCE "pc".id_os_seq owned by "pc".stg_oservicio.id_os;
-------------------------------------------------------------------------------------

CREATE SEQUENCE "pc".seq_id_prda;
CREATE TABLE "pc".stg_padronda
(
id_prda integer not null default nextval('seq_id_prda')
, RUC BIGINT
, Estado VARCHAR(50)
, Condicion VARCHAR(50)
, Tipo VARCHAR(100)
, ae_rp3 VARCHAR(500)
, ae_rs3 VARCHAR(500)
, ae_rp4  VARCHAR(500)
, NroTrab VARCHAR(13)
, TipoFacturacion VARCHAR(100)
, TipoContabilidad VARCHAR(100)
, ComercioExterior VARCHAR(200)
, UBIGEO VARCHAR(15)
, Departamento VARCHAR(50)
, Provincia VARCHAR(100)
, Distrito VARCHAR(100)
, PERIODO_PUBLICACION BIGINT
, fecha_carga date default current_date
)
;

ALTER SEQUENCE "pc".seq_id_prda owned by "pc".stg_padronda.id_prda;

create index indx_rucproveed on stg_ocompras(ruc_proveedor);
create index indx_rucentidad on stg_ocompras(ruc_entidad);
create index indx_rucempresa on stg_padronda(ruc);

CREATE SEQUENCE "pc".seq_id_orden;

CREATE TABLE "pc".FACT_OCOMPRAS
(
id_orden integer NOT NULL DEFAULT nextval('seq_id_orden'::regclass),
id_ocos integer NOT NULL,
fecha_proceso timestamp without time zone,
ruc_proveedor bigint,
proveedor character varying(200),
ruc_entidad bigint,
entidad character varying(200),
tipo_procedimiento character varying(100),
orden_electronica character varying(200),
orden_electronica_generada character varying(110),
estado_orden_electronica character varying(200),
documento_estado_ocam character varying(104),
fecha_formalizacion timestamp without time zone,
fecha_ultimo_estado timestamp without time zone,
sub_total numeric(11,2),
igv numeric(10,2),
total numeric(11,2),
orden_digitalizada character varying(200),
descripcion_estado character varying(200),
acuerdo_marco character varying(100),
fecha_carga date DEFAULT CURRENT_DATE,
tipo_orden integer 
);
	
ALTER SEQUENCE "pc".seq_id_orden owned by "pc".fact_ocompras.id_orden;

