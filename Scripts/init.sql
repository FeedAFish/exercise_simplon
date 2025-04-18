-- Create tables products, stores and sales
CREATE Table public.products (
  id SERIAL PRIMARY KEY,
  name varchar(255),
  ref_id varchar(255) UNIQUE,
  price NUMERIC(10,2),
  stock integer
);

CREATE Table public.stores (
  id SERIAL PRIMARY KEY,
  city varchar(255),
  employee_nb integer
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


CREATE Table public.turnover (
  id SERIAL PRIMARY KEY,
  id_ref_product varchar(255) UNIQUE,
  turnover_value NUMERIC(10,2)
);



CREATE Table public.total_turnover (
  id BOOLEAN PRIMARY KEY DEFAULT TRUE,
  turnover_value NUMERIC(10,2)
);

INSERT INTO public.total_turnover (turnover_value) VALUES (0);


CREATE Table public.sales_by_product (
  id SERIAL PRIMARY KEY,
  id_ref_product varchar(255) UNIQUE,
  sold_nb integer
);

CREATE Table public.sales_by_city (
  id SERIAL PRIMARY KEY,
  city varchar(255) UNIQUE,
  sold_nb integer
);


-- Trigger for Turnover
CREATE OR REPLACE FUNCTION public.update_on_insert_turnover()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    product_price numeric;
BEGIN
    SELECT price INTO product_price
    FROM public.products
    WHERE ref_id = NEW.id_ref_product;

    INSERT INTO public.turnover (id_ref_product, turnover_value)
    VALUES (NEW.id_ref_product, NEW.sold_nb * product_price)
    ON CONFLICT (id_ref_product)
    DO UPDATE SET turnover_value = public.turnover.turnover_value + EXCLUDED.turnover_value;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_on_delete_turnover()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    product_price numeric;
BEGIN
    SELECT price INTO product_price
    FROM public.products
    WHERE ref_id = OLD.id_ref_product;

    -- Update turnover
    UPDATE public.turnover
    SET turnover_value = public.turnover.turnover_value - OLD.sold_nb * product_price
    WHERE id_ref_product = OLD.id_ref_product;

    --Delete if value == 0
    IF (SELECT turnover_value FROM public.turnover WHERE id_ref_product = OLD.id_ref_product) = 0 THEN
        DELETE FROM public.turnover
        WHERE id_ref_product = OLD.id_ref_product;
    END IF;

    RETURN OLD;
END;
$$;

CREATE TRIGGER update_insert_turnover
AFTER INSERT ON public.sales
FOR EACH ROW
EXECUTE FUNCTION public.update_on_insert_turnover();

CREATE TRIGGER update_delete_turnover
AFTER DELETE ON public.sales
FOR EACH ROW
EXECUTE FUNCTION public.update_on_delete_turnover();

-- Trigger for Total Turnover
CREATE OR REPLACE FUNCTION public.update_on_insert_total_turnover()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    product_price numeric;
BEGIN
    SELECT price INTO product_price
    FROM public.products
    WHERE ref_id = NEW.id_ref_product;

    UPDATE public.total_turnover
    SET turnover_value = turnover_value + NEW.sold_nb * product_price;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_on_delete_total_turnover()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    product_price numeric;
BEGIN
    SELECT price INTO product_price
    FROM public.products
    WHERE ref_id = OLD.id_ref_product;

    UPDATE public.total_turnover
    SET turnover_value = turnover_value - OLD.sold_nb * product_price;

    RETURN OLD;
END;
$$;

CREATE TRIGGER update_insert_total_turnover
AFTER INSERT ON public.sales
FOR EACH ROW
EXECUTE FUNCTION public.update_on_insert_total_turnover();

CREATE TRIGGER update_delete_total_turnover
AFTER DELETE ON public.sales
FOR EACH ROW
EXECUTE FUNCTION public.update_on_delete_total_turnover();

-- Trigger for Sales by product
CREATE OR REPLACE FUNCTION public.update_on_insert_sales_by_product()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.sales_by_product (id_ref_product, sold_nb)
    VALUES (NEW.id_ref_product, NEW.sold_nb)
    ON CONFLICT (id_ref_product)
    DO UPDATE SET sold_nb = public.sales_by_product.sold_nb + EXCLUDED.sold_nb;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_on_delete_sales_by_product()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.sales_by_product
    SET sold_nb = public.sales_by_product.sold_nb - OLD.sold_nb
    WHERE id_ref_product = OLD.id_ref_product;

    RETURN OLD;
END;
$$;

CREATE TRIGGER update_insert_sales_by_product
AFTER INSERT ON public.sales
FOR EACH ROW
EXECUTE FUNCTION public.update_on_insert_sales_by_product();

CREATE TRIGGER update_delete_sales_by_product
AFTER DELETE ON public.sales
FOR EACH ROW
EXECUTE FUNCTION public.update_on_delete_sales_by_product();

-- Trigger for Sales by city
CREATE OR REPLACE FUNCTION public.update_on_insert_sales_by_city()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  store_city varchar(255);
BEGIN
  SELECT city INTO store_city
  FROM public.stores
  WHERE id = NEW.id_store;

  INSERT INTO public.sales_by_city (city, sold_nb)
  VALUES (store_city, NEW.sold_nb)
  ON CONFLICT (city)
  DO UPDATE SET sold_nb = public.sales_by_city.sold_nb + EXCLUDED.sold_nb;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_on_delete_sales_by_city()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  store_city varchar(255);
BEGIN
  SELECT city INTO store_city
  FROM public.stores
  WHERE id = OLD.id_store;

  UPDATE public.sales_by_city
  SET sold_nb = public.sales_by_city.sold_nb - OLD.sold_nb
  WHERE city = store_city;

  RETURN OLD;
END;
$$;

CREATE TRIGGER update_insert_sales_by_city
AFTER INSERT ON public.sales
FOR EACH ROW
EXECUTE FUNCTION public.update_on_insert_sales_by_city();

CREATE TRIGGER update_delete_sales_by_city
AFTER DELETE ON public.sales
FOR EACH ROW
EXECUTE FUNCTION public.update_on_delete_sales_by_city();