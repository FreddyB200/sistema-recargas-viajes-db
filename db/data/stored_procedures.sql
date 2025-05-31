-- Stored Function for Revenue by Localities
CREATE OR REPLACE FUNCTION get_revenue_by_localities()
RETURNS TABLE(localidad VARCHAR(100), total_recaudado FLOAT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT l.nombre AS localidad, SUM(tf.valor) AS total_recaudado
    FROM viajes v
    JOIN tarifas tf ON v.tarifa_id = tf.tarifa_id
    JOIN estaciones e ON v.estacion_abordaje_id = e.estacion_id
    JOIN localidades l ON e.localidad_id = l.localidad_id
    GROUP BY l.nombre;
END;
$$;
