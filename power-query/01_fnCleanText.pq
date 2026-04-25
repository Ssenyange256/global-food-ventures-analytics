// =============================================================================
// Purpose : Helper function — normalise text columns before loading into the model.
// Source  : Called by DimProducts, DimCustomers, FactSales, FactTargets.
// Depends : Nothing (standalone function).
// Notes   : Trims leading/trailing whitespace, collapses internal runs of
//           whitespace to a single space, and title-cases the result.
//           Pass null-safe: if the input is null the function returns null.
// =============================================================================

let
    fnCleanText = (inputText as nullable text) as nullable text =>
        let
            NullGuard      = if inputText = null then null else inputText,
            Trimmed        = if NullGuard = null then null else Text.Trim(NullGuard),
            CollapseSpaces = if Trimmed  = null then null
                             else Text.Combine(
                                     List.Select(Text.Split(Trimmed, " "), each _ <> ""),
                                     " "
                                 ),
            TitleCased     = if CollapseSpaces = null then null
                             else Text.Proper(CollapseSpaces)
        in
            TitleCased
in
    fnCleanText
