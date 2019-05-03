CREATE TABLE "CALCENTRAL"."ps_uc_clc_oauth"
  (
     "uc_clc_id"       NUMBER(*, 0) NOT NULL ENABLE,
     "uc_clc_ldap_uid" VARCHAR2(254 byte) NOT NULL ENABLE,
     "uc_clc_app_id"   VARCHAR2(254 byte) NOT NULL ENABLE,
     "access_token"    CLOB NOT NULL ENABLE,
     "refresh_token"   CLOB NOT NULL ENABLE,
     "uc_clc_expire"   NUMBER(38, 0) NOT NULL ENABLE,
     "app_data"        CLOB NOT NULL ENABLE,
     "created_at"      DATE,
     "updated_at"      DATE
  );

CREATE TABLE "CALCENTRAL"."ps_uc_clc_srvalert"
  (
     "uc_clc_id"       NUMBER(*, 0) NOT NULL ENABLE,
     "uc_alrt_pubdt"   DATE,
     "uc_alrt_snippt"  VARCHAR2(254 byte) NOT NULL ENABLE,
     "uc_alrt_title"   VARCHAR2(254 byte) NOT NULL ENABLE,
     "uc_alrt_display" VARCHAR2(1 byte) NOT NULL ENABLE,
     "uc_alrt_splash"  VARCHAR2(1 byte) NOT NULL ENABLE,
     "created_at"      DATE,
     "updated_at"      DATE,
     "uc_alrt_body"    CLOB
  );

CREATE TABLE "CALCENTRAL"."ps_uc_recent_uids"
  (
     "uc_clc_id"      NUMBER(*, 0) NOT NULL ENABLE,
     "uc_clc_oid"     VARCHAR2(254 byte) NOT NULL ENABLE,
     "uc_clc_stor_id" VARCHAR2(254 byte) NOT NULL ENABLE,
     "created_at"     DATE,
     "updated_at"     DATE
  );

CREATE TABLE "CALCENTRAL"."ps_uc_saved_uids"
  (
     "uc_clc_id"      NUMBER(*, 0) NOT NULL ENABLE,
     "uc_clc_oid"     VARCHAR2(254 byte) NOT NULL ENABLE,
     "uc_clc_stor_id" VARCHAR2(254 byte) NOT NULL ENABLE,
     "created_at"     DATE,
     "updated_at"     DATE
  );

CREATE TABLE "CALCENTRAL"."ps_uc_user_auths"
  (
     "uc_clc_id"       NUMBER(*, 0) NOT NULL ENABLE,
     "uc_clc_ldap_uid" VARCHAR2(254 byte) NOT NULL ENABLE,
     "uc_clc_is_su"    VARCHAR2(1 byte) NOT NULL ENABLE,
     "uc_clc_active"   VARCHAR2(1 byte) NOT NULL ENABLE,
     "uc_clc_is_au"    VARCHAR2(1 byte) NOT NULL ENABLE,
     "uc_clc_is_vw"    VARCHAR2(1 byte) NOT NULL ENABLE,
     "created_at"      DATE,
     "updated_at"      DATE
  );

CREATE TABLE "CALCENTRAL"."ps_uc_user_data"
  (
     "uc_clc_id"       NUMBER(*, 0) NOT NULL ENABLE,
     "uc_clc_ldap_uid" VARCHAR2(254 byte) NOT NULL ENABLE,
     "uc_clc_prefnm"   VARCHAR2(255 byte) NOT NULL ENABLE,
     "uc_clc_fst_at"   DATE,
     "created_at"      DATE,
     "updated_at"      DATE
  );


CREATE SEQUENCE  "CALCENTRAL"."PS_UC_CLC_OAUTH_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 143 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;  
CREATE SEQUENCE  "CALCENTRAL"."PS_UC_CLC_SRVALERT_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 101 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
CREATE SEQUENCE  "CALCENTRAL"."PS_UC_RECENT_UIDS_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 388 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
CREATE SEQUENCE  "CALCENTRAL"."PS_UC_SAVED_UIDS_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 83 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
CREATE SEQUENCE  "CALCENTRAL"."PS_UC_USER_AUTHS_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 68 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
CREATE SEQUENCE  "CALCENTRAL"."PS_UC_USER_DATA_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 106 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
