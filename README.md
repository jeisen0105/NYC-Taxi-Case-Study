# NYC Fleet Optimization: Recovering $33.5M via Predictive Routing
### **A Big Data Case Study in Network Efficiency & Economic Recovery**

## Executive Summary
This project identifies a **$113.7M revenue leakage** within NYC fleet operations caused by reactive routing inefficiencies. Using **Google BigQuery** to analyze millions of rows of data sourced from the **official NYC TLC record**, I developed a data-driven proposal to capture **$33.5M** of that leakage through a **100% self-liquidating pilot model**. 

By shifting from individual "selfish" GPS routing to a coordinated network-layer approach, this analysis provides the financial and geospatial roadmap to increase the fleet's performance floor.

---

## The Technical Pipeline (10-Step SQL Suite)
The repository is organized into a modular SQL pipeline designed for high-scale processing and audit-grade financial transparency.

### **Phase 1: Data Engineering & Benchmarking**
* **`01_data_cleaning.sql`**: Enforces financial integrity, validates official TLC codes, and handles time-series outliers.
* **`02_citywide_benchmarking.sql`**: Establishes the **$1.64 RPM (Revenue Per Minute)** "Gold Standard" using `APPROX_QUANTILES` for statistical median extraction.
* **`03_distribution_histogram.sql`**: Discretizes data into $0.10 bins to visualize the "Heavy Right-Tail" efficiency distribution.

### **Phase 2: Economic Quantization**
* **`04_opportunity_cost_modeling.sql`**: Quantifies the **$113.7M revenue hole** using vectorized conditional math to calculate trip-by-trip variance.
* **`05_revenue_reconciliation.sql`**: Reconciles **Operational Revenue** ($766M+) against driver tips to ensure accurate enterprise-grade auditing.

### **Phase 3: Geospatial & Tactical Intelligence**
* **`06_geospatial_zone_mapping.sql`**: Integrates **NYC Taxi Zone Shapefiles** using `ST_ASGEOJSON` to map "Efficiency Cold Spots" at the neighborhood level.
* **`07_tactical_segmentation.sql`**: Prioritizes the **Top 10 (Funding Hubs)** and **Bottom 10 (Recovery Zones)** based on volume and efficiency.



### **Phase 4: Pilot Design & Financial Scaling**
* **`08_pilot_baseline_audit.sql`**: Uses **Correlated Subqueries and String Concatenation** to establish the pre-intervention revenue baseline for 10 specific temporal-spatial segments.
* **`09_phase1_financial_proforma.sql`**: Models a **Dual-Stream income model** (Surcharges + Efficiency Gains) using **Common Table Expressions (CTEs)**.
* **`10_phase2_network_scaling.sql`**: Extrapolates the **5% efficiency floor** across the entire network to validate the **$33.5M recovery target**.

---

## Strategic Methodology
* **Opportunity Cost Modeling:** I utilized a `CASE` statement to calculate the variance between actual trip performance and the **$1.65 RPM benchmark**, identifying that **14.84%** of total revenue is currently lost to avoidable delays.
* **Surgical Segmentation:** By filtering for high-volume segments (minimum **100k trips/year**), the pilot ensures statistical significance for the proposed coordination layer.
* **Self-Funding Logic:** The model transitions from a **self-funded pilot ($1.13M capital)**—generated via a temporary $0.99 surcharge in high-efficiency hubs—to a full-scale expansion.

---

## Key Results & Impact
* **Annual Revenue Recovery:** $33.5M (Projected at a conservative 5% efficiency gain).
* **Financial Impact:** $18.5M Net Profit in Year 1.
* **Projected ROI:** 235% Recurring ROI by Year 2.
* **Capital Requirement:** $0 Net Cost (100% self-liquidating model).

---

## Repository Structure
```bash
├── sql_scripts/            # 10-File SQL Pipeline (BigQuery SQL)
├── strategy_report/        # NYC_Fleet_Optimization_Strategy.pdf
├── visualizations/         # Histograms & Geospatial Performance Maps
└── README.md               # Technical Case Study & Documentation
