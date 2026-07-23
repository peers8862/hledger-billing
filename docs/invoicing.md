# Invoicing

## Generating an invoice

```bash
consult invoice
```

### The flow

1. **Select project** — defaults to last-used
2. **Review entries** — shows all unbilled billable entries for that project
3. **Select entries** — include all, none, or pick specific ones
4. **Set invoice number** — auto-incremented from entity counter
5. **Set invoice date** — defaults to today
6. **Add notes** — optional freeform text on the PDF
7. **Review totals** — taxable, exempt, tax, grand total
8. **Confirm** — generates everything

### Example session

```
Project [johnny-demo-comp]: ↵

Unbilled billable entries for Johnny Smith / Demo-Comp dot CA (CAD):

  #    Date          Hours     Rate Focus                          Tax
  ---- ----------   ------ -------- ------------------------------ -------
  1    2026-06-23     4.00    31.87 Frontend migration             13%
  2    2026-06-24     6.00    31.87 Backend API work               13%
  3    2026-06-27     1.75    31.87 Emergency fix                  13%
  4    2026-06-28     1.25    36.67 Rush work                      13%
  5    2026-06-29     4.50    31.87 API documentation              exempt

Include all? (Y/n/select) [Y]: select
Entry numbers (e.g. 1-3,5,7): 1-3,5

Invoice number [2026-002]: ↵
Invoice date [2026-07-15]: ↵
Invoice notes (optional): Covers sprint 4

Summary:
  Taxable subtotal:  $374.97 CAD
  Tax (13%):          $48.75 CAD
  Exempt subtotal:   $143.42 CAD
  ───────────────────────────────────
  Total due:         $567.14 CAD

Generate? (Y/n): ↵

✓ output/invoice-2026-002.pdf
✓ invoices/2026/2026-002.journal
✓ Entries archived to timesheets/billed/2026-002.yaml
```

### Entry selection

- **Y** — include all shown entries
- **n** — cancel
- **select** — pick by number. Supports:
  - Single numbers: `1,3,5`
  - Ranges: `1-5`
  - Mixed: `1-3,5,7-9`

Entries not selected remain in unbilled for the next invoice.

---

## What gets generated

### 1. PDF invoice (`output/invoice-<number>.pdf`)

A professional invoice rendered via Typst from your template. Contains:
- Entity header (your company, business number, contact)
- Client and project info
- Line items table (date, hours, rate, amount, description)
- Tax breakdown (supports multiple rates and exempt items)
- Total due
- Payment terms
- Optional notes

### 2. hledger journal (`invoices/<year>/<number>.journal`)

```
2026-07-15 * Invoice 2026-002  ; invoice:2026-002, client:Johnny Smith, project:Demo-Comp dot CA, entity:clairlea
    Assets:Accounts Receivable:Johnny Smith         CAD 567.14
    Income:Consulting                                  CAD -518.39
    Liabilities:HST Payable                            CAD -48.75
```

Tags on the transaction make it queryable:
```bash
hledger reg tag:invoice=2026-002
hledger reg tag:client="Johnny Smith"
hledger bal tag:entity=clairlea
```

### 3. Invoice record (`timesheets/billed/<number>.yaml`)

Metadata used by `consult paid` and `consult outstanding`:

```yaml
invoice: 2026-002
entity: clairlea
client: Johnny Smith
project_slug: johnny-demo-comp
date: 2026-07-15
currency: CAD
subtotal: 518.39
tax: 48.75
total: 567.14
status: outstanding
payments: []
entries: [...]
```

### 4. Template data (`build/<number>.yaml`)

Intermediate YAML passed to the Typst template. Useful for debugging template issues.

---

## Tax handling

### Per-entry tax

Each entry carries its own tax value (inherited from project default, overridable at log time):
- A number like `13` → 13% applied
- `0` → no tax (but still in the "taxable" category technically)
- `exempt` → excluded from tax calculation entirely

### Multiple tax rates on one invoice

If entries have different tax rates, the invoice calculates each group separately:

```
Taxable (13%):  $400.00   → Tax: $52.00
Taxable (5%):   $100.00   → Tax: $5.00
Exempt:         $50.00
───────────────────────────
Total:          $607.00
```

### No tax

If an entity has no business number and tax is 0, the tax liability line is omitted from the hledger journal entirely.

---

## Invoice numbering

Each entity has its own counter in `config.yaml`:

```yaml
entities:
  clairlea:
    invoice_prefix: ""
    next_invoice: 2026-003
  other-co:
    invoice_prefix: "MM-"
    next_invoice: 2026-001
```

The counter auto-increments after each invoice. Format is `YYYY-NNN` with zero-padded sequence. The prefix is prepended: `MM-2026-001`.

---

## hledger include management

On first invoice for a given year/entity, the system checks whether your journal file already includes the invoices directory. If not:

```
Add 'include invoices/2026/*.journal' to ~/accounting/journal.hledger? (Y/n):
```

The glob means subsequent invoices are picked up automatically without editing the journal again.
