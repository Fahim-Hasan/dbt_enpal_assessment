# Contributing

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
- Prefer a real dbt/`dbt_utils`/`dbt_expectations` test over a bespoke singular one when an
  existing generic test already expresses the check — reach for a new macro-backed generic test
  only when the logic is genuinely bespoke (e.g. the two above).

## Semantic layer

```bash
docker compose exec dbt mf validate-configs
docker compose exec dbt mf query --metrics deals_count --group-by metric_time__month,funnel_step,funnel_step__kpi_name
```

See `models/semantic/` for the semantic model/metric definitions.
