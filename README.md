# E-Commerce SQL Data Analysis & Optimization

An advanced SQL analytical portfolio project demonstrating operational business intelligence, customer lifetime metrics, and database performance tuning.

## Key Highlights & Insights

1. **Customer RFM Segmentation:** Classified customer base into High-Value VIP, Loyal, Regular, and New segments using multi-condition aggregation and `CASE` evaluation.
2. **Category Performance (Window Functions):** Tracked the top 3 revenue-driving products per category utilizing `DENSE_RANK() OVER (PARTITION BY ...)`.
3. **Month-over-Month (MoM) Growth:** Calculated historical financial velocity and revenue deltas using Common Table Expressions (CTEs) combined with `LAG()`.
4. **Performance Tuning:** Implemented B-Tree indexing across foreign key constraints and frequent filter predicates (`order_date`), measuring cost reduction via `EXPLAIN ANALYZE`.

##  Tech Stack & Skills
- **Dialect:** MySQL / PostgreSQL
- **Key Techniques:** Common Table Expressions (CTEs), Window Functions (`DENSE_RANK`, `LAG`), Aggregations, Conditional Partitioning, Execution Plan Analysis.

##  Repository Structure
- `ecommerce_analysis.sql`: Complete DDL schema design, sample data queries, analytical reports, and index creation.
