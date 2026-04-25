// =============================================================================
// Purpose : Helper function — derive fiscal year, fiscal quarter, and fiscal
//           month number from a calendar date.
// Source  : Called by the Calendar query.
// Depends : Nothing (standalone function).
// Notes   : GFV fiscal year starts 1 July (month 7).  FY2024 = Jul-2023 to Jun-2024.
//           Returns a record with fields: FiscalYear, FiscalQuarter, FiscalMonth.
// =============================================================================

let
    fnFiscalPeriod = (dateValue as date, fiscalYearStartMonth as number) as record =>
        let
            CalMonth       = Date.Month(dateValue),
            CalYear        = Date.Year(dateValue),

            // Fiscal month: 1 = first month of FY (July for GFV)
            FiscalMonth    = Number.Mod(CalMonth - fiscalYearStartMonth + 12, 12) + 1,

            // Fiscal year label: the calendar year in which the FY ends
            FiscalYear     = if CalMonth >= fiscalYearStartMonth
                             then CalYear + 1
                             else CalYear,

            // Fiscal quarter: Q1 = months 1-3 of the fiscal year
            FiscalQuarter  = Number.RoundUp(FiscalMonth / 3)
        in
            [
                FiscalYear    = FiscalYear,
                FiscalQuarter = FiscalQuarter,
                FiscalMonth   = FiscalMonth
            ]
in
    fnFiscalPeriod
