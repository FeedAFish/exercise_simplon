-- Create tables products, stores and sales
CREATE Table public.products (
  id SERIAL PRIMARY KEY,
  name varchar(255),
  ref_id varchar(255) UNIQUE,
  price float,
  stock integer
);

CREATE Table public.sales (
  id SERIAL PRIMARY KEY,
  id_ref_product varchar(255),
  sold_nb integer,
  id_store integer,
  date DATE
);

CREATE Table public.stores (
  id SERIAL PRIMARY KEY,
  city varchar(255),
  employee_nb integer
);

-- Create views to aggregate sales data
CREATE OR REPLACE VIEW public.sales_by_store AS
SELECT s.id_store, sum(s.sold_nb) as sold_nb
FROM public.sales s
GROUP BY s.id_store;

CREATE OR REPLACE VIEW public.sales_by_product AS
SELECT s.id_ref_product, sum(s.sold_nb) as sold_nb
FROM public.sales s
GROUP BY s.id_ref_product;

CREATE OR REPLACE VIEW public.sales_by_city AS
SELECT st.city, SUM(s.sold_nb) AS sold_nb
FROM public.sales s
JOIN public.stores st ON s.id_store = st.id
GROUP BY st.city;

