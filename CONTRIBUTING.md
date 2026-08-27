# Contributing

## Project layout

```
models/
  staging/       one model per raw source table -- rename/cast, canonicalize strings, no business logic
  intermediate/  one folder per fact pipeline -- reconstructs entities from the raw event logs, unfiltered
  marts/
    dimensions/  dim_deals__funnel_steps, dim_activity_types, dim_users, dim_deals__lost_reasons, dim_dates
    facts/       fct_deals__funnel, fct_deals__activity, fct_deals__latest_snapshot
    reporting/   rep_sales_funnel_monthly -- the required deliverable, materialized and fully dense
  semantic/      MetricFlow semantic models + the deals_count metric, for ad hoc mf query self-service
macros/          one macro per centralized mapping/validity rule, reused across models and tests
.claude/skills/  a Claude Code skill answering sales-funnel questions via the semantic layer
```

See `CLAUDE.md` for the full decision log — why each layer looks the way it does, every bug found
and fixed, and what's deliberately deferred.

## Getting started

```bash
docker compose up -d              # postgres (healthchecked) + one-shot CSV loader + dbt container
docker compose exec dbt dbt deps
docker compose exec dbt pre-commit install   # one-time; wires the git hooks below into commit
```

Or open the repo in the provided dev container — `dbt deps && pre-commit install && dbt build`
runs automatically on first create.

## Before committing

`pre-commit` runs automatically on `git commit` once installed, but you can run it manually:

```bash
pre-commit run --all-files
```

This covers: standard hygiene (trailing whitespace, EOF, merge conflicts), `sqlfluff-lint` on
every model, and `dbt-checkpoint` checks that every model has a description and at least one test.
`raw_data/` and `init.sql` are excluded from every hook — they belong to the raw data loading
mechanism and are off-limits to modify.

Run the full build and test suite before opening a PR:

```bash
docker compose exec dbt dbt build --select enpal_assessment_project
```

Scope to `enpal_assessment_project` rather than a bare `dbt build` — an unscoped run also pulls in
installed packages' own diagnostic models.

## CI

Every PR runs a full `pre-commit` pass plus a scoped `dbt build --target ci`, selecting changed
models, their ancestors, and their descendants
(`--select "+state:modified+,package:enpal_assessment_project"`, diffed against the manifest
`publish-dbt-state.yml` publishes on every merge to `main`). It intentionally does **not** use
`--defer` — this project's CI Postgres is destroyed and recreated on every run, so there's no
persistent location for a deferred node's data to live at; everything the build actually needs is
built fresh instead. The `ci` profile target runs single-threaded (`threads: 1`, vs. 4 for `dev`)
to avoid Postgres catalog-lock contention observed under concurrent view creation — see
`CLAUDE.md` §§15–16 for the full story, including a fix that turned out not to be the real cause
and was corrected rather than left standing.

## Project structure audit

[`dbt_project_evaluator`](https://github.com/dbt-labs/dbt-project-evaluator) is installed to flag
structural issues (undocumented/untested models, fanned-out sources, naming convention
violations). It's not part of the routine build — run it deliberately when doing an audit:

```bash
docker compose exec dbt dbt build --select package:dbt_project_evaluator
```

## Testing conventions

- Structural tests (`unique`, `not_null`, `relationships`) on every grain-defining key and FK.
- Known, evidenced source-data limitations are encoded as `severity: warn` singular/generic tests
  (see `macros/get_invalid_substep_events.sql`, `macros/get_colliding_deal_ids.sql`, and the tests
  built on top of them) rather than silently worked around — they document a real characteristic
  of the source data and are expected to stay non-zero, not to eventually "pass by getting fixed."
- Prefer a real dbt/`dbt_utils` test over a bespoke singular one when an existing generic test
  already expresses the check — reach for a new macro-backed generic test only when the logic is
  genuinely bespoke (e.g. the two above). `dbt_expectations` (statistical/distributional/regex
  checks beyond dbt_utils) was evaluated and deliberately not adopted for this take-home — noted
  as production-grade future work rather than left installed and unused.
- If a test passes locally but fails in CI (or vice versa) for a reason that isn't obviously a
  real data/logic bug, don't just re-add it once "fixed" — see `CLAUDE.md` §17 for a live example
  of this happening and being parked rather than guessed at further.

## Semantic layer

```bash
docker compose exec dbt mf validate-configs
docker compose exec dbt mf query \
  --metrics deals_count \
  --group-by metric_time__month,funnel_step,funnel_step__kpi_name \
  --decimals 0 \
  | sed -E 's/([0-9]{4}-[0-9]{2}-[0-9]{2})[T ]00:00:00/\1/g'
```

See `models/semantic/` for the semantic model/metric definitions, and `README.md` for the
non-technical-user-facing commands (table view, `--explain`, CSV export).

## The sales-funnel Claude Code Skill

`.claude/skills/sales-funnel-monthly/SKILL.md` lets anyone with `claude` installed ask natural-
language questions about the funnel report, answered live via `mf query`. It's scoped on purpose
— it declines anything not about the sales funnel report rather than answering from general
knowledge. If you extend it, keep that scope instruction; don't let it grow into a general-purpose
assistant for this repo.
