---  had a need to draw boxes around a string to return the value to a horrible report engine an application used

CREATE OR REPLACE FUNCTION drawbox(
	ptextinbox text,  
	pwidth integer, --how big is the box 
	psecondwidth integer)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE
	_return text = '';
	_length integer = 0;
	_hline text = '';
	_blankspaces text = '';
	_countspaces integer = 0;

begin
	_length = length(ptextinbox);

	_hline = lpad('', pwidth-2, E'\u2501');
  
	_countspaces = (psecondWidth - _length)/2;
	
	--raise notice  '%' ,_countspaces;
	_blankspaces = lpad( '', _countspaces, ' ') ;

	_return = E'\u250F' ||_hline || E'\u2513\r' || _blankspaces || ptextinbox || _blankspaces || E'\r' || E'\u2517' ||_hline || E'\u251B';

	--raise notice E'\r%', _return;
	
	return _return;
end; 
$BODY$;
