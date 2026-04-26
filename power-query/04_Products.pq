// =============================================================================
// Purpose : Build DimProducts from the products.csv source file.
// Source  : {pDataFolder}/products.csv  (25 SKUs across 7 categories)
// Depends : fnCleanText
// Notes   : UnitMarginPct is kept as a decimal fraction (0.64 = 64 %).
//           MarginBand is added as a calculated column in DAX (05_calculated_columns.dax)
//           because it depends on the model average — do not compute it here.
// =============================================================================

let
    // ── Source ────────────────────────────────────────────────────────────────
    pDataFolder        = "C:\GFV\data\",   // replace with your pDataFolder parameter

    RawCsv             = Csv.Document(
                             File.Contents(pDataFolder & "products.csv"),
                             [Delimiter = ",", Columns = 8, Encoding = 65001,
                              QuoteStyle = QuoteStyle.Csv]
                         ),

    PromoteHeaders     = Table.PromoteHeaders(RawCsv, [PromoteAllScalars = true]),

    // ── Explicit types (no auto-generated "Changed Type" noise) ───────────────
    SetTypes           = Table.TransformColumnTypes(PromoteHeaders, {
                             {"ProductID",      type text},
                             {"ProductName",    type text},
                             {"Category",       type text},
                             {"SubCategory",    type text},
                             {"Brand",          type text},
                             {"UnitPrice",      type number},
                             {"UnitCost",       type number},
                             {"UnitMarginPct",  type number}
                         }),

    // ── Clean text columns ────────────────────────────────────────────────────
    CleanProductName   = Table.TransformColumns(SetTypes, {
                             {"ProductName", fnCleanText, type text},
                             {"Category",    fnCleanText, type text},
                             {"SubCategory", fnCleanText, type text},
                             {"Brand",       fnCleanText, type text}
                         }),

    // ── Derived columns ───────────────────────────────────────────────────────
    AddUnitGrossMargin = Table.AddColumn(CleanProductName, "UnitGrossMargin",
                             each [UnitPrice] - [UnitCost], type number),

    // ── Sort for readability in the model ─────────────────────────────────────
    SortByCategory     = Table.Sort(AddUnitGrossMargin, {{"Category", Order.Ascending}, {"ProductName", Order.Ascending}})
in
    SortByCategory
