const { Sequelize } = require('sequelize');
require('dotenv').config();

let sequelize;

if (process.env.DATABASE_URL) {
    // Railway fournit DATABASE_URL automatiquement
    sequelize = new Sequelize(process.env.DATABASE_URL, {
        dialect: 'mysql',
        logging: false,
        dialectOptions: {
            ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
        },
        pool: { max: 10, min: 0, acquire: 30000, idle: 10000 },
    });
} else {
    // Local (Laragon)
    sequelize = new Sequelize(
        process.env.DB_NAME || 'allo_secours',
        process.env.DB_USER || 'root',
        process.env.DB_PASSWORD || '',
        {
            host: process.env.DB_HOST || 'localhost',
            port: process.env.DB_PORT || 3306,
            dialect: 'mysql',
            logging: false,
            pool: { max: 10, min: 0, acquire: 30000, idle: 10000 },
        }
    );
}

module.exports = sequelize;
