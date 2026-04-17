require('dotenv').config();
require('express-async-errors');

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const sequelize = require('./models/index');

// Importer les modèles pour qu'ils soient enregistrés
require('./models/User');
require('./models/Service');
require('./models/Review');

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Routes
const authRoutes = require('./routes/authRoutes');
const serviceRoutes = require('./routes/serviceRoutes');
const reviewRoutes = require('./routes/reviewRoutes');

const apiVersion = '/api/v1';
app.use(`${apiVersion}/auth`, authRoutes);
app.use(`${apiVersion}/services`, serviceRoutes);
app.use(`${apiVersion}/services/:serviceId/reviews`, reviewRoutes);

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'OK', message: 'Allo Secours API (MySQL)', timestamp: new Date() });
});

// 404
app.use((req, res) => {
    res.status(404).json({ success: false, error: 'Route non trouvée' });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Error:', err.message);
    res.status(err.status || 500).json({ success: false, error: err.message || 'Erreur serveur' });
});

// Connexion MySQL + démarrage
const PORT = process.env.PORT || 3000;

sequelize.sync({ alter: false })
    .then(() => {
        console.log('✓ Connecté à MySQL (MariaDB)');
        app.listen(PORT, () => {
            console.log(`
╔════════════════════════════════════════╗
║    Allo Secours Backend (MySQL)       ║
║    http://localhost:${PORT}             ║
╚════════════════════════════════════════╝
            `);
        });
    })
    .catch((err) => {
        console.error('✗ Erreur connexion MySQL:', err.message);
        process.exit(1);
    });

module.exports = app;
