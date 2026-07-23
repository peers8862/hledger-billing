# Time Logging

## Interactive logging

```bash
consult log
```

The prompts:

```
Project [last-used]: ↵
Date [2026-07-15]: ↵
Hours: 4
Focus: Frontend migration
Type [billable]: ↵
Tags (comma-separated, optional): sprint-4, react
Rate [31.87/h from 239/day]: ↵
Tax [13%]: ↵
✓ Logged.

Add another? [y/n]:
```

### Fields

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| Project | yes | last used | Project slug |
| Date | yes | today | YYYY-MM-DD |
| Hours | yes | — | Decimal hours (e.g., 4, 2.5, 0.75) |
| Focus | yes | — | What you worked on |
| Type | yes | `billable` | See below |
| Tags | no | none | Comma-separated labels |
| Rate | yes | from project | Effective hourly rate |
| Tax | yes | from project | Percentage or "exempt" |

### Rate resolution

When you're prompted for rate, the system:
1. Looks at the project's rate history
2. Finds the rate entry active on your entry's date
3. Computes effective hourly (for daily rates: daily ÷ hours_per_day)
4. Shows it as the default

If no rate exists for the date (entry predates all rate history), you'll get an error and must enter a rate manually.

You can override for any single entry by typing a number instead of pressing enter.

### Tax override

Default comes from the project config. Override per-entry:
- Type a number for a different percentage: `5`
- Type `exempt` for tax-free items

---

## Batch logging

For catching up on multiple days at once:

```bash
consult log --batch
```

```
Project [johnny-demo-comp]: ↵
Type for all entries [billable]: ↵
Tax % for all entries [13]: ↵

Enter lines (DATE HOURS FOCUS):
  2026-07-07 4 Frontend migration
  2026-07-08 6.5 Backend API
  2026-07-09 3 Code review
.
✓ Logged 3 entries (13.5h)
```

Format per line: `DATE HOURS FOCUS`

- Date must be YYYY-MM-DD
- Hours is a number
- Focus is everything after the second space
- Type and tax are set once for the whole batch
- Rate is auto-resolved per entry from the project's rate history
- End with `.` or Ctrl+D

---

## Entry types

The `type` field categorizes how you spent time. Only `billable` entries appear on invoices.

| Type | On invoice? | Purpose |
|------|-------------|---------|
| `billable` | ✓ | Client-facing work |
| `research` | ✗ | Investigation, R&D |
| `prep` | ✗ | Setup, learning, preparation |
| `admin` | ✗ | Emails, scheduling |
| `internal` | ✗ | Your own business overhead |
| (any custom) | ✗ | Whatever you define |

Rules:
- Default is `billable`
- Must be lowercase letters and hyphens only
- Must start and end with a letter
- Free-form — use whatever categories make sense for you

Non-billable entries are tracked for your own visibility. `consult status` shows a breakdown:

```
Project: johnny-demo-comp (Johnny Smith / Demo-Comp dot CA)
  billable      17.50h  →  $557.67
  research       3.00h   (not billed)
  prep           2.25h   (not billed)
  total         22.75h
```

---

## Tags

Optional labels for filtering and reporting. Comma-separated at entry time:

```
Tags: sprint-4, react, urgent
```

Uses:
- Filter at invoice time: include only entries with specific tags
- Filter in export: `consult export --tag sprint-4`
- Group line items on invoices by tag (future enhancement)

---

## Editing entries

### Undo last entry

```bash
consult undo
```

Shows the last entry and confirms before removing it.

### Edit any entry

```bash
consult log edit
```

Shows your recent entries (last 20), you pick one by number, then walk through each field with the current value as default. Press enter to keep, or type a new value.

---

## Storage

Entries are stored in `timesheets/unbilled.yaml`:

```yaml
entries:
  - project: johnny-demo-comp
    date: 2026-07-15
    hours: 4.0
    focus: Frontend migration
    type: billable
    tags: [sprint-4, react]
    rate: 31.87
    tax: 13
```

After invoicing, entries move to `timesheets/billed/<invoice-number>.yaml`.
