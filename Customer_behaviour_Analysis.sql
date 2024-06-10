-- What is the total amount each customer spent at the restaurant?
-- To achieve this, I have to join the sales and menu tables.

SELECT s.customer_id, SUM(m.price) AS total_amount_spent
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY customer_id;

-- done

-- How many days has each customer visited the restaurant?
SELECT 
    customer_id, 
    COUNT(DISTINCT order_date) AS days_visited
FROM 
    sales
GROUP BY 
    customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH customer_first_purchase AS (
	SELECT s.customer_id, MIN(s.order_date) AS first_purchase_date
	FROM sales AS s
	GROUP BY s.customer_id
)
SELECT cfp.customer_id, cfp.first_purchase_date, m.product_name
FROM customer_first_purchase AS cfp
JOIN sales AS s ON s.customer_id = cfp.customer_id
AND cfp.first_purchase_date = s.order_date
JOIN menu AS m ON m.product_id = s.product_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name, COUNT(*) AS total_purchased
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_purchased DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?


SELECT
    s.customer_id,
    m.product_name,
    order_counts.max_count
FROM
    sales s
JOIN
    menu m ON s.product_id = m.product_id
JOIN (
    SELECT
        customer_id,
        product_id,
        COUNT(product_id) AS max_count
    FROM
        sales
    GROUP BY
        customer_id, product_id
) AS order_counts ON s.customer_id = order_counts.customer_id
AND s.product_id = order_counts.product_id
LEFT JOIN (
    SELECT
        customer_id,
        MAX(count) AS max_count
    FROM (
        SELECT
            customer_id,
            product_id,
            COUNT(product_id) AS count
        FROM
            sales
        GROUP BY
            customer_id, product_id
    ) AS inner_counts
    GROUP BY
        customer_id
) AS max_order_counts ON order_counts.customer_id = max_order_counts.customer_id
AND order_counts.max_count = max_order_counts.max_count
WHERE
    order_counts.max_count = max_order_counts.max_count;


-- 6. Which item was purchased first by the customer after they became a member?

SELECT 
    s.customer_id, 
    m.product_name, 
    s.order_date
FROM 
    sales s
JOIN 
    members mem ON s.customer_id = mem.customer_id
JOIN 
    menu m ON s.product_id = m.product_id
WHERE 
    s.order_date >= mem.join_date
    AND s.order_date = (
        SELECT MIN(order_date)
        FROM sales
        WHERE customer_id = s.customer_id
          AND order_date >= mem.join_date
    );



-- 7. Which item was purchased just before the customer became a member?

SELECT 
    s.customer_id, 
    m.product_name, 
    s.order_date
FROM 
    sales s
JOIN 
    members mem ON s.customer_id = mem.customer_id
JOIN 
    menu m ON s.product_id = m.product_id
WHERE 
    s.order_date < mem.join_date
    AND s.order_date = (
        SELECT MAX(order_date)
        FROM sales
        WHERE customer_id = s.customer_id
          AND order_date < mem.join_date
    );

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
    s.customer_id,
    COUNT(s.product_id) AS total_items,
    SUM(m.price) AS total_amount_spent
FROM 
sales s
JOIN 
members mem ON s.customer_id = mem.customer_id
JOIN 
menu m ON s.product_id = m.product_id
WHERE 
s.order_date < mem.join_date
GROUP BY 
s.customer_id;




-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT 
    s.customer_id,
    SUM(
        CASE
            WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
            ELSE m.price * 10
        END
    ) AS total_points
FROM 
    sales s
JOIN 
    menu m ON s.product_id = m.product_id
GROUP BY 
    s.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
	-- not just sushi - how many points do customer A and B have at the end of January?

SELECT 
    s.customer_id,
    SUM(
        CASE
            WHEN s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY) THEN m.price * 10 * 2
            WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
            ELSE m.price * 10
        END
    ) AS total_points
FROM 
    sales s
JOIN 
    members mem ON s.customer_id = mem.customer_id
JOIN 
    menu m ON s.product_id = m.product_id
WHERE 
    s.customer_id IN ('A', 'B')
    AND s.order_date <= '2021-01-31'
GROUP BY 
    s.customer_id;
    
-- Project End


    
    
    
    
    