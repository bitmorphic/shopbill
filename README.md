# Shop Billing System
**Subject:** System Programming CSLB 154 - PROF DR.BISWAJIT SIR

A web-based shop billing system that demonstrates basic arithmetic operations
(item amount, GST, grand total) using x86 Assembly language concepts,
with a clean working user interface built in HTML, CSS, and JavaScript.


---

## Features

- Add items with name, price, and quantity
- Automatic item amount calculation (price × quantity)
- Running subtotal across all items
- GST (18%) calculated automatically
- Grand Total = Subtotal + GST
- Remove individual items from the bill
- Clear the entire bill with one click
- Print a clean bill
- Today's date auto-filled on the bill

---

## Assembly Language (billing.asm)

The file `billing.asm` is written in **NASM x86 32-bit** assembly language.
It contains four functions that mirror the JavaScript billing logic:

| Function | Assembly Instructions | Purpose |
|---|---|---|
| `calc_item_amount` | `MOV`, `IMUL`, `RET` | price × quantity |
| `add_to_subtotal` | `ADD`, `MOV`, `RET` | running total |
| `calc_gst` | `IMUL`, `XOR`, `DIV`, `RET` | (subtotal × 18) / 100 |
| `calc_grand_total` | `ADD`, `MOV`, `RET` | subtotal + GST |


---

project will be live here `https://gentle-hotteok-759e56.netlify.app/` 
