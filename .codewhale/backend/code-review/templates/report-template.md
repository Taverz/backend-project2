# Code Review Report

> Template. When generating, replace `{{variables}}` with real values. Remove the
> instructional comments at the top and bottom from the final report. Sections with
> empty lists — keep the section, mark `_(none)_`.

**Branch:** `{{current_branch}}` → `{{base_branch}}`
**Merge-base:** `{{merge_base_short_sha}}`
**Date:** {{date_iso}}
**Mode:** `{{mode}}` (default = A+B+C+codex; quick = A+C)
**Files reviewed:** {{files_reviewed}} ({{files_skipped}} skipped: generated/lock/assets)
**Lines:** +{{lines_added}} / -{{lines_removed}}
**Streams:** A=`{{model_A}}`, B=`{{model_B}}`, C=`{{model_C}}` (naive)
**Cross-model (codex):** {{codex_status}}
**Run ID:** `{{run_id}}` ([manifest](../.runs/{{run_id}}/manifest.json))

## Run Integrity

This report was gated by `validate-run.sh` (all invariants passed). Evidence:

| Check | Status |
|-------|--------|
| Phase 1 D1 asked | {{d1_method}} |
| CLAUDE.md read | {{claude_md_read_status}} |
| Docs read | {{docs_read_count}} file(s): `{{docs_read_list}}` |
| Validation | lint={{lint_status}}, analyzer={{analyzer_status}}, tests={{tests_status}} |
| Stream A dispatched | {{stream_a_count}} specialists on `{{model_A}}` |
| Stream B dispatched | {{stream_b_count}} specialists on `{{model_B}}` |
| Stream C dispatched | {{stream_c_count}} naive researcher on `{{model_C}}` |
| Codex | {{codex_attempted_summary}} |
| Synthesis | {{synthesis_status}} (task `{{synthesis_task_id}}`) |

> If any of these say "missing" or look wrong, the validator failed and you
> should not trust this report. Re-run `/code-review` from scratch.

---

## Summary

| Severity | Count |
|----------|------:|
| 🚨 Blocker | {{blocker_count}} |
| 🔴 Critical | {{critical_count}} |
| 🟡 Major | {{major_count}} |
| 🟢 Minor | {{minor_count}} |
| ℹ️ Info | {{info_count}} |
| _suppressed_ | {{suppressed_count}} |

## Cross-Stream Synthesis

| Bucket | Count | What it means |
|--------|------:|---------------|
| ✅ Consensus (≥3 sources) | {{consensus_count}} | High-confidence findings — multiple independent reviewers raised the same issue |
| ⚖️ Majority (2 sources) | {{majority_count}} | Solid signal but worth verifying — see the source columns |
| 🔍 Unique (1 source) | {{unique_count}} | Single-source findings — verify before fixing; some are real, some hallucinations |
| ⚠️ Disagreement | {{disagreement_count}} | One reviewer flagged it, another explicitly cleared it — read carefully |
| 🕵️ Research discrepancies | {{discrepancy_count}} | Same file covered by multiple streams, only one flagged — see Appendix E |

### Cross-Stream Agreement Matrix

Each row is a finding; each column is whether that source raised it. Reading
across each row tells you *who* believes the finding is real.

