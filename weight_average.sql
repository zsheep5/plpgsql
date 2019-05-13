--Weight aggrate average function

CREATE OR REPLACE FUNCTION w_average_sf(
	numeric[],
	numeric,
	numeric)
    RETURNS numeric[]
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

	begin 
		return array_append(array_append($1, $2), $3);
	end;
$BODY$;

----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION w_average_ff(
	numeric[])
    RETURNS numeric
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
	declare 
		iState       alias for $1 ;
		_sumedWeight numeric ;
		_sumedWxV    numeric ;
		_elmentCount integer ;
		_icounter    integer ;
	begin 
		_elmentCount := array_upper(iState,1) ;
		_sumedWeight := 0 ;
		_sumedWxV    := 0 ;
		_icounter    := 0 ;
			
		loop
			_sumedWeight := _sumedWeight + iState[_icounter + 1] ;
			_icounter := _icounter + 2 ;
			
			if ( _icounter = _elmentCount ) then
				exit; 
			end if ;
		end loop ; 
		_icounter := 0;
		if _sumedWeight = 0 or _sumedWeight is null then
			return null;
		end if ;
		loop 
			_sumedWxV := _sumedWxV + ( (iState[_icounter + 1]/_sumedWeight) * iState[_icounter+2]) ;
			_icounter := _icounter + 2 ;
			
			if ( _icounter = _elmentCount ) then
				exit; 
			end if ;
		end loop ;
		return _sumedWxV;
	end;
$BODY$;

Drop Aggregate if exists w_average(numeric,numeric);
CREATE AGGREGATE w_average(numeric,numeric)
(
	sfunc = w_average_sf,
	stype = numeric[],
	finalfunc = w_average_ff,
	initcond = '{0,0}'
);

--sample use code
create temporary table w_avg ( value_to_average numeric(20,10), value_weight numeric(20,10));
insert into  w_avg values (10.5, 3), (20, .5), (15,0), (12,15);
select w_average(value_weight,value_to_average ) from w_avg;
