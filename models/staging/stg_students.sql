with base as (
    select
        USER_ID,
        PATH_CATEGORY_NAME,
        AGE_GROUP,
        GENDER,
        REGION,
        YEAR_PATH_STARTED,
        row_number() over (
            partition by USER_ID
            order by YEAR_PATH_STARTED desc
        ) as rn
    from {{ source('oc_raw', 'students') }}
)

select
    USER_ID,
    PATH_CATEGORY_NAME as path_category,
    AGE_GROUP,
    GENDER,
    REGION,
    YEAR_PATH_STARTED
from base
where rn = 1
