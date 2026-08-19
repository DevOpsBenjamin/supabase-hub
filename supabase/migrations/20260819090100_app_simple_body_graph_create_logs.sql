-- App: simple-body-graph (schema: app_simple_body_graph)
-- Weight and body fat log, one row per user per date.
--
-- Squashed from the app repo's own migrations: the is_sick column was added and
-- dropped there before this repo existed, so it never appears here.
create table app_simple_body_graph.logs (
    id uuid primary key,
    date date not null,
    mass numeric(5, 2) not null,
    body_fat numeric(4, 2) not null,
    user_id uuid references auth.users(id) default auth.uid() not null,
    created_at timestamptz default timezone('utc'::text, now()) not null
);

alter table app_simple_body_graph.logs enable row level security;

create policy "Users read their own logs"
on app_simple_body_graph.logs for select
using (auth.uid() = user_id);

create policy "Users insert their own logs"
on app_simple_body_graph.logs for insert
with check (auth.uid() = user_id);

create policy "Users update their own logs"
on app_simple_body_graph.logs for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users delete their own logs"
on app_simple_body_graph.logs for delete
using (auth.uid() = user_id);

grant select, insert, update, delete on app_simple_body_graph.logs to authenticated;
