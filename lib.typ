#let invoice(
  title: [請求書],
  date: auto,
  invoice-number-series: 1,
  due-date: datetime(year: 2025, month: 12, day: 31),
  recipient: (
    name: [◯◯株式会社],
    postal-ccode: [123-4567],
    address: [◯◯県△△市□□町1-2-3],
  ),
  issuer: (
    name: [田中 太郎],
    postal-ccode: [321-6543],
    address: [△△県◯◯市□□町3-2-1],
  ),
  account: (
    bank: [◯◯銀行],
    branch: [△△支店],
    number: [1234567],
    holder: [タナカ タロウ],
  ),
  items: (
    (
      name: [サービス名],
      amount: 5,
      unit: [時間],
      price: 2000,
    ),
  ),
  min-item-rows: 8,
  tax-rate: 0.1,
  body,
) = {
  set document(title: title)
  set page(paper: "a4", numbering: none)
  set text(font: "Harano Aji Mincho", size: 10pt, weight: "regular", lang: "ja")
  set par(justify: true, leading: 0.8em)

  show table.cell.where(y: 0): set text(fill: white)
  set table(
    fill: (_, row) => if row == 0 { black } else if calc.rem(row, 2) == 1 { white } else { silver },
    stroke: (x, y) => (
      top: if y <= 1 { 0pt } else { 0pt },
      bottom: if y == 0 { 0pt } else { 1pt + black },
      left: 0pt,
      right: 0pt,
    ),
  )

  let format-number(number) = {
    let s = str(number)
    let result = ""
    let len = s.len()
    for i in range(len) {
      result += s.at(i)
      if calc.rem(len - 1 - i, 3) == 0 and (len - 1 - i) > 0 {
        result += ","
      }
    }
    result
  }

  if date == auto {
    date = datetime.today()
  }
  let subtotal = items.map(it => it.price * it.amount).sum(default: 0)
  let tax = subtotal * tax-rate
  let total = subtotal + tax

  // Contents
  context {
    show heading.where(level: 1): set text(size: 1.5em, weight: "regular")
    heading(title, level: 1)
  }
  v(1em)
  grid(
    columns: (4fr, 3fr),
    {
      par(text(size: 1.2em, recipient.name + " 御中"))
      [
        〒 #recipient.postal-ccode \
        #recipient.address
      ]
      v(2em)
      [
        下記の通りご請求申し上げます。
      ]
      v(0.1em)
      table(
        columns: (auto, auto, auto),
        inset: (x: 1.5em, y: 0.5em),
        table.header(
          [小計], [消費税], [合計金額],
        ),
        [#format-number(subtotal) 円], [#format-number(tax) 円], [#format-number(total) 円],
      )
      v(0.1em)
      grid(
        columns: (auto, auto),
        rows: (1.6em, auto),
        column-gutter: 1em,
        [振込期限], due-date.display("[year]年[month]月[day]日"),
        [振込先], [
          銀行名: #account.bank \
          支店名: #account.branch \
          口座番号: #account.number \
          口座名義: #account.holder
        ],
      )
    },
    {
      grid(
        columns: (auto, 1fr),
        rows: (2em, auto),
        align: (left, right),
        [日付:], date.display("[year]年[month]月[day]日"),
        [請求書番号:], date.display("[year][month][day]") + "-" + str(invoice-number-series),
      )
      v(1em)
      par(text(size: 1.2em, issuer.name))
      [
        〒 #issuer.postal-ccode \
        #issuer.address
      ]
    }
  )
  table(
    columns: (1fr, auto, auto, auto),
    inset: (x: 1.5em, y: 0.5em),
    table.header(
      [詳細], [数量], [単価], [金額]
    ),
    ..{
      let item-rows = ()
      for item in items {
        item-rows.push((
          item.name,
          {
            let unit = item.at("unit", default: none)
            str(item.amount) + (if unit != none { " " + unit } else { "" } )
          },
          format-number(item.price) + " 円",
          format-number(item.amount * item.price) + " 円",
        ))
      }
      while item-rows.len() < min-item-rows {
        item-rows.push(([ #sym.space.nobreak ], [ #sym.space.nobreak ], [ #sym.space.nobreak ], [ #sym.space.nobreak ]))
      }
      item-rows.flatten()
    },
  )
  v(1em)
  line(length: 100%, stroke: 1pt + silver)
  [備考欄]
  pad(left: 0.5em, body)
}
