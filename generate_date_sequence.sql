/*
 * Generate a sequence of days (months) from a defined start day (month)
 * up to the most recent complete day (month).
 */

/* Calculate total number of days/months to generate */
set number_days = (
    select datediff(
        'day',
        to_date('2022-01-01', 'YYYY-MM-DD'), -- start day
        current_date
    )
);

set number_months = (
    select datediff(
        'month',
        to_date('2021-01-01', 'YYYY-MM-DD'), -- start month
        date_trunc('month', current_date)
    )
);

/* Generate sequence of days */
select dateadd(
        'day',
        '-' || row_number() over (order by null),
        current_date
    ) as date_sequence
from table (generator(rowcount => ($number_days)))
-- order by date_sequence asc;

/* Generate sequence of months */
select dateadd(
        'month',
        '-' || row_number() over (order by null),
        date_trunc('month', current_date)
    ) as month_sequence
from table (generator(rowcount => ($number_months)))
-- order by month_sequence asc;

/* Clean up */
unset number_days;
unset number_months;
