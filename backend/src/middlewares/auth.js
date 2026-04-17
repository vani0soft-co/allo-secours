const jwt = require('jsonwebtoken');

// Middleware d'authentification
exports.authenticate = (req, res, next) => {
    try {
        const token = req.headers.authorization?.split(' ')[1];

        if (!token) {
            return res.status(401).json({
                success: false,
                error: 'Token non fourni',
            });
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = {
            id: decoded.id,
        };

        next();
    } catch (error) {
        return res.status(401).json({
            success: false,
            error: 'Token invalide',
        });
    }
};

// Middleware d'autorisation
exports.authorize = (...roles) => {
    return (req, res, next) => {
        if (!req.user || !roles.includes(req.user.role)) {
            return res.status(403).json({
                success: false,
                error: 'Non autorisé',
            });
        }
        next();
    };
};

// Middleware de gestion des erreurs
exports.errorHandler = (err, req, res, next) => {
    console.error(err);

    res.status(err.status || 500).json({
        success: false,
        error: err.message || 'Erreur serveur interne',
    });
};

// Middleware 404
exports.notFound = (req, res) => {
    res.status(404).json({
        success: false,
        error: 'Route non trouvée',
    });
};
