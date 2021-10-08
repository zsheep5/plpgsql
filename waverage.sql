CREATE OR REPLACE FUNCTION waverage_sf (numeric[], _value numeric, _weight numeric)
RETURNS numeric[] as 
$Body$
	DECLARE 
		_state numeric[];
	BEGIN 
		_state = $1;
		_state[1] = _state[1]+_weight;
  		_state[2] = _state[2]+_weight*_value;
		return _state;
	END;
$Body$
LANGUAGE 'plpgsql' VOLATILE;

CREATE OR REPLACE FUNCTION waverage_ff ( _state numeric[] )
RETURNS numeric as 
$Body$
	BEGIN 
		RETURN (_state[2]/_state[1]);
	END;
$Body$
LANGUAGE 'plpgsql' VOLATILE;

CREATE OR REPLACE AGGREGATE waverage (numeric, numeric)(
	sfunc = waverage_sf, 
	stype = numeric[],
	initcond = '{0,0}',
	finalfunc = waverage_ff
);

select waverage(df,df ) 
from generate_series(1,100) as df