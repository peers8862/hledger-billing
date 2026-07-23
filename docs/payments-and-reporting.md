# Payments & Reporting

## Recording payments

```bash
consult paid
```

Shows your outstanding invoices and lets you pick one:

```
Outstanding invoices:

  1. 2026-001  Johnny Smith / Demo-Comp dot CA   $630.23 CAD   (45 days)
  2. 2026-002  Johnny Smith / Demo-Comp dot CA   $567.14 CAD   (15 days)
  3. MM-2026-001  Other Client / Widget        $750.00 USD   (10 days)

Which invoice? 1
Payment date [2026-07-15]: ↵
Amount received [$630.23]: ↵
Deposited to account [Assets:Chequing]: ↵

✓ Recorded $630.23 CAD payment for 2026-001. ✓ Fully paid
```

### What happens

1. Updates the invoice record (`timesheets/billed/<number>.yaml`) with the payment
2. Writes a payment journal entry to `invoices/<year>/<number>-payment.journal`
3. Marks as paid if total payments ≥ invoice total

### Partial payments

If a client pays less than the full amount, just enter the partial amount:

```
Amount received [$630.23]: 300
✓ Recorded $300 CAD payment for 2026-001. $330.23 remaining
```

The invoice stays in "outstanding" with a reduced balance. Run `consult paid` again when the rest arrives.

### Generated journal entry

```
2026-08-10 * Payment received 2026-001  ; invoice:2026-001, client:Johnny Smith
    Assets:Chequing                                    CAD 630.23
    Assets:Accounts Receivable:Johnny Smith         CAD -630.23
```

---

## Outstanding invoices

```bash
consult outstanding
```

Shows all unpaid invoices grouped by age:

```
Outstanding: $1947.37

  Current (0-30 days):
    2026-002       Johnny Smith           $    567.14 CAD  (15d)
    MM-2026-001    Other Client              $    750.00 USD  (10d)

  30+ days:
    2026-001       Johnny Smith           $    630.23 CAD  (45d)

  60+ days:

  90+ days ⚠:
```

Partial payments are reflected — shows remaining balance, not original total.

---

## Status (unbilled summary)

```bash
consult status
```

Shows what you've logged but haven't invoiced yet, grouped by project and type:

```
johnny-demo-comp — Johnny Smith / Demo-Comp dot CA (CAD)
  billable      17.50h  →  $557.73
  research       3.00h   (not billed)
  total         22.75h

acme-website — Acme Corp / Website Rebuild (USD)
  billable       8.00h  →  $400.00
  total          8.00h
```

---

## CSV export

```bash
consult export [flags]
```

Outputs CSV to stdout. Pipe to a file or other tools:

```bash
consult export > timesheet.csv
consult export --project johnny-demo-comp > johnny-hours.csv
```

### Flags

| Flag | Example | Description |
|------|---------|-------------|
| `--project` | `--project johnny-demo-comp` | Filter by project slug |
| `--from` | `--from 2026-01-01` | Entries on or after date |
| `--to` | `--to 2026-06-30` | Entries on or before date |
| `--tag` | `--tag sprint-4` | Only entries with this tag |
| `--type` | `--type research` | Only entries of this type |
| `--all` | `--all` | Include billed entries too |

Flags combine (AND logic):
```bash
consult export --project johnny-demo-comp --from 2026-06-01 --to 2026-06-30 --type billable
```

### CSV columns

```
project, date, hours, rate, amount, type, tax, focus, tags
```

Tags are semicolon-separated within the column.

### Typical uses

Send a timesheet to a client:
```bash
consult export --project johnny-demo-comp --from 2026-06-01 --type billable > june-timesheet.csv
```

Analyze your own time allocation:
```bash
consult export --all --type research > research-hours.csv
```

See all work for a tag:
```bash
consult export --all --tag sprint-4
```

---

## Querying via hledger

Since all invoices and payments are valid hledger journals, you can query them directly:

```bash
# All consulting income
hledger -f ~/accounting/journal.hledger bal Income:Consulting

# Accounts receivable (who owes you)
hledger -f ~/accounting/journal.hledger bal "Assets:Accounts Receivable"

# All activity for a specific client
hledger -f ~/accounting/journal.hledger reg tag:client="Johnny Smith"

# Invoices by entity
hledger -f ~/accounting/journal.hledger reg tag:entity=clairlea

# Monthly income report
hledger -f ~/accounting/journal.hledger bal Income:Consulting --monthly
```

These work because the generated journals use hledger tags on every transaction.
