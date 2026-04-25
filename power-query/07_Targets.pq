// =============================================================================
// Purpose : Build FactTargets — monthly revenue targets by region.
// Source  : {pDataFolder}/targets.csv  (288 rows: 8 regions × 36 months)
// Depends : fnCleanText
// Notes   : TargetDate is the first day of each month.  The relationship to
//           Calendar is one-to-many at month granularity:
//               Calendar[Date] → FactTargets[TargetDate]
//           This means only rows where Calendar[Date] = first-of-month will
//           match; use CALCULATE with STARTOFMONTH or filter to month-grain
//           visuals to avoid double-counting.
//           Region values must exactly match DimCustomers[Region] for
//           cross-filtering to work correctly.
// =============================================================================

let
    // ── Source ────────────────────────────────────────────────────────────────
    pDataFolder        = "C:\GFV\data\",   // replace with your pDataFolder parameter

    RawCsv             = Csv.Document(
                             File.Contents(pDataFolder & "targets.csv"),
                             [Delimiter = ",", Columns = 3, Encoding = 65001,
                              QuoteStyle = QuoteStyle.Csv]
                         ),

    PromoteHeaders     = Table.PromoteHeaders(RawCsv, [PromoteAllScalars = true]),

    // ── Explicit types ────────────────────────────────────────────────────────
    SetTypes           = Table.TransformColumnTypes(PromoteHeaders, {
                             {"TargetDate",     type date},
                             {"Region",         type text},
                             {"RevenueTarget",  type number}
                         }),

    // ── Clean text ────────────────────────────────────────────────────────────
    CleanRegion        = Table.TransformColumns(SetTypes, {
                             {"Region", fnCleanText, type text}
                         }),

    // ── Derived: year-month key for convenience slicing ───────────────────────
    AddYearMonth       = Table.AddColumn(CleanRegion, "TargetYearMonth",
                             each Date.Year([TargetDate]) * 100 + Date.Month([TargetDate]),
                             Int64.Type),

    AddYearMonthLabel  = Table.AddColumn(AddYearMonth, "TargetYearMonthLabel",
                             each Date.ToText([TargetDate], "MMM yyyy"),
                             type text),

    // ── Sort chronologically then by region ───────────────────────────────────
    SortRows           = Table.Sort(AddYearMonthLabel, {
                             {"TargetDate", Order.Ascending},
                             {"Region",     Order.Ascending}
                         })
in
    SortRows
