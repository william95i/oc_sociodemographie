with base as (
    select *
    from {{ ref('stg_students') }}
),

cleaned as (
    select
        user_id,
        upper(path_category) as path_category,

        -- Normalisation du genre
        case
            when gender is null then 'INCONNU'
            when trim(upper(gender)) in ('M', 'H', 'HOMME') then 'HOMME'
            when trim(upper(gender)) in ('F', 'FEMME') then 'FEMME'
            else 'INCONNU'
        end as gender,

        -- Normalisation de la région
        upper(region) as region,

        -- Normalisation des tranches d'âge pour matcher l'INSEE
        case
    when age_group in ('20-24 ans', '25-29 ans', '30-34 ans') then '20-39'
    when age_group in ('35-39 ans') then '20-39'

    when age_group in ('40-44 ans', '45-49 ans', '50-54 ans', '55-59 ans') then '40-59'

    when age_group in ('60-64 ans', '65-69 ans', '70-74 ans') then '60-74'

    when age_group = '60 ans ou plus' then '60-74'  

    when age_group like '75%' then '75+'
    else age_group
end as age_group_norm,

        year_path_started
    from base
)

select *
from cleaned

