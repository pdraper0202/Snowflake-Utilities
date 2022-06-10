/*********************************/
/*******  PIVOT & UNPIVOT  *******/
/*********************************/

/*
 * Unpivot - makes a wide table long
 * Pivot - makes a long table wide
 */

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

create or replace table long_tbl as 
    select *
    from wide_tbl
    unpivot(value for metric in (
          metric_a
        , metric_b
        , metric_c
        , metric_d
    ))
;

create or replace table wide_tbl2 as 
    select *
    from long_tbl
    pivot(sum(value) for metric in (
          'METRIC_A'
        , 'METRIC_B'
        , 'METRIC_C'
        , 'METRIC_D'
    )) as p (
          id
        , metric_a
        , metric_b
        , metric_c
        , metric_d
    )
;

select
    (select hash_agg(*) from wide_tbl)
    = (select hash_agg(*) from wide_tbl2) as is_equal
;

drop table wide_tbl;
drop table long_tbl;
drop table wide_tbl2;