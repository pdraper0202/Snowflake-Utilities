/*
 * For each value of foo, give a distinct count of bar where foo is in 
 * the rolling range [foo - 4, foo].
 * This can be useful when foo is, say, a date, and you need
 * the distinct count of bar during a rolling date window.
 */

create temporary table tbl (
    foo number
    , bar varchar
)
;

insert into tbl values 
      (1, 'a')
    , (2, 'b')
    , (3, 'b')
    , (4, 'a')
    , (5, 'c')
    , (6, 'b')
    , (7, 'a')
    , (8, 'a')
    , (9, 'a')
    , (10, 'a')
    , (11, 'a')
    , (12, 'b')
    , (13, 'a')
    , (14, 'c')
    , (15, 'd')
    , (16, 'b')
    , (17, 'c')
    , (18, 'd')
    , (19, 'd')
    , (20, 'a')
;

select
    x.foo
    , (
        select count(distinct t.bar)
        from tbl t
        where t.foo between x.foo - 4 and x.foo
    ) as bar_count_distinct_rolling
from tbl x
order by x.foo
;

drop table tbl;