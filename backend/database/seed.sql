-- ============================================
-- Seed Data - Vocabulario Español-Inglés
-- Encoding: UTF-8
-- ============================================

-- Limpiar datos existentes del usuario demo
DELETE FROM words WHERE user_id = 1;
DELETE FROM categories WHERE user_id = 1;
DELETE FROM users WHERE username = 'demo';

-- Insertar usuario de prueba
INSERT INTO users (username, email, password_hash) VALUES 
    ('demo', 'demo@example.com', 'demo123');

-- Obtener ID del usuario
DO $$
DECLARE
    demo_user_id INTEGER;
    cat_general_id INTEGER;
    cat_tech_id INTEGER;
    cat_business_id INTEGER;
    cat_travel_id INTEGER;
    cat_food_id INTEGER;
BEGIN
    SELECT id INTO demo_user_id FROM users WHERE username = 'demo';

    -- Crear categorias para el usuario
    INSERT INTO categories (name, user_id) VALUES ('General', demo_user_id) RETURNING id INTO cat_general_id;
    INSERT INTO categories (name, user_id) VALUES ('Technology', demo_user_id) RETURNING id INTO cat_tech_id;
    INSERT INTO categories (name, user_id) VALUES ('Business', demo_user_id) RETURNING id INTO cat_business_id;
    INSERT INTO categories (name, user_id) VALUES ('Travel', demo_user_id) RETURNING id INTO cat_travel_id;
    INSERT INTO categories (name, user_id) VALUES ('Food', demo_user_id) RETURNING id INTO cat_food_id;

    -- GENERAL (20 palabras)
    INSERT INTO words (spanish, english, category_id, user_id) VALUES
        ('casa', 'house', cat_general_id, demo_user_id),
        ('perro', 'dog', cat_general_id, demo_user_id),
        ('gato', 'cat', cat_general_id, demo_user_id),
        ('libro', 'book', cat_general_id, demo_user_id),
        ('mesa', 'table', cat_general_id, demo_user_id),
        ('silla', 'chair', cat_general_id, demo_user_id),
        ('agua', 'water', cat_general_id, demo_user_id),
        ('tiempo', 'time', cat_general_id, demo_user_id),
        ('dia', 'day', cat_general_id, demo_user_id),
        ('noche', 'night', cat_general_id, demo_user_id),
        ('amigo', 'friend', cat_general_id, demo_user_id),
        ('familia', 'family', cat_general_id, demo_user_id),
        ('ciudad', 'city', cat_general_id, demo_user_id),
        ('pais', 'country', cat_general_id, demo_user_id),
        ('mundo', 'world', cat_general_id, demo_user_id),
        ('vida', 'life', cat_general_id, demo_user_id),
        ('trabajo', 'work', cat_general_id, demo_user_id),
        ('escuela', 'school', cat_general_id, demo_user_id),
        ('calle', 'street', cat_general_id, demo_user_id),
        ('puerta', 'door', cat_general_id, demo_user_id);

    -- TECHNOLOGY (15 palabras)
    INSERT INTO words (spanish, english, category_id, user_id) VALUES
        ('computadora', 'computer', cat_tech_id, demo_user_id),
        ('telefono', 'phone', cat_tech_id, demo_user_id),
        ('pantalla', 'screen', cat_tech_id, demo_user_id),
        ('teclado', 'keyboard', cat_tech_id, demo_user_id),
        ('raton', 'mouse', cat_tech_id, demo_user_id),
        ('red', 'network', cat_tech_id, demo_user_id),
        ('aplicacion', 'application', cat_tech_id, demo_user_id),
        ('datos', 'data', cat_tech_id, demo_user_id),
        ('nube', 'cloud', cat_tech_id, demo_user_id),
        ('contrasena', 'password', cat_tech_id, demo_user_id),
        ('usuario', 'user', cat_tech_id, demo_user_id),
        ('archivo', 'file', cat_tech_id, demo_user_id),
        ('carpeta', 'folder', cat_tech_id, demo_user_id),
        ('descarga', 'download', cat_tech_id, demo_user_id),
        ('actualizacion', 'update', cat_tech_id, demo_user_id);

    -- BUSINESS (15 palabras)
    INSERT INTO words (spanish, english, category_id, user_id) VALUES
        ('empresa', 'company', cat_business_id, demo_user_id),
        ('reunion', 'meeting', cat_business_id, demo_user_id),
        ('cliente', 'client', cat_business_id, demo_user_id),
        ('proyecto', 'project', cat_business_id, demo_user_id),
        ('presupuesto', 'budget', cat_business_id, demo_user_id),
        ('ganancia', 'profit', cat_business_id, demo_user_id),
        ('inversion', 'investment', cat_business_id, demo_user_id),
        ('equipo', 'team', cat_business_id, demo_user_id),
        ('meta', 'goal', cat_business_id, demo_user_id),
        ('estrategia', 'strategy', cat_business_id, demo_user_id),
        ('mercado', 'market', cat_business_id, demo_user_id),
        ('ventas', 'sales', cat_business_id, demo_user_id),
        ('contrato', 'contract', cat_business_id, demo_user_id),
        ('socio', 'partner', cat_business_id, demo_user_id),
        ('oficina', 'office', cat_business_id, demo_user_id);

    -- TRAVEL (10 palabras)
    INSERT INTO words (spanish, english, category_id, user_id) VALUES
        ('aeropuerto', 'airport', cat_travel_id, demo_user_id),
        ('vuelo', 'flight', cat_travel_id, demo_user_id),
        ('hotel', 'hotel', cat_travel_id, demo_user_id),
        ('equipaje', 'luggage', cat_travel_id, demo_user_id),
        ('pasaporte', 'passport', cat_travel_id, demo_user_id),
        ('boleto', 'ticket', cat_travel_id, demo_user_id),
        ('playa', 'beach', cat_travel_id, demo_user_id),
        ('montana', 'mountain', cat_travel_id, demo_user_id),
        ('mapa', 'map', cat_travel_id, demo_user_id),
        ('turista', 'tourist', cat_travel_id, demo_user_id);

    -- FOOD (10 palabras)
    INSERT INTO words (spanish, english, category_id, user_id) VALUES
        ('comida', 'food', cat_food_id, demo_user_id),
        ('desayuno', 'breakfast', cat_food_id, demo_user_id),
        ('almuerzo', 'lunch', cat_food_id, demo_user_id),
        ('cena', 'dinner', cat_food_id, demo_user_id),
        ('restaurante', 'restaurant', cat_food_id, demo_user_id),
        ('cocina', 'kitchen', cat_food_id, demo_user_id),
        ('pan', 'bread', cat_food_id, demo_user_id),
        ('carne', 'meat', cat_food_id, demo_user_id),
        ('verdura', 'vegetable', cat_food_id, demo_user_id),
        ('fruta', 'fruit', cat_food_id, demo_user_id);

END $$;

-- Verificar datos
SELECT 'Palabras insertadas: ' || COUNT(*)::text FROM words WHERE user_id = 1;
SELECT 'Categorias: ' || COUNT(*)::text FROM categories WHERE user_id = 1;
