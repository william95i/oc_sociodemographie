select
    user_id,
    path_category,
    age_group,
    gender,
    region,
    year_path_started
from {{ ref('int_students') }}

