CREATE OR REPLACE FUNCTION spellNumericValue( pValue numeric)
  RETURNS text AS
$BODY$
DECLARE
  _dollar bigint = TRUNC(pValue)::text;
  _cents int = ((pValue - TRUNC(pValue))*100)::int;
  _spelledAmount text = '' ; 
  _brokenOut int[] ;
  _pos INTEGER = 0;
  _word text ;
  _tempVal int = 0 ;
BEGIN
 
	--break the number down into separate elements each containing a max of 3
        --digits.  Number 23321456 is broken in array like so {456,321,23}
	WHILE _dollar > 0 LOOP
		_brokenOut = array_append(_brokenOut, (_dollar%1000)::int);
		_dollar = TRUNC(_dollar/1000);
		_pos = _pos + 1;
	END LOOP;
 
	--this works on numbers between 1 to 999 transforming into english words, then goes to the
	--next set of numbers in the array working backwards as the array was loaded backwards
	--Meaning the highest value is the last element of the array _brokenOut
	--This assumes words thousands millions, billions... occurs every 10^3  
	WHILE _pos > 0 LOOP
		_tempVal = _brokenOut[_pos] ;  --use _tempVal to work on using the array directly has big performance hit. 
		IF _tempVal >99 THEN
			IF    _tempVal > 899 THEN _spelledAmount = _spelledAmount || 'Nine Hundred ' ;
			ELSIF _tempVal > 799 THEN _spelledAmount = _spelledAmount || 'Eight Hundred ' ;
			ELSIF _tempVal > 699 THEN _spelledAmount = _spelledAmount || 'Seven Hundred ' ;
			ELSIF _tempVal > 599 THEN _spelledAmount = _spelledAmount || 'Six Hundred ' ;
			ELSIF _tempVal > 499 THEN _spelledAmount = _spelledAmount || 'Five Hundred ' ;
			ELSIF _tempVal > 399 THEN _spelledAmount = _spelledAmount || 'Four Hundred ' ;
			ELSIF _tempVal > 299 THEN _spelledAmount = _spelledAmount || 'Three Hundred ' ;
			ELSIF _tempVal > 199 THEN _spelledAmount = _spelledAmount || 'Two Hundred ' ;
			ELSIF _tempVal > 99 THEN  _spelledAmount = _spelledAmount || 'One Hundred ' ;
			END IF ;
		END IF;
 
		IF    _tempVal%100 = 10 THEN _spelledAmount = _spelledAmount || 'Ten ';
		ELSIF _tempVal%100 = 11 THEN _spelledAmount = _spelledAmount || 'Eleven ';
		ELSIF _tempVal%100 = 12 THEN _spelledAmount = _spelledAmount || 'Twelve ';
		ELSIF _tempVal%100 = 13 THEN _spelledAmount = _spelledAmount || 'Thirteen ';
		ELSIF _tempVal%100 = 14 THEN _spelledAmount = _spelledAmount || 'Fourteen ';
		ELSIF _tempVal%100 = 15 THEN _spelledAmount = _spelledAmount || 'Fifteen ';
		ELSIF _tempVal%100 = 16 THEN _spelledAmount = _spelledAmount || 'Sixteen ';
		ELSIF _tempVal%100 = 17 THEN _spelledAmount = _spelledAmount || 'Seventeen ';
		ELSIF _tempVal%100 = 18 THEN _spelledAmount = _spelledAmount || 'Eighteen ';
		ELSIF _tempVal%100 = 19 THEN _spelledAmount = _spelledAmount || 'Nineteen ';
		ELSIF _tempVal/10%10 =2 THEN _spelledAmount = _spelledAmount || 'Twenty '; 
		ELSIF _tempVal/10%10 =3 THEN _spelledAmount = _spelledAmount || 'Thirty ' ;
		ELSIF _tempVal/10%10 =4 THEN _spelledAmount = _spelledAmount || 'Fourty ' ;
		ELSIF _tempVal/10%10 =5 THEN _spelledAmount = _spelledAmount || 'Fifty ' ;
		ELSIF _tempVal/10%10 =6 THEN _spelledAmount = _spelledAmount || 'Sixty ' ;
		ELSIF _tempVal/10%10 =7 THEN _spelledAmount = _spelledAmount || 'Seventy ' ;
		ELSIF _tempVal/10%10 =8 THEN _spelledAmount = _spelledAmount || 'Eighty ' ;
		ELSIF _tempVal/10%10 =9 THEN _spelledAmount = _spelledAmount || 'Ninety  ' ;
		END IF ;
 
 
		IF _tempVal%100 < 10 OR _tempVal%100 > 20 THEN
			IF    _tempVal%10 = 1 THEN _spelledAmount = _spelledAmount || 'One ';
			ELSIF _tempVal%10 = 2 THEN _spelledAmount = _spelledAmount || 'Two ';
			ELSIF _tempVal%10 = 3 THEN _spelledAmount = _spelledAmount || 'Three ';
			ELSIF _tempVal%10 = 4 THEN _spelledAmount = _spelledAmount || 'Four ';
			ELSIF _tempVal%10 = 5 THEN _spelledAmount = _spelledAmount || 'Five ';
			ELSIF _tempVal%10 = 6 THEN _spelledAmount = _spelledAmount || 'Six ';
			ELSIF _tempVal%10 = 7 THEN _spelledAmount = _spelledAmount || 'Seven ';
			ELSIF _tempVal%10 = 8 THEN _spelledAmount = _spelledAmount || 'Eight ';
			ELSIF _tempVal%10 = 9 THEN _spelledAmount = _spelledAmount || 'Nine ';
			END IF ;
		END IF ;
 
                --Based on array element tells us which word to use.  
                --As the array is loaded backwards the highest value is
                --highest array element number. To take it higher values all
                --one needs to do is add more elsif statements. 
		IF _pos = 2 THEN
			_spelledAmount = _spelledAmount || 'Thousand ';
		ELSIF _pos = 3  THEN
			_spelledAmount = _spelledAmount || 'Million';
		ELSIF _pos = 4  THEN
			_spelledAmount = _spelledAmount || 'Billion ';
		ELSIF _pos = 5 THEN
			_spelledAmount = _spelledAmount || 'Trillion ';
		ELSIF _pos = 6 THEN
			_spelledAmount = _spelledAmount || 'Quadrillion ';
		ELSIF _pos = 7 THEN
			_spelledAmount = _spelledAmount || 'Quintillion ';
		ELSE 
			_spelledAmount = _spelledAmount || '';
		END IF;
 
		_pos = _pos-1;
	END LOOP;
 
        --Functions primary purpose is to write out the amount on Checks
        --this can be dropped out if you don't need it.   
        IF pvalue <= 0.99 THEN
		_spelledAmount = _spelledAmount || 'Zero Dollars ';
	ELSE 
		_spelledAmount = _spelledAmount || 'Dollars ';
	END IF ;
 
	IF _cents = 0 THEN
		_spelledAmount = _spelledAmount || ' and Zero cents';
	ELSE
		_spelledAmount = _spelledAmount || 'and ' || _cents::text || '/100 cents';
	END IF ;
	RETURN _SpelledAmount;
 
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

