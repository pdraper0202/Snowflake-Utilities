/***********************************/
/*******  OUTLIER DETECTION  *******/
/***********************************/

/***  MEDIAN ABSOLUTE DEVIATION  ***/
create temporary table mad_test (
    id number     -- entities
    , grp number  -- partition by
    , val number  -- data
);

insert into mad_test values 
      (1, 1, 3)
    , (2, 1, 5)
    , (3, 1, 1)
    , (4, 1, 5)
    , (5, 1, 4)
    , (6, 1, 6)
    , (7, 1, 18) -- outlier
    , (8, 1, 3)
    , (9, 1, 3)
    , (10, 1, 1)
    , (1, 2, 2)
    , (2, 2, 5)
    , (3, 2, 6)
    , (4, 2, 7)
    , (5, 2, 7)
    , (6, 2, 3)
    , (7, 2, 8)
    , (8, 2, 9)
    , (9, 2, null)
    , (10, 2, 2)
;

with
param as (
    select 5 as z_thresh
)
, tmp as (
    select
        *
        , median(val) over (partition by grp) as median_val
        , abs(val - median_val) as absolute_deviation
    from mad_test
)
select
    *
    , median(absolute_deviation) over (partition by grp) as median_absolute_deviation
    , absolute_deviation / nullif(1.4826 * median_absolute_deviation, 0) as z_abs_robust
    , z_abs_robust >= (select z_thresh from param) as is_outlier
from tmp;

drop table mad_test;