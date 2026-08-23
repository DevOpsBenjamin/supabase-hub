-- App: simple-body-graph (schema: app_simple_body_graph)
-- add ble fields to logs

alter table app_simple_body_graph.logs
    add column if not exists measured_at timestamptz,
    add column if not exists heart_rate numeric(3, 0),
    add column if not exists impedances jsonb,
    add column if not exists scale_device_id text;


