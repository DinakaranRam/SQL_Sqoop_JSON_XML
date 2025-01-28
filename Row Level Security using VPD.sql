
create or replace
FUNCTION LAND.DINA_DEP_ACSS_VPD_FNC (
OBJECT_SCHEMA ALL_OBJECTS.OWNER%TYPE
,OBJECT_NAME ALL_OBJECTS.OBJECT_NAME%TYPE
) RETURN VARCHAR2 AS

L_PREDICATE VARCHAR2(2000);
L_TEMP VARCHAR2(2000);
L_USER VARCHAR2(200);
L_PRNT_PRMSN_VAL VARCHAR2(200);
L_EXEMPT_PRMSN VARCHAR2(200);
BEGIN

-- Get the logged in User
SELECT SYS_CONTEXT('USERENV', 'SESSION_USER') INTO L_USER FROM DUAL;

-- For WHS_RPT (the OBIEE reporting user) there should be an additional
-- context set for VPD. This will give us the logged in user of OBIEE
IF L_USER = 'HST_RPT' THEN
SELECT SYS_CONTEXT('VPD_CONTEXT', 'USER_NAME') INTO L_USER FROM DUAL;
END IF;

-- See if the user is exempt
begin
SELECT prnt_prmsn_val into L_EXEMPT_PRMSN
FROM LAND.v_ds_usr_prmsn
WHERE usr_nam = L_USER
AND prnt_prmsn_typ_cd='EXEMPT'
AND prnt_prmsn_nam='EDV-Exemption'
and prnt_prmsn_val = 'EDV';


exception
when OTHERS THEN
L_PREDICATE := '1=2' ;
end;

if (L_EXEMPT_PRMSN is not null) then
L_PREDICATE := '1=1' ;
RETURN L_PREDICATE;
end if;

-- user is not exempt, so see they are in GRP_NAME

begin
SELECT prnt_prmsn_val into L_EXEMPT_PRMSN
FROM LAND.v_ds_usr_prmsn
WHERE usr_nam = L_USER
AND grp_nam='GRP_NAME'
AND prnt_prmsn_nam='GRP_NAME'
and prnt_prmsn_val = 'X';

exception
when OTHERS THEN
L_PREDICATE := '1=2' ;
end;

if (L_EXEMPT_PRMSN is not null) then
L_PREDICATE := '1=1' ;
RETURN L_PREDICATE;
end if;

-- user is not exempt, so see what doc classes they get.
-- See if the user is in the proper group

begin
SELECT prnt_prmsn_val into L_EXEMPT_PRMSN
FROM LAND.v_ds_usr_prmsn
WHERE usr_nam = L_USER
AND grp_nam='BIGRP_NAME'
AND prnt_prmsn_nam='DEP-Exemption'
and prnt_prmsn_val = 'DEP';

exception
when OTHERS THEN
L_PREDICATE := '1=2' ;
end;

if (L_EXEMPT_PRMSN is not null) then
L_PREDICATE := '1=1' ;
ELSE
L_PREDICATE := '1=2' ;

RETURN L_PREDICATE;
end if;


RETURN L_PREDICATE;

END;

GRANT EXECUTE ON LAND.DINA_CMT_ACSS_VPD_FNC TO LAND_ADM_ROLE