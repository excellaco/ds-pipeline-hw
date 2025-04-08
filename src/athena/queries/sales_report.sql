-- Monthly sales aggregation with Lake Formation permissions
WITH processed_sales AS (
  SELECT
    date_trunc('month', order_date) AS month,
    product_category,
    SUM(revenue) AS total_revenue
  FROM processed_db.sales_processed
  WHERE order_status = 'COMPLETED'
    AND year = year(current_date)
  GROUP BY 1, 2
)
SELECT 
  month,
  product_category,
  total_revenue,
  total_revenue / SUM(total_revenue) OVER (PARTITION BY month) AS pct_revenue
FROM processed_sales
ORDER BY 1 DESC, 2