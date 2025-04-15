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

ALTER Table public.sales
ADD CONSTRAINT unique_sale_combo
UNIQUE (date, id_ref_product, id_store);


CREATE Table public.stores (
  id SERIAL PRIMARY KEY,
  city varchar(255),
  employee_nb integer
);