| Finding | A | B | C | codex | Bucket | Confidence |
|---------|:-:|:-:|:-:|:-----:|--------|:----------:|
{{#agreement_matrix}}
| [{{anchor_upper}}]({{anchor}}) — {{title}} | {{a_mark}} | {{b_mark}} | {{c_mark}} | {{codex_mark}} | {{bucket}} | {{adjusted_confidence}}/10 |
{{/agreement_matrix}}

### Validation

| Check | Status | Details |
|-------|--------|---------|
| Linter | {{lint_status}} | {{lint_summary}} |
| Analyzer | {{analyzer_status}} | {{analyzer_summary}} |
| Tests | {{tests_status}} | {{tests_summary}} |

{{#validation_failed}}
> ⚠️ **Heads-up:** validation failed before review started. Details in Appendix B.
> Some findings below may be downstream of the failing build, not real bugs.
{{/validation_failed}}

### Top 3 to fix first

1. {{top_1}}
2. {{top_2}}
3. {{top_3}}

---

## Table of Contents

### 🚨 Blocker ({{blocker_count}})

{{#blockers}}
- [B-{{nn}}: {{title}}](#b-{{nn}}) — `{{path}}:{{line}}`
{{/blockers}}
{{^blockers}}
_(no findings at this level)_
{{/blockers}}

### 🔴 Critical ({{critical_count}})

{{#criticals}}
- [C-{{nn}}: {{title}}](#c-{{nn}}) — `{{path}}:{{line}}`
{{/criticals}}
{{^criticals}}
_(no findings at this level)_
{{/criticals}}

### 🟡 Major ({{major_count}})

{{#majors}}
- [M-{{nn}}: {{title}}](#m-{{nn}}) — `{{path}}:{{line}}`
{{/majors}}
{{^majors}}
_(no findings at this level)_
{{/majors}}

### 🟢 Minor ({{minor_count}})

{{#minors}}
- [N-{{nn}}: {{title}}](#n-{{nn}}) — `{{path}}:{{line}}`
{{/minors}}
{{^minors}}
_(no findings at this level)_
{{/minors}}

### ℹ️ Info ({{info_count}})

{{#infos}}
- [I-{{nn}}: {{title}}](#i-{{nn}}) — `{{path}}:{{line}}`
{{/infos}}
{{^infos}}
_(no findings at this level)_
{{/infos}}

---

## Findings

> Each finding is a separate `<details>` section. Blockers are open by default,
> the rest collapsed. Click the heading to expand.

{{#findings}}
<details id="{{anchor}}" {{#is_blocker}}open{{/is_blocker}}>
<summary><strong>{{anchor_upper}} — [{{severity}}]</strong> {{title}} — <code>{{path}}{{#line}}:{{line}}{{/line}}</code></summary>

**Specialist:** {{specialist}}
**Stream coverage:** {{coverage_label}}  <!-- e.g. "A + B + codex" or "C only (naive)" -->
**Bucket:** {{bucket}}  <!-- consensus | majority | unique -->
**Confidence:** {{adjusted_confidence}}/10 (raw {{confidence}}, {{calibration_note}})
{{#verify_needed}}**⚠ Verify before fixing:** single-source finding{{/verify_needed}}
**Category:** `{{category}}`
**Fingerprint:** `{{fingerprint}}`

### What

{{summary}}

### Why it matters

{{why}}

### Where

```{{file_lang}}
// {{path}}{{#line}}:{{line}}{{/line}}
{{code_snippet}}
```

### How to fix

{{fix}}

{{#references}}
### References

{{#refs}}
- {{.}}
{{/refs}}
{{/references}}

</details>

{{/findings}}

---

## Appendix A: Suppressed Findings (low confidence)

These were below the confidence gate and not included in the main report. They may
be false positives — but if you confirm them, the next review's calibration will
boost them.

<details>
<summary>Show {{suppressed_count}} suppressed findings</summary>

{{#suppressed}}
- **{{specialist}}** | confidence {{confidence}}/10 | `{{path}}{{#line}}:{{line}}{{/line}}` — {{title}}
  > {{summary}}
{{/suppressed}}
{{^suppressed}}
_(no suppressed findings)_
{{/suppressed}}

</details>

---

## Appendix B: Validation Output

### Linter

<details>
<summary>{{lint_status}} — {{lint_summary}} ({{lint_duration_s}}s)</summary>

```
{{lint_output_tail}}
```

</details>

### Analyzer

<details>
<summary>{{analyzer_status}} — {{analyzer_summary}} ({{analyzer_duration_s}}s)</summary>

```
{{analyzer_output_tail}}
```

</details>

### Tests

<details>
<summary>{{tests_status}} — {{tests_summary}} ({{tests_duration_s}}s)</summary>

```
{{tests_output_tail}}
```

</details>

---

## Appendix C: Diff Summary

<details>
<summary>Files changed ({{files_reviewed}})</summary>

| File | +/- | Layer | Tags |
|------|-----|-------|------|
{{#diff_files}}
| `{{path}}` | +{{added}}/-{{removed}} | {{layer}} | {{tags}} |
{{/diff_files}}

</details>

<details>
<summary>Commits on the branch ({{commits_count}})</summary>

```
{{commits_log}}
```

</details>

---

## Appendix D: Calibration

After the review you can confirm or reject findings — that improves the accuracy of
future reviews. Answers are recorded in `~/.claude/code-review/calibration.jsonl`.

| Finding | Status |
|---------|--------|
{{#calibration_rows}}
| {{anchor_upper}} | {{verdict}} |
{{/calibration_rows}}

---

## Appendix E: Research Discrepancies & Disagreements

This section surfaces *places where the streams disagreed about the same code*.
These are the highest-information moments in the report — they're where one
reviewer was wrong (hallucination) or another was blind (miss).

### Disagreements ({{disagreement_count}})

A disagreement is a *positive* counter-claim: one stream raised an issue, another
stream explicitly stated the same code is fine.

{{#disagreements}}
- **`{{path}}{{#line}}:{{line}}{{/line}}`** — {{title}}
  - {{stream_for}} says: _{{claim_for}}_
  - {{stream_against}} says: _{{claim_against}}_
  - **Read first:** {{recommendation}}
{{/disagreements}}
{{^disagreements}}
_(no disagreements detected — streams converged on every flagged issue)_
{{/disagreements}}

### Research discrepancies ({{discrepancy_count}})

A discrepancy is a *coverage gap*: same file/line was in scope for multiple streams,
only one flagged it. Either a real catch the others missed, or a hallucination.
The synthesizer cannot tell — only the user can.

{{#discrepancies}}
- **`{{path}}{{#line}}:{{line}}{{/line}}`** — {{title}}
  - Flagged by: **{{flagging_streams}}**
  - Covered (and didn't flag): {{silent_streams}}
  - Type: `{{discrepancy_type}}`
  - **What to check:** open the file at this line and decide. If real → confirm
    the {{flagging_streams}} finding above. If not → mark it false-positive in
    Appendix D so future calibration depresses similar findings.
{{/discrepancies}}
{{^discrepancies}}
_(no research discrepancies detected — coverage was uniform across streams)_
{{/discrepancies}}

---

## Metadata

```json
{
  "generated_at": "{{date_iso}}",
  "branch": "{{current_branch}}",
  "base": "{{base_branch}}",
  "merge_base": "{{merge_base_full_sha}}",
  "specialists": {{specialists_json}},
  "codex_used": {{codex_used_bool}},
  "duration_s": {{total_duration_s}},
  "report_version": "1.0.0"
}
```

---

_Report auto-generated by the `/code-review` skill. Don't edit this file — it will be
overwritten on the next run. Keep your own notes in the Git PR description or a
sibling `.md`._
