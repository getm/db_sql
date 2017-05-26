################################################################################
# Create users and schema with proper permisions
################################################################################
getm_admin
getm_ro # read only access

CREATE SCHEMA getm_admin
  AUTHORIZATION getm_admin;
  
GRANT ALL ON SCHEMA getm_admin TO getm_admin;
GRANT USAGE ON SCHEMA getm_admin TO getm_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA getm_admin
  GRANT SELECT ON TABLES
  TO getm_ro;
  
################################################################################
# Create tm_prime table
################################################################################
CREATE TABLE getm_admin.tm_prime
(
  objectid serial NOT NULL,
  benumber character varying(10),
  osuffix character varying(5),
  tgt_coor character varying(16),
  tgt_name character varying(254),
  catcode character varying(5),
  country character varying(2),
  label character varying(10),
  feat_name character varying(254),
  out_ty character varying(50),
  notional character varying(3),
  chng_req character varying(50),
  ce_l numeric(38,3),
  ce_w numeric(38,3),
  ce_h numeric(38,3),
  c_pvchar character varying(20),
  conf_lvl character varying(24),
  icod timestamp,
  d_state smallint,
  class character varying(15),
  release character varying(1),
  control character varying(32),
  drv_from character varying(48),
  c_reason character varying(20),
  decl_on character varying(14),
  source character varying(128),
  c_method character varying(64),
  doi timestamp,
  c_date timestamp,
  circ_er numeric(38,3),
  lin_er numeric(38,3),
  producer smallint,
  shape geometry NOT NULL,
  analyst character varying(128),
  qc character varying(128),
  class_by character varying(128),
  tot character varying(5),
  CONSTRAINT enforce_srid_shape CHECK (st_srid(shape) = 4326),
  CONSTRAINT tm_prime_pkey PRIMARY KEY (objectid)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE getm_admin.tm_prime
  OWNER TO getm_admin;
GRANT ALL ON TABLE getm_admin.tm_prime TO getm_admin;
GRANT SELECT ON TABLE getm_admin.tm_prime TO getm_ro;

CREATE INDEX idx_tm_prime
  ON getm_admin.tm_prime USING gist(shape);

################################################################################
# Create tm_prod table (producer organization)
################################################################################
CREATE TABLE getm_admin.tm_prod
(
  code integer NOT NULL,
  producer character varying(254),
  CONSTRAINT tm_prod_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE getm_admin.tm_prod
  OWNER TO getm_admin;
GRANT ALL ON TABLE getm_admin.tm_prod TO getm_admin;
GRANT SELECT ON TABLE getm_admin.tm_prod TO getm_ro;

################################################################################
# Create tm_release table (releasability)
################################################################################
CREATE TABLE getm_admin.tm_release
(
  code character varying(2),
  release character varying(254),
  CONSTRAINT tm_release_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE getm_admin.tm_release
  OWNER TO getm_admin;
GRANT ALL ON TABLE getm_admin.tm_release TO getm_admin;
GRANT SELECT ON TABLE getm_admin.tm_release TO getm_ro;

################################################################################
# Create tm_prime_history table
################################################################################
CREATE TABLE getm_admin.tm_prime_history
(
  hid serial NOT NULL,
  created timestamp NOT NULL,
  deleted timestamp,
  objectid integer,
  benumber character varying(10),
  osuffix character varying(5),
  tgt_coor character varying(16),
  tgt_name character varying(254),
  catcode character varying(5),
  country character varying(2),
  label character varying(10),
  feat_name character varying(254),
  out_ty character varying(50),
  notional character varying(3),
  chng_req character varying(50),
  ce_l numeric(38,3),
  ce_w numeric(38,3),
  ce_h numeric(38,3),
  c_pvchar character varying(20),
  conf_lvl character varying(24),
  icod timestamp,
  d_state smallint,
  class character varying(15),
  release character varying(1),
  control character varying(32),
  drv_from character varying(48),
  c_reason character varying(20),
  decl_on character varying(14),
  source character varying(128),
  c_method character varying(64),
  doi timestamp,
  c_date timestamp,
  circ_er numeric(38,3),
  lin_er numeric(38,3),
  producer smallint,
  shape geometry NOT NULL,
  analyst character varying(128),
  qc character varying(128),
  class_by character varying(128),
  tot character varying(5),
  CONSTRAINT enforce_srid_shape CHECK (st_srid(shape) = 4326),
  CONSTRAINT tm_prime_pkey_history PRIMARY KEY (hid)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE getm_admin.tm_prime_history
  OWNER TO getm_admin;
GRANT ALL ON TABLE getm_admin.tm_prime_history TO getm_admin;
GRANT SELECT ON TABLE getm_admin.tm_prime_history TO getm_ro;

CREATE INDEX idx_tm_prime_history
  ON getm_admin.tm_prime_history USING gist(shape);

################################################################################
# Create history functions 
################################################################################

CREATE OR REPLACE FUNCTION getm_admin.tm_prime_delete()
  RETURNS trigger AS
$BODY$
  BEGIN
    UPDATE getm_admin.tm_history
      SET deleted = current_timestamp
      WHERE deleted IS NULL and objectid = OLD.objectid;
    RETURN NULL;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION getm_admin.tm_prime_delete()
  OWNER TO getm_admin;
  
CREATE OR REPLACE FUNCTION getm_admin.tm_prime_insert()
  RETURNS trigger AS
$BODY$
  BEGIN
    INSERT INTO getm_admin.tm_prime_history
      (created,objectid,benumber,osuffix,icod,label,feat_name,out_ty,chng_req,notional,
       conf_lvl,ce_l,ce_w,ce_h,c_pvchar,analyst,qc,class,release,control,class_by,drv_from,
       c_reason,decl_on,source,c_method,c_date,circ_er,lin_er,producer,tgt_coor,tgt_name,
       catcode,country,doi,tot,d_state,shape)
    VALUES
      (now(), NEW.objectid, NEW.benumber, NEW.osuffix, NEW.icod, NEW.label, NEW.feat_name, 
       NEW.out_ty, NEW.chng_req, NEW.notional, NEW.conf_lvl, NEW.ce_l, NEW.ce_w, NEW.ce_h, 
       NEW.c_pvchar, NEW.analyst, NEW.qc, NEW.class, NEW.release, NEW.control, NEW.class_by, 
       NEW.drv_from, NEW.c_reason, NEW.decl_on, NEW.source, NEW.c_method, NEW.c_date, NEW.circ_er, 
       NEW.lin_er, NEW.producer, NEW.tgt_coor, NEW.tgt_name, NEW.catcode, NEW.country, NEW.doi, 
       NEW.tot, NEW.d_state, NEW.shape);
    RETURN NEW;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION getm_admin.tm_prime_insert()
  OWNER TO getm_admin;
  
CREATE OR REPLACE FUNCTION getm_admin.tm_prime_update()
  RETURNS trigger AS
$BODY$
  BEGIN
    UPDATE getm_admin.tm_history
      SET deleted = current_timestamp
      WHERE deleted IS NULL and objectid = OLD.objectid;
    INSERT INTO getm_admin.tm_prime_history
      (created,objectid,benumber,osuffix,icod,label,feat_name,out_ty,chng_req,notional,
       conf_lvl,ce_l,ce_w,ce_h,c_pvchar,analyst,qc,class,release,control,class_by,drv_from,
       c_reason,decl_on,source,c_method,c_date,circ_er,lin_er,producer,tgt_coor,tgt_name,
       catcode,country,doi,tot,d_state,shape)
    VALUES
      (now(), NEW.objectid, NEW.benumber, NEW.osuffix, NEW.icod, NEW.label, NEW.feat_name, 
       NEW.out_ty, NEW.chng_req, NEW.notional, NEW.conf_lvl, NEW.ce_l, NEW.ce_w, NEW.ce_h, 
       NEW.c_pvchar, NEW.analyst, NEW.qc, NEW.class, NEW.release, NEW.control, NEW.class_by, 
       NEW.drv_from, NEW.c_reason, NEW.decl_on, NEW.source, NEW.c_method, NEW.c_date, NEW.circ_er, 
       NEW.lin_er, NEW.producer, NEW.tgt_coor, NEW.tgt_name, NEW.catcode, NEW.country, NEW.doi, 
       NEW.tot, NEW.d_state, NEW.shape);
    RETURN NEW;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION getm_admin.tm_prime_update()
  OWNER TO getm_admin;
  
################################################################################
# Create history triggers 
################################################################################

CREATE TRIGGER tm_prime_delete_trigger
  AFTER DELETE
  ON getm_admin.tm_prime
  FOR EACH ROW
  EXECUTE PROCEDURE getm_admin.tm_prime_delete();
  
CREATE TRIGGER tm_prime_insert_trigger
  AFTER INSERT
  ON getm_admin.tm_prime
  FOR EACH ROW
  EXECUTE PROCEDURE getm_admin.tm_prime_insert();
  
CREATE TRIGGER tm_prime_update_trigger
  AFTER UPDATE
  ON getm_admin.tm_prime
  FOR EACH ROW
  EXECUTE PROCEDURE getm_admin.tm_prime_update();
  
################################################################################
# Create SQL views
################################################################################
CREATE OR REPLACE VIEW getm_admin.tm_pub AS
  SELECT tm_prime.shape::geometry(Geometry,4326) AS geom, tm_prime.benumber, 
      tm_prime.objectid, tm_prime.osuffix, tm_prime.icod, tm_prime.label, 
      tm_prime.feat_name, tm_prime.out_ty, tm_prime.chng_req, tm_prime.notional, 
      tm_prime.conf_lvl, tm_prime.ce_l, tm_prime.ce_w, tm_prime.ce_h, tm_prime.c_pvchar, 
      tm_prime.analyst, tm_prime.qc, tm_prime.class, tm_prime.release, tm_prime.control, 
      tm_prime.class_by, tm_prime.drv_from, tm_prime.c_reason, tm_prime.decl_on,
      tm_prime.source, tm_prime.c_method, tm_prime.c_date, tm_prime.circ_er, 
      tm_prime.lin_er, tm_prime.producer, tm_prime.tgt_coor, tm_prime.tgt_name,
      tm_prime.catcode, tm_prime.country, tm_prime.doi, tm_prime.tot, tm_prime.d_state
    FROM getm_admin.tm_prime, getm_admin.tm_release, getm_admin.tm_prod
  WHERE tm_prime.release::text = tm_release.code AND tm_prime.producer = tm_prod.code;
ALTER TABLE getm_admin.tm_pub
  OWNER TO getm_admin;
GRANT ALL ON TABLE getm_admin.tm_pub TO getm_admin;
GRANT SELECT ON TABLE getm_admin.tm_pub TO getm_ro;

CREATE OR REPLACE VIEW getm_admin.tm_pub_collateral AS
  SELECT *
    FROM getm_admin.tm_pub
  WHERE tm_pub.out_ty::text ~~ '%Collateral%'::text;
ALTER TABLE getm_admin.tm_pub_collateral
  OWNER TO getm_admin;
GRANT ALL ON TABLE getm_admin.tm_pub_collateral TO getm_admin;
GRANT SELECT ON TABLE getm_admin.tm_pub_collateral TO getm_ro;
  
CREATE OR REPLACE VIEW getm_admin.tm_pub_critical AS
  SELECT *
    FROM getm_admin.tm_pub
  WHERE tm_pub.out_ty::text ~~ '%Critical%'::text;
ALTER TABLE getm_admin.tm_pub_critical
  OWNER TO getm_admin;
GRANT ALL ON TABLE getm_admin.tm_pub_critical TO getm_admin;
GRANT SELECT ON TABLE getm_admin.tm_pub_critical TO getm_ro;
  
CREATE OR REPLACE VIEW getm_admin.tm_pub_facility AS
  SELECT *
    FROM getm_admin.tm_pub
  WHERE tm_pub.out_ty::text ~~ '%Facility%'::text;
ALTER TABLE getm_admin.tm_pub_facility
  OWNER TO getm_admin;
GRANT ALL ON TABLE getm_admin.tm_pub_facility TO getm_admin;
GRANT SELECT ON TABLE getm_admin.tm_pub_facility TO getm_ro;

CREATE OR REPLACE VIEW getm_admin.tm_pub_functional AS
  SELECT *
    FROM getm_admin.tm_pub
  WHERE tm_pub.out_ty::text ~~ '%Functional%'::text;
ALTER TABLE getm_admin.tm_pub_functional
  OWNER TO getm_admin;
GRANT ALL ON TABLE getm_admin.tm_pub_functional TO getm_admin;
GRANT SELECT ON TABLE getm_admin.tm_pub_functional TO getm_ro;

CREATE OR REPLACE VIEW getm_admin.tm_pub_installation AS
  SELECT *
    FROM getm_admin.tm_pub
  WHERE tm_pub.out_ty::text ~~ '%Installation%'::text;
ALTER TABLE getm_admin.tm_pub_installation
  OWNER TO getm_admin;
GRANT ALL ON TABLE getm_admin.tm_pub_installation TO getm_admin;
GRANT SELECT ON TABLE getm_admin.tm_pub_installation TO getm_ro;

CREATE OR REPLACE VIEW getm_admin.tm_pub_poi AS
  SELECT *
    FROM getm_admin.tm_pub
  WHERE tm_pub.out_ty::text ~~ '%POI%'::text;
ALTER TABLE getm_admin.tm_pub_poi
  OWNER TO getm_admin;
GRANT ALL ON TABLE getm_admin.tm_pub_poi TO getm_admin;
GRANT SELECT ON TABLE getm_admin.tm_pub_poi TO getm_ro;
