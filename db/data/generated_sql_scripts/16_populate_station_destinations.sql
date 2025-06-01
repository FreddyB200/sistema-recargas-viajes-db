

\echo 'Populando la tabla station_destinations desde los datos de trips...'


DO $$
DECLARE
    v_aggregation_period TEXT := 'JUNIO_2024_SEMANA_03_AL_09';
    v_trips_start_date TIMESTAMP := '2024-06-03 00:00:00';
    v_trips_end_date TIMESTAMP := '2024-06-10 00:00:00'; -- Exclusivo (hasta el inicio del día 10)
BEGIN
    RAISE NOTICE 'Limpiando datos previos de station_destinations para el período: %', v_aggregation_period;
    DELETE FROM station_destinations WHERE aggregation_period = v_aggregation_period;

    RAISE NOTICE 'Calculando y insertando nuevas agregaciones para station_destinations...';
    WITH JourneyLegsRanked AS (
        SELECT
            transfer_group_id,
            card_id, -- Incluido para posible análisis futuro, no estrictamente necesario para esta agregación
            boarding_station_id,
            disembarking_station_id,
            boarding_time,
            -- Rango para el primer tramo del viaje
            ROW_NUMBER() OVER (PARTITION BY transfer_group_id ORDER BY boarding_time ASC) as rn_asc,
            -- Rango para el último tramo del viaje
            ROW_NUMBER() OVER (PARTITION BY transfer_group_id ORDER BY boarding_time DESC) as rn_desc
        FROM
            trips
        WHERE
            boarding_time >= v_trips_start_date AND boarding_time < v_trips_end_date
    ),
    ActualJourneys AS (
        SELECT
            first_leg.boarding_station_id AS true_origin_station_id,
            last_leg.disembarking_station_id AS true_final_destination_station_id
        FROM
            JourneyLegsRanked first_leg
        JOIN
            JourneyLegsRanked last_leg ON first_leg.transfer_group_id = last_leg.transfer_group_id
        WHERE
            first_leg.rn_asc = 1  -- Primer tramo del viaje
            AND last_leg.rn_desc = 1 -- Último tramo del viaje
            AND first_leg.boarding_station_id IS NOT NULL
            AND last_leg.disembarking_station_id IS NOT NULL
            AND first_leg.boarding_station_id != last_leg.disembarking_station_id -- Opcional: excluir viajes que terminan donde empiezan
    ),
    AggregatedCounts AS (
        SELECT
            true_origin_station_id,
            true_final_destination_station_id,
            COUNT(*) AS total_trips
        FROM
            ActualJourneys
        GROUP BY
            true_origin_station_id,
            true_final_destination_station_id
    )
    INSERT INTO station_destinations (origin_station_id, final_destination_station_id, trip_count, aggregation_period)
    SELECT
        ac.true_origin_station_id,
        ac.true_final_destination_station_id,
        ac.total_trips,
        v_aggregation_period
    FROM
        AggregatedCounts ac
    ON CONFLICT (origin_station_id, final_destination_station_id, aggregation_period) 
    DO UPDATE SET trip_count = EXCLUDED.trip_count; -- Si se re-ejecuta, sobrescribe con el nuevo conteo

    RAISE NOTICE 'Población de station_destinations completada para el período: %', v_aggregation_period;
END $$;

\echo 'Tabla station_destinations poblada.'