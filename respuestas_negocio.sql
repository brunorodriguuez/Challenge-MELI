/* Ejercicio 1: 
Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas realizadas en enero 2020 sea superior a 1500. 
*/

SELECT
    c.customer_id,
    c.email,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS total_sales
FROM
    Customer c
JOIN
    Order o ON c.customer_id = o.customer_id
WHERE
    -- Filtrar por usuarios cuyo cumpleaños es hoy
    MONTH(c.birth_date) = MONTH(CURDATE()) -- Mes actual
    AND DAY(c.birth_date) = DAY(CURDATE()) -- Día actual
    -- Filtrar por ventas en enero de 2020
    AND o.order_date BETWEEN '2020-01-01' AND '2020-01-31' -- Ventas en enero 2020
-- Asegurar que la cantidad total de ventas sea superior a 1500
GROUP BY 
    c.customer_id
HAVING 
    total_sales > 1500;


/* Ejercicio 2: 
Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($) en la categoría Celulares. 
Se requiere el mes y año de análisis, nombre y apellido del vendedor, cantidad de ventas realizadas, cantidad de productos vendidos y el monto total transaccionado.
*/

WITH SellersPerMonth AS ( --Utilización de tabla temporal solo para una mejor lectura
    SELECT
        YEAR(o.order_date) AS year,
        MONTH(o.order_date) AS month,
        c.first_name,
        c.last_name,
        COUNT(o.order_id) AS total_sales,
        SUM(o.quantity) AS total_products_sold,
        SUM(o.total_price) AS total_amount,
        RANK() OVER (PARTITION BY MONTH(o.order_date) ORDER BY total_amount DESC) AS ranking --Asignar ranking a cada vendedor dentro de cada mes según el total_amount.

    FROM Order o
    JOIN Item i ON o.item_id = i.item_id
    JOIN Customer c ON i.seller_id = c.customer_id
    JOIN Category cat ON i.category_id = cat.category_id
    WHERE cat.name = 'Celulares'  
    AND o.order_date BETWEEN '2020-01-01' AND '2020-12-31'
    GROUP BY MONTH(o.order_date), c.customer_id, c.first_name, c.last_name
)
SELECT 
    month, 
    first_name, 
    last_name, 
    total_sales, 
    total_products_sold, 
    total_amount
FROM SellersPerMonth
WHERE ranking <= 5
ORDER BY month, total_amount DESC;
 
 
 /* 
 Comentarios: 

 -- Category: Si sabemos el id de la Categoría, podríamos incluirlo en el where y no hacemos un join con la tabla de Category. 
        Por ejemplo, si category_id = 1 es Celulares,entonces:
        where i.category_id = 1 

--  RANK() OVER (PARTITION BY YEAR(o.order_date), MONTH(o.order_date) ORDER BY SUM(o.total_price) DESC) AS ranking
        RANK() genera un número de clasificación para cada fila dentro de un conjunto de filas. Este número está basado en un orden especificado.
        OVER() es el alcance o ámbito donde se va a aplicar el cálculo
        PARTITION BY divide las filas en grupos (particiones) según las columnas especificadas.
        Ejemplo:

Mes	        Vendedor	Total Ventas
Enero	    A	        1000
Enero	    B	        500
Febrero	    A	        750
Febrero	    B	        1200

Después de RANK OVER PARTION BY:

Mes	        Vendedor	Total Ventas	ranking
Enero	    A	        1000	        1
Enero	    B	        500	            2
Febrero	    B	        1200	        1
Febrero	    A	        750	            2
--
 */



/* Ejercicio 3: 
Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día. 
Tener en cuenta que debe ser reprocesable. Vale resaltar que en la tabla Item, vamos a tener únicamente el último estado informado por la PK definida. 
(Se puede resolver a través de StoredProcedure) 
*/

-- Tabla para el histórico de precios
CREATE TABLE ItemPriceHistory (
    item_id INT,
    price DECIMAL(10, 2),
    status ENUM('active', 'inactive', 'deleted'),
    update_date DATE,
    FOREIGN KEY (item_id) REFERENCES Item(item_id)
);

-- Stored Procedure para actualizar el histórico de precios
DELIMITER //
CREATE PROCEDURE UpdateItemPriceHistory ()
BEGIN
    -- Inserta el precio y estado actual de cada ítem en la tabla de histórico
    INSERT INTO ItemPriceHistory (item_id, price, status, update_date)
        SELECT item_id, price, status, CURDATE()
        FROM Item
        -- Solo si no existe ya un registro para el mismo item_id y update_date
        WHERE NOT EXISTS (
            SELECT 1 -- Verificar la existencia de al menos un registro que cumpla con las condiciones sin importar qué valor sea.
            FROM ItemPriceHistory
            WHERE item_id = Item.item_id
            AND update_date = CURDATE()
        );
END //
DELIMITER ;

-- Ejecución del Stored Procedure
CALL UpdateItemPriceHistory();