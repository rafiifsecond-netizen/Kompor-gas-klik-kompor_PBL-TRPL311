START TRANSACTION;

SET @demo_order_number = 'KP-DEMO-ONGOING-20261021';
SET @demo_customer_id = 5;
SET @demo_technician_id = 2;
SET @demo_service_item_id = 3;
SET @demo_order_id = (
    SELECT id FROM orders WHERE order_number = @demo_order_number LIMIT 1
);
SET @demo_service_name = (
    SELECT name FROM service_items WHERE id = @demo_service_item_id
);
SET @demo_service_price = (
    SELECT base_price FROM service_items WHERE id = @demo_service_item_id
);

INSERT INTO orders (
    order_number,
    customer_id,
    technician_id,
    status,
    scheduled_at,
    customer_name,
    customer_phone,
    address,
    latitude,
    longitude,
    stove_brand,
    stove_type,
    problem_description,
    subtotal,
    transport_fee,
    discount,
    total_amount,
    payment_method,
    payment_status,
    created_at,
    updated_at
)
SELECT
    @demo_order_number,
    @demo_customer_id,
    @demo_technician_id,
    'on_the_way',
    NOW() + INTERVAL 1 HOUR,
    customer.name,
    COALESCE(customer.phone, '-'),
    'Jl. Kemang Timur No. 21, Jakarta Selatan (order demo)',
    -6.2500000,
    106.8350000,
    'Modena',
    'Kompor Tanam 2 Tungku',
    'Order demo untuk mencoba alur pesanan teknisi.',
    @demo_service_price,
    15000,
    ROUND(@demo_service_price * 0.10, 2),
    @demo_service_price + 15000 - ROUND(@demo_service_price * 0.10, 2),
    'cash',
    'unpaid',
    NOW(),
    NOW()
FROM users AS customer
WHERE customer.id = @demo_customer_id
  AND customer.role = 'customer'
  AND @demo_service_name IS NOT NULL
  AND @demo_order_id IS NULL;

SET @demo_order_id = (
    SELECT id FROM orders WHERE order_number = @demo_order_number LIMIT 1
);

INSERT INTO order_items (
    order_id,
    service_item_id,
    service_name,
    unit_price,
    quantity,
    total_price,
    created_at,
    updated_at
)
SELECT
    @demo_order_id,
    @demo_service_item_id,
    @demo_service_name,
    @demo_service_price,
    1,
    @demo_service_price,
    NOW(),
    NOW()
WHERE @demo_order_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM order_items WHERE order_id = @demo_order_id
  );

INSERT INTO order_status_logs (
    order_id,
    actor_id,
    actor_role,
    status_from,
    status_to,
    note,
    latitude,
    longitude,
    created_at,
    updated_at
)
SELECT
    @demo_order_id,
    @demo_technician_id,
    'technician',
    NULL,
    'accepted',
    'Order demo diterima teknisi.',
    -6.2297280,
    106.8558500,
    NOW(),
    NOW()
WHERE @demo_order_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM order_status_logs
      WHERE order_id = @demo_order_id AND status_to = 'accepted'
  );

INSERT INTO order_status_logs (
    order_id,
    actor_id,
    actor_role,
    status_from,
    status_to,
    note,
    latitude,
    longitude,
    created_at,
    updated_at
)
SELECT
    @demo_order_id,
    @demo_technician_id,
    'technician',
    'accepted',
    'on_the_way',
    'Order demo: teknisi sedang menuju lokasi pelanggan.',
    -6.2297280,
    106.8558500,
    NOW(),
    NOW()
WHERE @demo_order_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM order_status_logs
      WHERE order_id = @demo_order_id AND status_to = 'on_the_way'
  );

INSERT INTO chats (order_id, customer_id, technician_id, created_at, updated_at)
SELECT @demo_order_id, @demo_customer_id, @demo_technician_id, NOW(), NOW()
WHERE @demo_order_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM chats WHERE order_id = @demo_order_id);

COMMIT;
