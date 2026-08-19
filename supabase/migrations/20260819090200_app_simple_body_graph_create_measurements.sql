-- App: simple-body-graph (schema: app_simple_body_graph)
-- Body measurements, one row per user per date.
create table app_simple_body_graph.measurements (
    id uuid primary key,
    date date not null,
    waist numeric(5, 2),
    chest numeric(5, 2),
    arms numeric(5, 2),
    thighs numeric(5, 2),
    user_id uuid references auth.users(id) default auth.uid() not null,
    created_at timestamptz default timezone('utc'::text, now()) not null
);

alter table app_simple_body_graph.measurements enable row level security;

create policy "Users read their own measurements"
on app_simple_body_graph.measurements for select
using (auth.uid() = user_id);

create policy "Users insert their own measurements"
on app_simple_body_graph.measurements for insert
with check (auth.uid() = user_id);

create policy "Users update their own measurements"
on app_simple_body_graph.measurements for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users delete their own measurements"
on app_simple_body_graph.measurements for delete
using (auth.uid() = user_id);

grant select, insert, update, delete on app_simple_body_graph.measurements to authenticated;
