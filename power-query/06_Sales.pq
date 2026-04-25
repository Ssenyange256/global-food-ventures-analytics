// =============================================================================
// Purpose : Build FactSales — the central fact table for all revenue, cost,
//           and operations analysis.
// Source  : {pDataFolder}/sales.csv  (2,720 order lines, 2023-2025)
// Depends : fnCleanText, DimProducts (merged to bring in UnitMarginPct for
//           cross-checking; final COGS comes from the CSV directly)
// Notes   : GrossMargin is included as a pre-computed column so IsProfitableLine
//           (DAX calculated column) can evaluate it without a measure dependency.
//           ShipDate → Calendar relationship is inactive in the model; activate
//           via USERELATIONSHIP in the DAX measure "Revenue by Ship Date".
// =============================================================================

let
    // ── Source ────────────────────────────────────────────────────────────────
    pDataFolder        = "C:\GFV\data\",   // replace with your pDataFolder parameter

    RawCsv             = Csv.Document(
                             File.Contents(pDataFolder & "sales.csv"),
                             [Delimiter = ",", Columns = 13, Encoding = 65001,
                              QuoteStyle = QuoteStyle.Csv]
                         ),

    PromoteHeaders     = Table.PromoteHeaders(RawCsv, [PromoteAllScalars = true]),

    // ── Explicit types ────────────────────────────────────────────────────────
    SetTypes           = Table.TransformColumnTypes(PromoteHeaders, {
                             {"OrderID",      type text},
                             {"CustomerID",   type text},
                             {"ProductID",    type text},
                             {"OrderDate",    type date},
                             {"ShipDate",     type date},
                             {"Quantity",     Int64.Type},
                             {"GrossRevenue", type number},
                             {"DiscountPct",  type number},
                             {"NetRevenue",   type number},
                             {"COGS",         type number},
                             {"GrossMargin",  type number},
                             {"LeadTimeDays", Int64.Type},
                             {"ShipMode",     type text}
                         }),

    // ── Clean the only free-text column ───────────────────────────────────────
    CleanShipMode      = Table.TransformColumns(SetTypes, {
                             {"ShipMode", fnCleanText, type text}
                         }),

    // ── Derived: order year-month key (matches Calendar[YearMonth]) ───────────
    AddYearMonth       = Table.AddColumn(CleanShipMode, "OrderYearMonth",
                             each Date.Year([OrderDate]) * 100 + Date.Month([OrderDate]),
                             Int64.Type),

    // ── Sort chronologically ──────────────────────────────────────────────────
    SortByDate         = Table.Sort(AddYearMonth, {{"OrderDate", Order.Ascending}})
in
    SortByDate
