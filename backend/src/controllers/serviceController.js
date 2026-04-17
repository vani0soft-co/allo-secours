const { Op } = require('sequelize');
const Service = require('../models/Service');

// Formater un service pour la réponse (parse les JSON strings)
function formatService(s, distanceKm = 0) {
    const j = s.toJSON ? s.toJSON() : s;
    return {
        ...j,
        specialties: typeof j.specialties === 'string' ? JSON.parse(j.specialties || '[]') : (j.specialties || []),
        services: typeof j.services === 'string' ? JSON.parse(j.services || '[]') : (j.services || []),
        distance: parseFloat(distanceKm.toFixed ? distanceKm.toFixed(2) : distanceKm),
    };
}

// Haversine : distance en km entre deux points GPS
function haversineKm(lat1, lon1, lat2, lon2) {
    const R = 6371;
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLon = ((lon2 - lon1) * Math.PI) / 180;
    const a =
        Math.sin(dLat / 2) ** 2 +
        Math.cos((lat1 * Math.PI) / 180) *
        Math.cos((lat2 * Math.PI) / 180) *
        Math.sin(dLon / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

// Tous les services
exports.getAllServices = async (req, res) => {
    try {
        const { category, search, skip = 0, limit = 50 } = req.query;

        const where = {};
        if (category) where.category = category;
        if (search) {
            where[Op.or] = [
                { name: { [Op.like]: `%${search}%` } },
                { address: { [Op.like]: `%${search}%` } },
                { city: { [Op.like]: `%${search}%` } },
            ];
        }

        const { count, rows } = await Service.findAndCountAll({
            where,
            offset: parseInt(skip),
            limit: parseInt(limit),
            order: [['rating', 'DESC']],
        });

        const data = rows.map(s => formatService(s, 0));

        res.json({ success: true, data, pagination: { total: count } });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

// Service par ID
exports.getServiceById = async (req, res) => {
    try {
        const service = await Service.findByPk(req.params.id);
        if (!service) {
            return res.status(404).json({ success: false, error: 'Service non trouvé' });
        }
        res.json({ success: true, data: formatService(service, 0) });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

// Services à proximité (GET avec lat/lon en query)
exports.getNearbyServices = async (req, res) => {
    try {
        const { latitude, longitude, radius = 10, category } = req.query;

        const lat = parseFloat(latitude);
        const lon = parseFloat(longitude);
        const radiusKm = parseFloat(radius);

        if (isNaN(lat) || isNaN(lon)) {
            return res.status(400).json({ success: false, error: 'latitude et longitude requis' });
        }

        const where = {};
        if (category) where.category = category;

        const services = await Service.findAll({ where });

        const nearby = services
            .map(s => {
                const dist = haversineKm(lat, lon, s.latitude, s.longitude);
                return formatService(s, dist);
            })
            .filter(s => s.distance <= radiusKm)
            .sort((a, b) => a.distance - b.distance)
            .slice(0, 50);

        res.json({ success: true, data: nearby });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

// Créer un service
exports.createService = async (req, res) => {
    try {
        const service = await Service.create({
            ...req.body,
            specialties: req.body.specialties || [],
            services: req.body.services || [],
        });
        res.status(201).json({ success: true, data: service });
    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
};
