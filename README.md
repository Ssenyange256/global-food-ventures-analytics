# Global Food Ventures — Sales & Operations Analytics

A portfolio Power BI analytics project demonstrating a clean, production-style pipeline for a multi-region food distribution business. Every piece of logic lives in plain text files — **Power Query M** for data shaping, **DAX** for analytics — so the work reads like code, not clicks.

![Built with Power BI](https://img.shields.io/badge/Built%20with-Power%20BI-F2C811?logo=powerbi&logoColor=black)
![M language](https://img.shields.io/badge/Power%20Query-M-blue)
![DAX](https://img.shields.io/badge/Model-DAX-4A90E2)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Table of contents

1. [Business context](#business-context)
2. [What this project shows](#what-this-project-shows)
3. [Repository layout](#repository-layout)
4. [Data model](#data-model)
5. [Getting started](#getting-started)
6. [Power Query pipeline](#power-query-pipeline)
7. [DAX measure library](#dax-measure-library)
8. [Sample insights you can build](#sample-insights-you-can-build)
9. [Roadmap](#roadmap)
10. [Author](#author)

---

## Business context

**Global Food Ventures (GFV)** sources African specialty foods — coffee, spices, flours, oils, nuts, sauces — and sells them through four channels (Direct, Distributor, E-commerce, Wholesale) to retail, wholesale, and export customers across East, West, Southern and North Africa, the Middle East, Europe, North America, and Oceania.

Leadership needs one consistent view of **how revenue, margin, and shipping performance are tracking against monthly regional targets**, sliceable by product, brand, customer, and channel.

This repository is the analytical backbone for that view. It contains the raw sample data, the Power Query scripts that build the model, and the DAX that powers every visual.

## What this project shows

- A **star schema** designed for VertiPaq and business-friendly slicing.
- Clean, commented **Power Query M** with reusable helper functions.
- A fully documented **DAX measure library**, grouped by purpose.
- **Fiscal calendar** logic built from scratch (GFV's FY starts in July).
- **Target-vs-actual** variance, attainment %, and colour helpers for conditional formatting.
- Separation of concerns: all cleanup happens in Power Query, all analytics in DAX — never both.

## Repository layout

```
global-food-ventures-analytics/
├── README.md                     <- you are here
├── LICENSE
├── .gitignore
├── data/
│   ├── products.csv              <- 25 SKUs across 7 categories
│   ├── customers.csv             <- 20 B2B customers, 8 regions
│   ├── sales.csv                 <- 2,720 order lines (2023-2025)
│   └── targets.csv               <- monthly regional revenue targets
├── power-query/
│   ├── 01_fnCleanText.pq         <- helper: normalise text columns
│   ├── 02_fnFiscalPeriod.pq      <- helper: fiscal year/quarter/month
│   ├── 03_Calendar.pq            <- Calendar dimension (built from scratch)
│   ├── 04_Products.pq            <- DimProducts
│   ├── 05_Customers.pq           <- DimCustomers
│   ├── 06_Sales.pq               <- FactSales (incl. COGS merge)
│   └── 07_Targets.pq             <- FactTargets
├── dax/
│   ├── 01_core_measures.dax
│   ├── 02_time_intelligence.dax
│   ├── 03_targets_and_attainment.dax
│   ├── 04_customer_and_product.dax
│   └── 05_calculated_columns.dax
├── docs/
│   ├── data-model.md             <- schema, relationships, why star
│   ├── power-query-guide.md      <- conventions, load order, swapping source
│   └── dax-guide.md              <- naming, formatting, best practices
└── images/
    └── (add dashboard screenshots here)
```

## Data model

```
              +----------------+
              |   Calendar     |
              +----------------+
                      |
                      | 1..*
                      v
+----------------+  +----------------+  +----------------+
|  DimProducts   |--|   FactSales    |--|  DimCustomers  |
+----------------+  +----------------+  +----------------+
                      |         ^
                      | *..1    | 1..*  (inactive, ShipDate)
                      v         |
              +----------------+|
              |  FactTargets   |+
              +----------------+
```

See [`docs/data-model.md`](docs/data-model.md) for grain, cardinalities, and the reason each relationship is set the way it is.

## Getting started

1. **Clone the repo**

   ```bash
   git clone https://github.com/<your-username>/global-food-ventures-analytics.git
   cd global-food-ventures-analytics
   ```

2. **Point Power BI at the data** — by default the M scripts read from `C:\GFV\data\`. Either copy the CSVs there or open each `.pq` file and replace that path with your own. (Better: create a Power BI parameter named `pDataFolder` and reference it.)

3. **Create the queries in Power BI Desktop**, in this order:
   1. `01_fnCleanText.pq`   → New Blank Query → paste → rename to **fnCleanText**
   2. `02_fnFiscalPeriod.pq` → same, name it **fnFiscalPeriod**
   3. `03_Calendar.pq` → name it **Calendar**
   4. `04_Products.pq` → name it **DimProducts**
   5. `05_Customers.pq` → name it **DimCustomers**
   6. `06_Sales.pq` → name it **FactSales**  (depends on DimProducts)
   7. `07_Targets.pq` → name it **FactTargets**

4. **Mark `Calendar` as a date table** — Model view → right-click Calendar → Mark as date table → Date column = `Date`.

5. **Build the relationships** per the diagram above. The `ShipDate → Calendar[Date]` relationship must be set to **inactive**.

6. **Paste the DAX measures** from each `.dax` file into Power BI (or Tabular Editor). Apply the format strings listed in [`docs/dax-guide.md`](docs/dax-guide.md).

7. **Build your report pages.** Suggested starting points are in the [Sample insights](#sample-insights-you-can-build) section below.

## Power Query pipeline

Every `.pq` file is a single `let … in` expression with a consistent structure:

- A comment block documenting **Purpose / Source / Depends / Notes**.
- An explicit `Table.TransformColumnTypes` step — no auto-generated "Changed Type" noise.
- Meaningful step names so the Applied Steps list reads like a narrative.
- Reusable logic extracted into `fnCleanText` and `fnFiscalPeriod`.

See [`docs/power-query-guide.md`](docs/power-query-guide.md) for load order, conventions, and how to swap the file source for a SQL or API source without changing the downstream model.

## DAX measure library

| File                                 | What's inside                                    |
|--------------------------------------|--------------------------------------------------|
| `01_core_measures.dax`               | Revenue, COGS, margin, units, AOV                |
| `02_time_intelligence.dax`           | YTD, PY, YoY, MoM, rolling 3/12, ship-date view  |
| `03_targets_and_attainment.dax`      | Variance, attainment %, colour-coding helpers    |
| `04_customer_and_product.dax`        | New customers, concentration, ranking, lead time |
| `05_calculated_columns.dax`          | Model-side columns (used sparingly)              |

Naming, variable style, and format strings are documented in [`docs/dax-guide.md`](docs/dax-guide.md).

## Sample insights you can build

With the measures in this repo you can immediately produce:

- **Executive scorecard** — Total Revenue, Gross Margin %, Attainment %, YoY growth, Active Customers.
- **Regional target tracker** — Region on rows, month on columns, attainment % in cells with the `Attainment Colour` conditional format.
- **Product profitability matrix** — Category and SubCategory with Units Sold, Revenue, Gross Margin %, and the `MarginBand` calculated column.
- **Customer concentration view** — Top-5 customer revenue share (`Customer Concentration Top 5`) and tenure-band breakdown.
- **Operations panel** — Average Lead Time, On-Time Ship %, Revenue by Ship Date, by Channel and ShipMode.

## Roadmap

- [ ] Add a `.pbip` project file so the whole report is source-controllable.
- [ ] Wire the pipeline to an Azure SQL source using parameters.
- [ ] Add row-level security (RLS) for regional managers.
- [ ] Publish a Power BI service report and link screenshots here.
- [ ] Add incremental refresh policies for FactSales.

## Author

**Derrick Ssenyange** — Global Food Ventures
Email: [derrick@globalfoodventures.com](mailto:derrick@globalfoodventures.com)

_Contributions, issues, and feedback are welcome — open a pull request or raise an issue._
