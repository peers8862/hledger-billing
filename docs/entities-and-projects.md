# Entities & Projects

## Entities

An entity is a billing identity — the company or sole proprietorship that appears on your invoices. You might have one, or several.

### Creating your first entity

```bash
consult init
```

This walks you through:
- Company name and business number
- Contact info (email, phone)
- Default currency and tax rate
- Invoice numbering prefix
- hledger journal file path
- hledger account names (receivable, income, tax liability, bank)
- Invoice template (optional)

### Adding more entities

```bash
consult entity add
```

Same prompts. Each entity gets its own invoice counter and can point to a different hledger journal.

### Listing and editing

```bash
consult entity list
consult entity edit clairlea
```

Edit walks through each field showing the current value. Press enter to keep it.

### Entity config fields

| Field | Purpose |
|-------|---------|
| `name` | Appears on invoices |
| `business_number` | Tax registration (HST, GST, VAT, etc.) |
| `email` | Contact on invoice |
| `phone` | Contact on invoice |
| `payment_terms` | e.g., "Net 30 days" |
| `currency` | Default for projects under this entity |
| `tax` | Default tax % for projects |
| `invoice_prefix` | Prepended to invoice numbers (e.g., "CLR-") |
| `next_invoice` | Auto-incremented counter |
| `journal_file` | Where hledger `include` is managed |
| `template` | Invoice template filename (in `templates/`) |
| `accounts` | hledger account name mapping |

### Account mapping

Each entity defines how transactions map to your chart of accounts:

```yaml
accounts:
  receivable: "Assets:Accounts Receivable"
  income: "Income:Consulting"
  tax_liability: "Liabilities:HST Payable"
  bank: "Assets:Chequing"
```

The client name is appended to the receivable account automatically:
`Assets:Accounts Receivable:Cibby Alexandar`

---

## Projects

A project links a client to an entity. It defines who you're billing, at what rate, in what currency.

### Creating a project

```bash
consult project new
```

You'll specify:
- **Entity** — which company is billing
- **Project slug** — short identifier (e.g., `acme-website`)
- **Client name** — appears on invoice
- **Project name** — appears on invoice
- **Currency** — for this project
- **Tax %** — default for entries
- **Rate type** — daily or hourly
- **Rate amount** — and effective date
- **Journal file override** — if different from entity default
- **Template override** — if different from entity default

### Rate types

**Daily rate with hours:**
```
Daily rate: 239
Hours per day: 7.5
→ Effective hourly: $31.87/h
```
Billing is always hours × effective hourly rate. The daily rate is the contractual reference point.

**Hourly rate:**
```
Hourly rate: 50
```
Straightforward multiplication.

### Rate history

Rates are stored with effective dates. The system looks up which rate applies based on the entry date:

```yaml
rates:
  - from: 2026-01-01
    daily_rate: 239.00
  - from: 2026-07-01
    daily_rate: 275.00
```

Update with:
```bash
consult rate acme-website
```

Old rates are never deleted — they're needed to correctly resolve entries logged against earlier dates.

### Project config file

Stored in `projects/<slug>.yaml`:

```yaml
entity: clairlea
client: Cibby Alexandar
project: YUPI dot CA
currency: CAD
tax: 13
rate_type: daily
hours_per_day: 7.5
active: true
template: null
rates:
  - from: 2026-01-01
    daily_rate: 239.00
```

### Active/inactive projects

Projects are `active: true` by default. To mark one inactive, edit the YAML directly and set `active: false`. Inactive projects won't appear in default lists (future enhancement).
