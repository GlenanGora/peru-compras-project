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

/************************************************************************************
ATENCION:
1) Ejecutar la carga de las ordenes de compra, ordenes de servicio, padron Sunat desde
   pentaho ubicado en la carpeta /pentaho/load_oc_os.ktr y /pentaho/load_padronsunatDA.ktr
2) Si no se desea usar pentaho se puede unir los archivos mediante la creación de un 
   ejecutable en bat o sh y luego copiar con el comando COPY hacia las tablas.
**************************************************************************************/

/**************************************************************************************
Cargamos en una unica tabla los datos de ordenes de compra y ordenes de servicio
para el analisis solo se realizara con las ordenes de compra.
***************************************************************************************/

insert into fact_ocompras(id_ocos,fecha_proceso,ruc_proveedor,ruc_entidad,tipo_procedimiento,orden_electronica,orden_electronica_generada,estado_orden_electronica,documento_estado_ocam,fecha_formalizacion,fecha_ultimo_estado,sub_total,igv,total,orden_digitalizada, descripcion_estado,acuerdo_marco,tipo_orden)
SELECT
id_oc id_ocos,
fecha_proceso,
ruc_proveedor,
ruc_entidad,
tipo_procedimiento,
orden_electronica,
orden_electronica_generada,
estado_orden_electronica,
documento_estado_ocam,
fecha_formalizacion,
fecha_ultimo_estado,
sub_total,
igv,
total,
orden_digitalizada, 
descripcion_estado,
acuerdo_marco,
tipo tipo_orden
FROM stg_ocompras
UNION
SELECT
id_os id_ocos,
fecha_proceso,
ruc_proveedor,
ruc_entidad,
'sin datos' tipo_procedimiento,
orden_electronica,
orden_electronica_generada,
estado_orden_electronica,
'sin datos' documento_estado_ocam,
NULL fecha_formalizacion,
fecha_ultimo_estado,
0 sub_total,
0 igv,
total,
orden_publicada orden_digitalizada,
'sin datos' descripcion_estado,
acuerdo_marco,
tipo tipo_orden  
FROM stg_oservicio;

CREATE TABLE IF NOT EXISTS pc.det_ocompras
(
    id_registro bigint,
    cod_articulo character varying(50) COLLATE pg_catalog."default",
    cantidad numeric(11,2),
    preciounit numeric(11,2),
    igv numeric(11,2),
    importe numeric(11,2),
    fecha_carga date DEFAULT date(now())
)

/**********************************************************************************************************
Para modelar adecuadamente entre la tabla que contiene las ordenes de compra y servicio debemos crear
las tablas entidad y proveedor, la primera contiene todos los nombres de las entidades que han realizado la
adquisición, es por ello que se necesita el padron de sunat, lo mismo aplica para crear la tabla proveedores
************************************************************************************************************/

-- Insertamos en la tabla entidad solo las entidades que han realizado una compra
create table d_entidad as
SELECT oc.ruc_entidad, max(oc.entidad) razon_social, pa.estado,pa.condicion,pa.tipo tipo_empresa, pa.ae_rp3,pa.ae_rp4,pa.ubigeo,pa.departamento,pa.provincia,pa.distrito
FROM stg_ocompras oc
LEFT JOIN stg_padronda pa on oc.ruc_entidad=pa.ruc
where pa.ruc is not null
GROUP BY oc.ruc_entidad,pa.estado,pa.condicion,pa.tipo,pa.ae_rp3,pa.ae_rp4,pa.ubigeo,pa.departamento,pa.provincia,pa.distrito

-- Insertamos en la tabla entidad solo las entidades que han solicitado un servicio
insert into d_entidad
SELECT oc.ruc_entidad, max(oc.entidad) razon_social, pa.estado,pa.condicion,pa.tipo tipo_empresa,pa.ae_rp3,pa.ae_rp4,pa.ubigeo,pa.departamento,pa.provincia,pa.distrito
FROM stg_oservicio oc
LEFT JOIN stg_padronda pa on oc.ruc_entidad=pa.ruc
where pa.ruc is not null and oc.ruc_entidad not in (select ruc_entidad from d_entidad)
GROUP BY oc.ruc_entidad,pa.estado,pa.condicion,pa.tipo,pa.ae_rp3,pa.ae_rp4,pa.ubigeo,pa.departamento,pa.provincia,pa.distrito

-- Insertamos en la tabla proveedor solo las empresas que han realizado vendido al estado
create table d_proveedor as
SELECT oc.ruc_proveedor, max(oc.proveedor) razon_social, pa.estado,pa.condicion,pa.tipo tipo_empresa, pa.ae_rp3,pa.ae_rp4,pa.ubigeo,pa.departamento,pa.provincia,pa.distrito
FROM stg_ocompras oc
LEFT JOIN stg_padronda pa on oc.ruc_proveedor=pa.ruc
where pa.ruc is not null
GROUP BY oc.ruc_proveedor,pa.estado,pa.condicion,pa.tipo,pa.ae_rp3,pa.ae_rp4,pa.ubigeo,pa.departamento,pa.provincia,pa.distrito

-- INSERTAMOS SOLO LOS QUE NO SE ENCUENTRAN EN LA TABLA D_PROVEEDOR
insert into d_proveedor
SELECT oc.ruc_entidad, max(oc.entidad) razon_social, pa.estado,pa.condicion,pa.tipo tipo_empresa,pa.ae_rp3,pa.ae_rp4,pa.ubigeo,pa.departamento,pa.provincia,pa.distrito
FROM stg_oservicio oc
LEFT JOIN stg_padronda pa on oc.ruc_entidad=pa.ruc
where pa.ruc is not null and oc.ruc_entidad not in (select ruc_entidad from d_entidad)
GROUP BY oc.ruc_entidad,pa.estado,pa.condicion,pa.tipo,pa.ae_rp3,pa.ae_rp4,pa.ubigeo,pa.departamento,pa.provincia,pa.distrito
--------------------------------------------------------------------------------------------------------------------------------
/******************************************************************************************
Antes de ejecutar el archivo 2.- tabla_detalles.sql ir a /carga y seguir los pasos del archivo
gCollab.txt descargar los archivos pdf y scrapear los datos para almacenarlos en la base de datos
y obtener los detalles de las compras.
*******************************************************************************************/
