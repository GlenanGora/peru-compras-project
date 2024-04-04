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
