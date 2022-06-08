/********************************/
/***********  ARRAYS  ***********/
/********************************/

/*
 * Given a table of data, condense it using arrays, and expand it using flatten.
 */

/* Create test table and populate with data */
create or replace temporary table arrays_example (
    id number     -- entity to group by
    , seq number  -- entity to order by
    , foo number
    , bar number
);

insert into arrays_example values 
      (1, 1, 7, 25)
    , (1, 2, 8, 26)
    , (1, 3, 9, 27)
    , (1, 4, 10, 28)
    , (1, 5, 11, 29)
    , (1, 6, 12, 30)
    , (2, 1, 13, 31)
    , (2, 4, 16, 32)
    , (2, 2, 14, 33)
    , (2, 5, 17, 34)
    , (2, 3, 15, 35)
    , (2, 6, 18, 36)
    , (3, 6, 24, 37)
    , (3, 5, 23, 38)
    , (3, 4, 22, 39)
    , (3, 3, 21, 40)
    , (3, 2, 20, 41)
    , (3, 1, 19, 42)
;

create or replace table nested_tbl as
    select 
        id
        , array_agg(seq) within group (order by seq) as seq_arr
        , array_agg(foo) within group (order by seq) as foo_arr
        , array_agg(bar) within group (order by seq) as bar_arr
    from arrays_example
    group by id
    order by id
;

create or replace table flat_tbl as
    select
        s.id
        , f.value as seq
        , foo_arr[f.index] as foo
        , bar_arr[f.index] as bar
    from
        nested_tbl as s
        , lateral flatten(input => s.seq_arr) as f
;

select
    (select hash_agg(*) from arrays_example)
     = (select hash_agg(*) from flat_tbl) as is_equal
;

drop table arrays_example;
drop table nested_tbl;
drop table flat_tbl;
