CREATE SCHEMA ol_code;
show search_path;  --show the current search path;
set search_path to ol_code, pg_catalog, public; --temporary change the path 
CREATE OR REPLACE FUNCTION ol_code.round(val numeric, prec integer default 0)
    RETURNS numeric
	LANGUAGE 'plpgsql'
	COST 1
	STRICT PARALLEL SAFE
as $$
	DECLARE
		_last_digit numeric = TRUNC(ABS((val * (10::numeric^prec) %1::numeric )),1);
	BEGIN
		IF _last_digit = 0.5 THEN  --the digit being rounded is 5 
			-- lets find out if the leading digit is even or odd  
			IF TRUNC(ABS(val * (10::numeric^prec))) %2::numeric = 0 THEN
				RETURN trunc(val::numeric,prec);
			END IF ;
		END IF ;
		IF val > 0.0 AND _last_digit >= 0.5 THEN
			RETURN  trunc(val::numeric + (1/ (10::numeric^prec)), prec) ;
		ELSEIF  val > 0.0 AND _last_digit < 0.5 THEN
			RETURN trunc(val::numeric, prec);
		ELSEIF val < 0.0 AND _last_digit >= 0.5 THEN
			RETURN  trunc(val::numeric - (1/ (10::numeric^prec)), prec) ;
		ELSE
			RETURN  trunc(val::numeric, prec);
		END IF;
	END ;
$$;
---test the results
select  pg_catalog.round(10.6745, 3), round(10.6745, 3),  pg_catalog.round(10.6746, 3), round(10.6746, 3),
	pg_catalog.round(-10.6745, 3), round(-10.6745, 3),  pg_catalog.round(-10.6746, 3), round(-10.6746, 3)
