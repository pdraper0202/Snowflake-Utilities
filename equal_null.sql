/************************/
/*****  EQUAL_NULL  *****/
/************************/

/*
 * In snowflake, the clause where x != y will also not return rows where x is null.
 * This is different from some other databases.
 * To also return the nulls, use the equal_null function.
 */

create temporary table equal_null_demo (
    id number
    , val number
);

insert into equal_null_demo values
      (1, 1)
    , (2, 2)
    , (3, 3)
    , (4, null)
    , (5, 5)
;

-- !=
select id, val
from equal_null_demo
where val != 1;

select id, val
from equal_null_demo
where not equal_null(val, 1);

-- not in (is there something better?)
select id, val
from equal_null_demo
where val not in (1, 2);

select id, val
from equal_null_demo
where not (
    equal_null(val, 1)
    or equal_null(val, 2)
);

drop table equal_null_demo;
