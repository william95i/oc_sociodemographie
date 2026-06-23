{{ config(
    materialized = 'table'
) }}

WITH students AS (

    SELECT
        year_path_started AS year,
        region,
        age_group_norm AS age_group,
        gender,
        COUNT(*) AS students_count
    FROM {{ ref('int_students') }}
    GROUP BY
        year_path_started,
        region,
        age_group_norm,
        gender

),

insee AS (

    SELECT
        region,
        age_group,
        gender,
        population
    FROM {{ ref('stg_insee_pop_2024') }}

),

joined AS (

    SELECT
        s.year,
        s.region,
        s.age_group,
        s.gender,
        s.students_count,
        i.population AS population_insee,

        -- Ratio étudiants / 10 000 habitants
        CASE 
            WHEN i.population IS NULL THEN NULL
            ELSE ROUND((s.students_count::FLOAT / i.population) * 10000, 4)
        END AS student_population_ratio,

        -- Parts en POURCENTAGE
        ROUND((i.population::FLOAT / sum(i.population) over ()) * 100, 4)
            AS part_population_pct,

        ROUND((s.students_count::FLOAT / sum(s.students_count) over ()) * 100, 4)
            AS part_students_pct,

        -- Sur / sous-représentation en points de pourcentage
        ROUND(
            ((s.students_count::FLOAT / sum(s.students_count) over ()) -
             (i.population::FLOAT / sum(i.population) over ())) * 100,
            4
        ) AS ecart_representation_pct

    FROM students s
    LEFT JOIN insee i
        ON s.region = i.region
        AND s.age_group = i.age_group
        AND (
            s.gender = i.gender
            OR (s.gender = 'INCONNU' AND i.gender = 'ALL')
        )

)

SELECT *
FROM joined
ORDER BY year, region, age_group, gender



