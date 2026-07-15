# consult

A command-line billing system for consultants built around [hledger](https://hledger.org). Log time, generate invoices as PDFs, and keep your books in plain text.

## What it does

- Interactive time logging with per-entry rate, tax, type, and tags
- Invoice generation: produces both a PDF (via Typst) and an hledger journal entry
- Payment tracking with aging reports
- Multi-entity support (bill through different companies)
- Rate history per project (rate changes are tracked by date)
- Automatic `include` management for your hledger journal

## Requirements

- Python 3.8+
- [PyYAML](https://pyyaml.org/) (`pip install pyyaml`)
- [hledger](https://hledger.org/install.html)
- [Typst](https://typst.app/) (for PDF generation)

## Install

```bash
git clone <repo-url> hledger-billing
cd hledger-billing
chmod +x consult
ln -s "$(pwd)/consult" ~/.local/bin/consult
```

## Quick start

```bash
consult init              # first-time setup
consult project new       # create a client project
consult log               # log time (daily use)
consult invoice           # generate invoice
consult paid              # record payment
```

## Commands

| Command | Description |
|---------|-------------|
| `consult init` | First-time setup — entity, accounts, journal path |
| `consult entity add` | Add another billing entity |
| `consult entity list` | List all entities |
| `consult entity edit <slug>` | Edit entity details |
| `consult project new` | Create a client project |
| `consult project list` | List all projects |
| `consult rate <project>` | Add a new rate effective from a date |
| `consult log` | Log time interactively |
| `consult log --batch` | Batch log multiple entries |
| `consult log edit` | Edit a previous entry |
| `consult status` | Show unbilled summary per project |
| `consult invoice` | Generate invoice (PDF + hledger journal) |
| `consult paid` | Record payment received |
| `consult outstanding` | Show unpaid invoices with aging |
| `consult export` | Export entries to CSV |
| `consult undo` | Remove last log entry |

## Documentation

- [Entities & Projects](docs/entities-and-projects.md) — setting up billing identities and client projects
- [Time Logging](docs/time-logging.md) — daily logging, batch entry, types, and tags
- [Invoicing](docs/invoicing.md) — generating invoices, tax handling, partial selection
- [Templates](docs/templates.md) — customizing invoice PDFs, per-entity and per-project templates
- [Payments & Reporting](docs/payments-and-reporting.md) — tracking payments, aging, CSV export

## File structure

```
hledger-billing/
├── consult                 # CLI script
├── config.yaml             # your config (gitignored)
├── config.example.yaml     # reference schema
├── projects/               # project configs (gitignored)
├── timesheets/
│   ├── unbilled.yaml       # pending entries (gitignored)
│   └── billed/             # archived per invoice (gitignored)
├── invoices/               # hledger journals (gitignored)
├── output/                 # generated PDFs (gitignored)
├── build/                  # intermediate data for templates (gitignored)
├── templates/
│   └── invoice.typ         # default Typst template
├── docs/                   # documentation
└── README.md
```

## How it fits with hledger

Your main hledger journal stays yours — household expenses, income, whatever you track. This tool generates `.journal` files that your main file pulls in via `include`:

```
include ~/path/to/hledger-billing/invoices/2026/*.journal
```

The tool manages this automatically on first invoice generation.

## License

MIT
