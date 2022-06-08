/**********************************/
/*******  LONGEST SEQUENCE  *******/
/**********************************/

/*
 * For each instance in column id, determine the length, 
 * start row, and end row of the longest sequence
 * of value 0 in column flag (indicator column of 0/1) as ordered by
 * column seq. For each id, returns a row of form
 * (id, sequence_length, row_start, row_end)
 */

/* Create test table and populate with data */
create temporary table longest_sequence_test (
    id number     -- entities to group by
    , seq number  -- field for the order by clause
    , flag number -- 0 or 1
);

insert into longest_sequence_test values 
    -- basic example, starting at flag = 0
    -- expect (1, 5, 1, 5)
      (1, 1, 0)
    , (1, 2, 0)
    , (1, 3, 0)
    , (1, 4, 0)
    , (1, 5, 0)
    , (1, 6, 1)
    -- basic example, starting at flag = 1
    -- expect (2, 2, 3, 4)
    , (2, 1, 1)
    , (2, 2, 1)
    , (2, 3, 0)
    , (2, 4, 0)
    , (2, 5, 1)
    , (2, 6, 1)
    -- seq can be different
    -- expect (3, 5, 2, 6)
    , (3, 10, 1)
    , (3, 15, 0)
    , (3, 17, 0)
    , (3, 32, 0)
    , (3, 55, 0)
    , (3, 57, 0)
    -- breaking ties
    -- expect (4, 3, 9, 11)
    , (4, 1, 1)
    , (4, 2, 1)
    , (4, 3, 0)
    , (4, 4, 0)
    , (4, 5, 0)
    , (4, 6, 1)
    , (4, 7, 1)
    , (4, 8, 1)
    , (4, 9, 0)
    , (4, 10, 0)
    , (4, 11, 0)
    , (4, 12, 1)
    -- no sequence of 0's
    -- expect (5, null, null, null)
    , (5, 1, 1)
    , (5, 2, 1)
    , (5, 3, 1)
    , (5, 4, 1)
    , (5, 5, 1)
    , (5, 6, 1)
;

/* Longest Sequence query */
with
-- add row_number column
appended as (
    select
        id
        , seq
        , flag
        , row_number() over (partition by id order by seq) as rownum
    from longest_sequence_test
)
-- calculate sequence lengths
, recurse as (
    select
        id
        , seq
        , flag
        , rownum
        , case when flag = 0 then 1 else 0 end as sequence_length
    from appended
    where rownum = 1
    union all
    select
        curr.id
        , curr.seq
        , curr.flag
        , curr.rownum
        , case when curr.flag = 0 then prev.sequence_length + 1 else 0 end
    from recurse prev
    join appended curr
        on prev.id = curr.id
        and prev.rownum + 1 = curr.rownum
)
-- select longest sequence
, results_temp as (
    select
        id
        , rownum
        , sequence_length
        , rownum - sequence_length + 1 as row_start
        , rownum as row_end
    from recurse
    qualify
        max(sequence_length) over (partition by id) > 0
        and sequence_length = max(sequence_length) over (partition by id)
)
-- break ties by taking the most recent longest sequence
, results as (
    select
        id
        , sequence_length
        , row_start
        , row_end
    from results_temp
    qualify rownum = max(rownum) over (partition by id)
)
-- join on any id's that have no sequence
select
    a.id
    , r.sequence_length
    , r.row_start
    , r.row_end
from (select distinct id from appended) as a
left join results r on a.id = r.id
order by id;

/* Drop temporary table */
drop table longest_sequence_test;