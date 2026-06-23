with raw as (

    select *
    from {{ source('oc_raw', 'POPULATION') }}

),

unpivoted as (

    select
        region,
        variable,
        value as population
    from raw
    unpivot (
        value for variable in (
            ENSEMBLE_0_19,
            ENSEMBLE_20_39,
            ENSEMBLE_40_59,
            ENSEMBLE_60_74,
            ENSEMBLE_75_PLUS,
            HOMMES_0_19,
            HOMMES_20_39,
            HOMMES_40_59,
            HOMMES_60_74,
            HOMMES_75_PLUS,
            FEMMES_0_19,
            FEMMES_20_39,
            FEMMES_40_59,
            FEMMES_60_74,
            FEMMES_75_PLUS
        )
    )

),

parsed as (

    select
        upper(region) as region_raw,
        split_part(variable, '_', 1) as gender_raw,
        split_part(variable, '_', 2) as age_raw,
        population
    from unpivoted

),

clean as (

    select
        case
            when region_raw in ('DOM', 'DROM') then 'DROM'
            when region_raw in ('GUADELOUPE', 'GUYANE', 'MARTINIQUE', 'MAYOTTE', 'LA REUNION') then 'DROM'
            when region_raw = 'CENTRE-VAL-DE-LOIRE' then 'CENTRE-VAL DE LOIRE'
            when region_raw = 'PROVENCE-ALPES-COTE D''AZUR' then 'PROVENCE-ALPES-COTE D''AZUR'
            when region_raw in ('FRANCE METROPOLITAINE', 'FRANCE METROPOLITAINE ET DOM', 'CORSE') then null
            else region_raw
        end as region,

        case
            when gender_raw = 'ENSEMBLE' then 'ALL'
            when gender_raw = 'HOMMES' then 'HOMME'
            when gender_raw = 'FEMMES' then 'FEMME'
        end as gender,

        case
            when age_raw = '0' then '0-19'
            when age_raw = '20' then '20-39'
            when age_raw = '40' then '40-59'
            when age_raw = '60' then '60-74'
            when age_raw = '75' then '75+'
        end as age_group,

        population

    from parsed

)

select *
from clean
where region is not null