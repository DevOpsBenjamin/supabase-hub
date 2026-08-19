# Seeds

Local-only fixtures, applied by `supabase db reset` in the order `config.toml`
globs them. One file per app, named after the app slug: `simple-body-graph.sql`.

Never seed anything the remote project needs; migrations own everything real.
