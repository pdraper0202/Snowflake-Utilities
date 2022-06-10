/****************************************/
/*******  TWO METHODS TO UNPIVOT  *******/
/****************************************/

create or replace temporary table wide_tbl (
      id number
    , metric_a number
    , metric_b number
    , metric_c number
    , metric_d number
);

insert into wide_tbl values 
      (1, 1, 2, 3, 4)
    , (2, 5, 6, 7, 8)
    , (3, 9, 10, 11, 12)
    , (4, 13, 14, 15, 16)
    , (5, 17, 18, 19, 20)
;

-- unpivot using a cross join
create or replace table long_tbl1 as
    with
    metric_list as (
        select 'METRIC_A' as metric
        union all
        select 'METRIC_B' as metric
        union all
        select 'METRIC_C' as metric
        union all
        select 'METRIC_D' as metric
    )
    select
        w.id
        , m.metric
        , case 
            when m.metric = 'METRIC_A' then metric_a
            when m.metric = 'METRIC_B' then metric_b
            when m.metric = 'METRIC_C' then metric_c
            when m.metric = 'METRIC_D' then metric_d
        end as value
    from wide_tbl as w, metric_list as m
;

-- unpivot using the unpivot function
create or replace table long_tbl2 as
    select *
    from wide_tbl
    unpivot(value for metric in (
          metric_a
        , metric_b
        , metric_c
        , metric_d
    ))
;

-- verify results are equal
select
    (select hash_agg(*) from long_tbl1)
    = (select hash_agg(*) from long_tbl2) as is_equal
;

-- create a much larger table
create or replace table wide_tbl as
    select 
        seq8() as id
        , uniform(1, 10, random(127)) as metric_a
        , uniform(1, 10, random(127)) as metric_b
        , uniform(1, 10, random(127)) as metric_c
        , uniform(1, 10, random(127)) as metric_d
    from table(generator(rowcount => 100000000))
    order by 1
;

-- timing would be better over multiple iterations, but...
-- this method took 12s
create or replace table long_tbl1 as
    with
    metric_list as (
        select 'METRIC_A' as metric
        union all
        select 'METRIC_B' as metric
        union all
        select 'METRIC_C' as metric
        union all
        select 'METRIC_D' as metric
    )
    select
        w.id
        , m.metric
        , case 
            when m.metric = 'METRIC_A' then metric_a
            when m.metric = 'METRIC_B' then metric_b
            when m.metric = 'METRIC_C' then metric_c
            when m.metric = 'METRIC_D' then metric_d
        end as value
    from wide_tbl as w, metric_list as m
;

-- this method took 12s as well
create or replace table long_tbl2 as
    select *
    from wide_tbl
    unpivot(value for metric in (
          metric_a
        , metric_b
        , metric_c
        , metric_d
    ))
;

-- again verify results are equal
select
    (select hash_agg(*) from long_tbl1)
    = (select hash_agg(*) from long_tbl2) as is_equal
;

drop table wide_tbl;
drop table long_tbl1;
drop table long_tbl2;
