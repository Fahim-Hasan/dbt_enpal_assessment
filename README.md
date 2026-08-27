## Setup

### Fastest path — dev container (recommended)

1. Download Docker Desktop (if you don't have it) from the official website, install and launch.
2. Clone this repo to your device, and open it in a dev-container-aware editor (e.g. VS Code with
   the Dev Containers extension).
3. Reopen in the container when prompted (or run "Dev Containers: Reopen in Container"). This
   automatically starts Postgres, loads the raw data, builds every dbt model, and installs the
   git hooks — no manual steps needed.

### Without a dev-container-aware editor

1. Steps 1–2 above.
2. From a terminal, in the repo root: `docker compose up -d` — starts Postgres (healthchecked),
   loads the raw CSVs, and starts a `dbt` service container.
3. `docker compose exec dbt dbt deps`
4. `docker compose exec dbt dbt build --select enpal_assessment_project`

Either way, once setup finishes you have the full staging/intermediate/marts layer built in
Postgres, the required `rep_sales_funnel_monthly` report table, and a working MetricFlow semantic
layer — ready for the commands below.

## Ask the sales funnel report directly (no SQL needed)

Run these inside the `dbt` container (`docker compose exec dbt bash`, or directly if you're
already inside the dev container).

Each command below has `--start-time 2024-03-01 --end-time 2024-03-31` built in — just edit those
two dates to whichever month or range you want (they don't have to be the same month; a wider
range like `--start-time 2024-01-01 --end-time 2024-12-31` shows every month in between).

**1. See the report as a table:**
```bash
mf query \
  --metrics deals_count \
  --group-by metric_time__month,funnel_step,funnel_step__kpi_name \
  --order metric_time__month,funnel_step \
  --start-time 2024-03-01 --end-time 2024-03-31 \
  --decimals 0 \
  | sed -E 's/([0-9]{4}-[0-9]{2}-[0-9]{2})[T ]00:00:00/\1/g'
```

**2. See the exact query behind the numbers:**
```bash
mf query \
  --metrics deals_count \
  --group-by metric_time__month,funnel_step,funnel_step__kpi_name \
  --start-time 2024-03-01 --end-time 2024-03-31 \
  --explain
```

**3. Save the result to a file you can open in Excel/Sheets:**
```bash
mkdir -p output
mf query \
  --metrics deals_count \
  --group-by metric_time__month,funnel_step,funnel_step__kpi_name \
  --order metric_time__month,funnel_step \
  --start-time 2024-03-01 --end-time 2024-03-31 \
  --decimals 0 \
  --csv output/sales_funnel_monthly.csv
sed -i -E 's/([0-9]{4}-[0-9]{2}-[0-9]{2})[T ]00:00:00/\1/g' output/sales_funnel_monthly.csv
```

You can also just open a terminal in this project and run `claude`, then ask directly — e.g.
*"What was the sales funnel for March 2024?"* A Claude Code skill
(`.claude/skills/sales-funnel-monthly/`) answers using this same semantic layer, scoped only to
sales funnel questions.

## Before you read these numbers — what they don't tell you

- **Reaching a stage is not the same as winning the deal.** This data can tell us a deal reached
  a certain point in the pipeline, but there's no way to tell from it whether a deal was ever
  actually won — only whether it was later marked lost. A high number at "Closing" doesn't mean
  those deals succeeded.
- **"Sales Call 1" and "Sales Call 2" always show 0.** Those two numbers would come from a
  separate log of sales activities, but that log doesn't reliably say which deal each call
  actually belongs to. Rather than guess, we only count a call when it can be genuinely verified
  against a real deal — and in this sample, none can be. That's a property of this sample data,
  not a mistake in the report.
- **Almost every deal in this sample eventually ends up "lost."** That's an unusually high number
  for a real business and is most likely a quirk of this being sample/test data, not a real
  signal about performance.
- **A month showing 0 for a step means exactly that — 0 deals reached it that month**, not
  missing or broken data.

## For developers

See [CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow — running tests and lint, the
`dbt_project_evaluator` audit, testing conventions, and the semantic layer's underlying models.

## Project Requirements (Given)

1. Remove the test model once you make sure it works
2. Dive deep into the Pipedrive CRM source data to gain a thorough understanding of all its details. (You may also research the Pipedrive CRM tool terms).
3. Define DBT sources and build the necessary layers organizing the data flow for optimal relevance and maintainability.
4. Build a reporting model (rep_sales_funnel_monthly) with monthly intervals, incorporating the following funnel steps (KPIs):
  &nbsp;&nbsp;&nbsp;Step 1: Lead Generation
  &nbsp;&nbsp;&nbsp;Step 2: Qualified Lead
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Step 2.1: Sales Call 1
  &nbsp;&nbsp;&nbsp;Step 3: Needs Assessment
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Step 3.1: Sales Call 2
  &nbsp;&nbsp;&nbsp;Step 4: Proposal/Quote Preparation
  &nbsp;&nbsp;&nbsp;Step 5: Negotiation
  &nbsp;&nbsp;&nbsp;Step 6: Closing
  &nbsp;&nbsp;&nbsp;Step 7: Implementation/Onboarding
  &nbsp;&nbsp;&nbsp;Step 8: Follow-up/Customer Success
  &nbsp;&nbsp;&nbsp;Step 9: Renewal/Expansion
5. Column names of the reporting model: `month`, `kpi_name`, `funnel_step`, `deals_count`
6. “Git commit” all the changes and create a PR to your forked repo (not the original one). Send your repo link to us.
