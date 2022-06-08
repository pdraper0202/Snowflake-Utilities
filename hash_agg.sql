/**********************************/
/***********  HASH_AGG  ***********/
/**********************************/

/*
 * To check if two tables are exactly identical, the hash_agg()
 * function is helpful
 */
 
/* Create two tables to compare */
create temporary table tbl_x (
    col_a number
    , col_b varchar
);

create temporary table tbl_y (
    col_a number
    , col_b varchar
    , col_c number
);

/* Insert data */
insert into tbl_x values 
      (1, 'a')
    , (2, 'b')
    , (3, 'c')
    , (4, 'd')
;

insert into tbl_y values 
      (1, 'a', 5)
    , (2, 'b', 6)
    , (3, 'c', 7)
    , (4, 'd', 8)
;

/* Compare */

-- Expect False
select
    (select hash_agg(*) from tbl_x)
     = (select hash_agg(*) from tbl_y) as is_hash_equal
;

-- Expect True
select
    (select hash_agg(*) from tbl_x)
     = (select hash_agg(col_a, col_b) from tbl_y) as is_hash_equal
;

/* Drop temporary tables */
drop table tbl_x;
drop table tbl_y;
