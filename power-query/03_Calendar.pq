// =============================================================================
// Purpose : Build the Calendar dimension from scratch — no external source.
// Source  : Generated in-memory from pCalendarStart to pCalendarEnd.
// Depends : fnFiscalPeriod
// Notes   : Mark this table as a Date Table in Power BI Model view using the
//           [Date] column.  The table contains contiguous dates with no gaps.
//           Fiscal year starts in July (month 7) per GFV convention.
// =============================================================================

let
    // ── Parameters ────────────────────────────────────────────────────────────
    StartDate          = #date(2023, 1, 1),
    EndDate            = #date(2025, 12, 31),
    FYStartMonth       = 7,

    // ── Date list ─────────────────────────────────────────────────────────────
    DateCount          = Duration.Days(EndDate - StartDate) + 1,
    DateList           = List.Dates(StartDate, DateCount, #duration(1, 0, 0, 0)),
    DateTable          = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}),

    // ── Base calendar columns ─────────────────────────────────────────────────
    SetDateType        = Table.TransformColumnTypes(DateTable, {{"Date", type date}}),

    AddYear            = Table.AddColumn(SetDateType,    "Year",            each Date.Year([Date]),            Int64.Type),
    AddMonthNum        = Table.AddColumn(AddYear,        "MonthNumber",     each Date.Month([Date]),           Int64.Type),
    AddMonthName       = Table.AddColumn(AddMonthNum,    "MonthName",       each Date.ToText([Date], "MMMM"),  type text),
    AddMonthShort      = Table.AddColumn(AddMonthName,   "MonthShort",      each Date.ToText([Date], "MMM"),   type text),
    AddQuarter         = Table.AddColumn(AddMonthShort,  "Quarter",         each "Q" & Text.From(Date.QuarterOfYear([Date])), type text),
    AddQuarterNum      = Table.AddColumn(AddQuarter,     "QuarterNumber",   each Date.QuarterOfYear([Date]),   Int64.Type),
    AddWeekNum         = Table.AddColumn(AddQuarterNum,  "WeekNumber",      each Date.WeekOfYear([Date]),      Int64.Type),
    AddDayOfWeek       = Table.AddColumn(AddWeekNum,     "DayOfWeek",       each Date.ToText([Date], "dddd"),  type text),
    AddDayOfWeekNum    = Table.AddColumn(AddDayOfWeek,   "DayOfWeekNumber", each Date.DayOfWeek([Date], Day.Monday) + 1, Int64.Type),
    AddIsWeekend       = Table.AddColumn(AddDayOfWeekNum,"IsWeekend",       each Date.DayOfWeek([Date], Day.Monday) >= 5, type logical),

    // ── Year-Month helper (used for relationships with FactTargets) ───────────
    AddYearMonth       = Table.AddColumn(AddIsWeekend,   "YearMonth",       each Date.Year([Date]) * 100 + Date.Month([Date]), Int64.Type),
    AddYearMonthLabel  = Table.AddColumn(AddYearMonth,   "YearMonthLabel",  each Date.ToText([Date], "MMM yyyy"), type text),

    // ── Fiscal columns ────────────────────────────────────────────────────────
    AddFiscal          = Table.AddColumn(AddYearMonthLabel, "FiscalPeriod",
                             each fnFiscalPeriod([Date], FYStartMonth)),
    AddFiscalYear      = Table.AddColumn(AddFiscal,      "FiscalYear",
                             each "FY" & Text.From([FiscalPeriod][FiscalYear]),  type text),
    AddFiscalYearNum   = Table.AddColumn(AddFiscalYear,  "FiscalYearNumber",
                             each [FiscalPeriod][FiscalYear],                    Int64.Type),
    AddFiscalQuarter   = Table.AddColumn(AddFiscalYearNum,"FiscalQuarter",
                             each "Q" & Text.From([FiscalPeriod][FiscalQuarter]), type text),
    AddFiscalMonth     = Table.AddColumn(AddFiscalQuarter,"FiscalMonthNumber",
                             each [FiscalPeriod][FiscalMonth],                   Int64.Type),

    // ── Drop the intermediate record column ───────────────────────────────────
    DropFiscalRecord   = Table.RemoveColumns(AddFiscalMonth, {"FiscalPeriod"}),

    // ── Final column order ─────────────────────────────────────────────────────
    ReorderColumns     = Table.ReorderColumns(DropFiscalRecord, {
                             "Date", "Year", "MonthNumber", "MonthName", "MonthShort",
                             "Quarter", "QuarterNumber", "WeekNumber",
                             "DayOfWeek", "DayOfWeekNumber", "IsWeekend",
                             "YearMonth", "YearMonthLabel",
                             "FiscalYear", "FiscalYearNumber", "FiscalQuarter", "FiscalMonthNumber"
                         })
in
    ReorderColumns
