--fairly complicated sql statement that was created to feed an R app,  each set of parent items had 200K to 500K child entries

with outlimit as 
		( select (max_abs-min_abs) * 0.90 + min_abs as outlimit, max_abs, min_abs ,id as outid 
	 		from test 
   			where id in (", keys2, " NULL)), 
	thres as 
		(select min(unique_id) as min_id, max(unique_id) as max_id, parent_id as thres_id
			from testvalues 
			right join outlimit on outlimit.outid = parent_id 
			where output_mv >= outlimit 
			group by parent_id ),
 	counter as
		( select count(output_mv) as times_below, parent_id as cid 
		 	from testvalues, outlimit, thres 
		 	where outlimit.outid = testvalues.parent_id 
		 		and outlimit.outid = thres_id 
		 		and output_mv < outlimit
		 		and testvalues.unique_id between min_id and max_id 
		 	group by parent_id )
 select outlimit.*, thres.*, counter.*, (max_id - min_id) as total_samples, 
 		round( (times_below::numeric / (max_id-min_id)::numeric)*100,2) as ratio_times_below_to_samples, 
		test.* ,output_mv, input_mv, cid as parent_id, test_time, unique_id 
 	from testvalues, test, outlimit, thres, counter 
	where parent_id = outid 
		and id = outid 
		and outid = thres_id 
		and cid = outid 
		and unique_id between min_id and max_id 
	order by unique_id ;
  
 -- tables that feed this sql statement
 CREATE TABLE public.test
(
    id integer NOT NULL DEFAULT nextval('test_id_seq'::regclass) ,
    capture_time timestamp without time zone,
    machine_ammeter numeric(20,10) DEFAULT 0,
    machine_sn text,
    waveform text,
    machine_make text ,
    machine_model text ,
    datafile text ,
    load text ,
    shunt_ccf numeric,
    output_delta numeric,
    output_percentdiff numeric,
    output_ideal numeric,
    output_deviation numeric,
    input_ideal numeric,
    io_ratio numeric,
    target_ammeter numeric,
    max_abs numeric(14,6),
    min_abs numeric(14,6),
    notes text,
    key_uuid uuid,
    CONSTRAINT test_pkey PRIMARY KEY (id)
);
unique_id integer NOT NULL DEFAULT nextval('testvalues_unique_id_seq'::regclass) ,
    parent_id integer,
    output_mv numeric(14,6),
    input_mv numeric(14,6),
    test_time time without time zone,
    key_uuid uuid,
    CONSTRAINT testvalues_pkey PRIMARY KEY (unique_id)
        USING INDEX TABLESPACE mag_lab,
    CONSTRAINT parent_id FOREIGN KEY (parent_id)
        REFERENCES public.test (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);


