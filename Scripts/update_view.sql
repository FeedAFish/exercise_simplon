-- Create views to aggregate sales data
CREATE OR REPLACE VIEW public.sales_by_store AS
SELECT s.id_store, sum(s.sold_nb) as sold_nb
FROM public.sales s
GROUP BY s.id_store
ORDER BY s.id_store;

CREATE OR REPLACE VIEW public.sales_by_product AS
SELECT s.id_ref_product, sum(s.sold_nb) as sold_nb
FROM public.sales s
GROUP BY s.id_ref_product
ORDER BY s.id_ref_product;

CREATE OR REPLACE VIEW public.sales_by_city AS
SELECT st.city, SUM(s.sold_nb) AS sold_nb
FROM public.sales s
JOIN public.stores st ON s.id_store = st.id
GROUP BY st.city
ORDER BY st.city;


-- Calculate turnover
CREATE OR REPLACE VIEW public.turnover AS
SELECT sales.id_ref_product, ROUND(sum(sales.sold_nb * products.price)::numeric, 2) as turnover
FROM sales
JOIN products ON sales.id_ref_product = products.ref_id
GROUP BY sales.id_ref_product;

-- Calculate total turnover
CREATE OR REPLACE VIEW public.total_turnover AS
SELECT ROUND(sum(turnover.turnover)::numeric, 2) as total_turnover
FROM public.turnover;