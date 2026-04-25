// =============================================================================
// Purpose : Build DimCustomers from the customers.csv source file.
// Source  : {pDataFolder}/customers.csv  (20 B2B customers across 8 regions)
// Depends : fnCleanText
// Notes   : OnboardedDate is kept as a date — the DAX calculated column
//           CohortYear (05_calculated_columns.dax) derives YEAR() from it.
//           Channel values: Direct | Distributor | E-commerce | Wholesale.
// =============================================================================

let
    // ── Source ────────────────────────────────────────────────────────────────
    pDataFolder        = "C:\GFV\data\",   // replace with your pDataFolder parameter

    RawCsv             = Csv.Document(
                             File.Contents(pDataFolder & "customers.csv"),
                             [Delimiter = ",", Columns = 6, Encoding = 65001,
                              QuoteStyle = QuoteStyle.Csv]
                         ),

    PromoteHeaders     = Table.PromoteHeaders(RawCsv, [PromoteAllScalars = true]),

    // ── Explicit types ────────────────────────────────────────────────────────
    SetTypes           = Table.TransformColumnTypes(PromoteHeaders, {
                             {"CustomerID",    type text},
                             {"CustomerName",  type text},
                             {"Region",        type text},
                             {"Channel",       type text},
                             {"Country",       type text},
                             {"OnboardedDate", type date}
                         }),

    // ── Clean text columns ────────────────────────────────────────────────────
    CleanText          = Table.TransformColumns(SetTypes, {
                             {"CustomerName", fnCleanText, type text},
                             {"Region",       fnCleanText, type text},
                             {"Country",      fnCleanText, type text}
                         }),

    // ── Derived: tenure in full years as of today ─────────────────────────────
    AddTenureYears     = Table.AddColumn(CleanText, "TenureYears",
                             each Number.RoundDown(
                                 Duration.TotalDays(DateTime.LocalNow() - DateTime.From([OnboardedDate])) / 365.25
                             ), Int64.Type),

    // ── Sort ──────────────────────────────────────────────────────────────────
    SortByRegion       = Table.Sort(AddTenureYears, {{"Region", Order.Ascending}, {"CustomerName", Order.Ascending}})
in
    SortByRegion
