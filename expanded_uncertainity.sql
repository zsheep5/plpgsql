-- calculates the expanded uncertainity used to figure out the confidence value with a stack of meters 

CREATE TYPE equip_range_unc AS
(
	range_id integer,
	expunc double precision
);

CREATE OR REPLACE FUNCTION expandeduncertainity(
	pequip_id integer)
    RETURNS SETOF equip_range_unc 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$

DECLARE
	r equip_range_unc%rowtype;

begin 
	for r in select  bb.range_id,  2*(|/ sum((bb.range_pos_tol + bb.range_neg_tol)/2 / |/ 3)) as expunc
			from (
			select range_id,  range_neg_tol, range_pos_tol
				from equip_range,  equip_head
				where equip_id = range_equip_id
				and equip_id = pEquip_id
			union 
			Select toler_p_range_id, range_neg_tol, range_pos_tol 
				from equip_range, toler_rel, equip_head 
				where toler_c_range_id = range_id 
					and equip_id = range_equip_id
					and toler_p_range_id = (select range_id from equip_range where range_equip_id = pEquip_id)) bb
			group by bb.range_id loop 
		return next r;
	end loop;
end;
$BODY$;

CREATE TABLE mcal.equip_head
(
    equip_id serial primary key, 
    equip_name text ,
    equip_mfg text,
    equip_model text ,
    equip_descrip text ,
    equip_caldate date,
    equip_recal date,
    equip_comment text ,
    equip_location text ,
    equip_serial text,
    equip_active boolean NOT NULL DEFAULT true,
    equip_source boolean,
    equip_formula text ,
    equip_prj_id integer
   );
CREATE TABLE mequip_range
(
    range_id serial primary key,
    range_equip_id integer,
    range_desc text ,
    range_unit integer,
    range_scale numeric(20,8),
    range_neg_tol numeric(20,8),
    range_pos_tol numeric(20,8),
    range_repeat numeric(20,8),
    range_abs_rel character(3),
    range_drift numeric(20,8),
    range_drift_sec integer,
    range_jitter integer);

CREATE TABLE toler_rel
(
    toler_id serial primary key,
    toler_p_range_id integer,
    toler_c_range_id integer,
    toler_conver numeric(20,8)
    );
   
