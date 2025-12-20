import dotenv from 'dotenv';
dotenv.config();

import pg from 'pg';
const { Pool } = pg;

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 5432,
    database: process.env.DB_NAME || 'ingles',
    user: process.env.DB_USER || 'postgres',
    password: String(process.env.DB_PASSWORD || ''),
});

// Test connection
pool.query('SELECT NOW()')
    .then(() => console.log('✓ Conectado a PostgreSQL'))
    .catch(err => console.error('✗ Error de conexión:', err.message));

export const query = (text, params) => pool.query(text, params);
export default pool;
