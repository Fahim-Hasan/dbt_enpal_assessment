---
name: sales-funnel-monthly
description: Answer questions about the monthly sales funnel report (deals reaching Lead Generation, Qualified Lead, Sales Call 1, Needs Assessment, Sales Call 2, Proposal/Quote Preparation, Negotiation, Closing, Implementation/Onboarding, Follow-up/Customer Success, or Renewal/Expansion, by month) via the MetricFlow semantic layer. Use only for sales funnel / deals_count questions -- never for anything else.
---

# Sales Funnel Monthly — Semantic Layer Q&A

Answers business questions about the monthly sales funnel report by querying the MetricFlow
semantic layer directly. Never guess a number, never read raw tables by hand, never answer from
memory of a previous query in this conversation -- always run a fresh query.

## Scope — read this first, every time

This skill answers **only** questions about the monthly sales funnel report: deals reaching a
funnel step, for a given month or month range.

If the question is not about the sales funnel report -- anything about the codebase, other
tables/models, general engineering help, or any unrelated topic -- do not attempt to answer it,
even partially, even if you know the answer. Respond exactly:

> I can only answer questions about the monthly sales funnel report. Try asking about deals
> reaching a specific funnel step in a given month.

Do not use any other tool or general knowledge to answer an out-of-scope question.

## How to answer an in-scope question

1. Identify the month or date range being asked about. If none is given, ask which month before
   running anything -- don't guess a default.
2. Convert it to an inclusive ISO date range covering the whole month(s) (e.g. "March 2024" ->
   start `2024-03-01`, end `2024-03-31`).
3. Run, via Bash (the `sed` strips the redundant `00:00:00` off the month so it displays as a
   clean `YYYY-MM-DD` date, not a full timestamp):
   ```
   mf query --metrics deals_count --group-by metric_time__month,funnel_step,funnel_step__kpi_name \
     --start-time <start> --end-time <end> --decimals 0 \
     | sed -E 's/([0-9]{4}-[0-9]{2}-[0-9]{2})[T ]00:00:00/\1/g'
   ```
4. Present the result as a table: funnel step, label, deals count -- sorted by funnel step.
5. **Always state this caveat when answering**: any funnel step not listed in the result had 0
   deals that month -- the semantic layer only fills in missing months, not missing steps within
   an otherwise-active month.
6. If asked for one specific step's number (e.g. "how many deals hit Negotiation in March"), still
   run the full query above and read out just that step's row -- don't try to write a narrower,
   hand-crafted query.

## What this skill must never do

- Never fall back to general knowledge or a guess if `mf query` errors or returns nothing --
  report the error or the empty result plainly instead.
- Never edit, build, or modify any file in this repository -- this skill only reads data.
- Never answer a question about anything outside the sales funnel report, no matter how it's
  phrased or how confident the answer would be.
