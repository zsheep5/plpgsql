Create or Replace function max_bytea_length(pchars text, bytea_length int)
RETURNS bytea
LANGUAGE plpgsql

COST 100
VOLATILE 
AS $BODY$

declare 
_i int;
_length_of_chars int;
_newchars text;
_testchars text;
begin

if octet_length(pchars::bytea) <= bytea_length then
   return pchars::bytea;
end if;
_i = least( octet_length(pchars)-4, bytea_length-4);
_length_of_chars =  char_length(pchars);
loop 
   _newchars= left(pchars, _i);
    _testchars = left(pchars, _i+1); 
  if octet_length(_testchars::bytea) > bytea_length or _i = _length_of_chars  then
     return _newchars::bytea;
  end if ;
  _i = _i+1;
end loop ;

end;
$BODY$