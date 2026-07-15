// invoice.typ - Default invoice template for consult
// Reads data from a YAML file passed via --input data=path/to/file.yaml

#let data = yaml(sys.inputs.data)

#let entity = data.entity
#let line_items = data.line_items
#let currency = data.currency

#set page(
  paper: "us-letter",
  margin: (top: 18mm, bottom: 18mm, left: 20mm, right: 20mm),
)

#set text(size: 10pt)
#set par(leading: 0.55em)

// ─── Header ─────────────────────────────────────────────────────────────────

#grid(
  columns: (1fr, 1fr),

  [
    #text(size: 18pt, weight: "bold")[#entity.name]

    #if entity.business_number != none [
      Business \#: #entity.business_number
    ]

    #if entity.email != none [#entity.email] \
    #if entity.phone != none [#entity.phone]
  ],

  align(right)[
    #text(size: 26pt, weight: "bold")[INVOICE]

    Invoice: #data.invoice_number \
    Date: #data.invoice_date
  ],
)

#v(0.3cm)
#line(length: 100%)
#v(0.5cm)

// ─── Bill To / Terms ────────────────────────────────────────────────────────

#grid(
  columns: (1fr, 1fr),

  [
    #text(weight: "bold")[BILL TO]

    #data.client

    Project: #data.project
  ],

  [
    #text(weight: "bold")[PAYMENT TERMS]

    #entity.payment_terms
  ],
)

#v(0.7cm)

// ─── Line Items ─────────────────────────────────────────────────────────────

#text(size: 13pt, weight: "bold")[Services Provided]
#v(0.3cm)

#{
  let header = ([*Date*], [*Hours*], [*Rate*], [*Amount*], [*Description*])

  let rows = ()
  for item in line_items {
    let amount_str = "\$" + str(calc.round(item.amount, digits: 2))
    let rate_str = "\$" + str(calc.round(item.rate, digits: 2))
    let tax_note = if item.tax == "exempt" { " †" } else { "" }
    rows.push((
      [#item.date],
      [#str(calc.round(item.hours, digits: 2))],
      [#rate_str],
      [#amount_str#tax_note],
      [#item.focus],
    ))
  }

  table(
    columns: (auto, auto, auto, auto, 1fr),
    inset: 5pt,
    stroke: 0.5pt,
    ..header,
    ..rows.flatten(),
  )
}

#if data.exempt_subtotal > 0 [
  #text(size: 8pt, style: "italic")[† exempt from tax]
]

#v(0.7cm)

// ─── Totals ─────────────────────────────────────────────────────────────────

#align(right)[
  #{
    let total_rows = ()

    let subtotal = data.taxable_subtotal + data.exempt_subtotal
    total_rows.push(([Subtotal:], [\$#str(calc.round(subtotal, digits: 2)) #currency]))

    if data.exempt_subtotal > 0 {
      total_rows.push(([#h(1em) _Taxable:_], [\$#str(calc.round(data.taxable_subtotal, digits: 2))]))
      total_rows.push(([#h(1em) _Exempt:_], [\$#str(calc.round(data.exempt_subtotal, digits: 2))]))
    }

    for tb in data.tax_breakdown {
      let label = "Tax (" + str(tb.percent) + "%):"
      total_rows.push(([#label], [\$#str(calc.round(tb.tax, digits: 2))]))
    }

    total_rows.push((
      [#text(weight: "bold")[TOTAL DUE:]],
      [#text(weight: "bold", size: 12pt)[\$#str(calc.round(data.grand_total, digits: 2)) #currency]],
    ))

    table(
      columns: (auto, auto),
      stroke: none,
      inset: (x: 8pt, y: 4pt),
      ..total_rows.flatten(),
    )
  }
]

// ─── Notes ──────────────────────────────────────────────────────────────────

#if data.notes != none [
  #v(0.5cm)
  #line(length: 100%)
  #v(0.3cm)
  #text(weight: "bold")[Notes]

  #data.notes
]

// ─── Footer ─────────────────────────────────────────────────────────────────

#v(1fr)
#line(length: 100%)
#v(0.2cm)
#text(size: 9pt)[
  Thank you for your business. \
  #entity.name
  #if entity.business_number != none [| Business \#: #entity.business_number]
]
