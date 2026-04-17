const Review = require('../models/Review');
const Service = require('../models/Service');

// Avis d'un service
exports.getServiceReviews = async (req, res) => {
    try {
        const { serviceId } = req.params;
        const reviews = await Review.findAll({
            where: { serviceId },
            order: [['createdAt', 'DESC']],
        });
        res.json({ success: true, data: reviews });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

// Créer un avis
exports.createReview = async (req, res) => {
    try {
        const { serviceId } = req.params;
        const { rating, comment, userName } = req.body;
        const userId = req.user?.id;

        const service = await Service.findByPk(serviceId);
        if (!service) {
            return res.status(404).json({ success: false, error: 'Service non trouvé' });
        }

        const review = await Review.create({
            serviceId,
            userId: userId || null,
            userName: userName || (req.user ? `${req.user.firstName} ${req.user.lastName}` : 'Anonyme'),
            rating,
            comment,
        });

        // Mettre à jour la note moyenne du service
        const reviews = await Review.findAll({ where: { serviceId } });
        const avgRating = reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length;
        await service.update({ rating: parseFloat(avgRating.toFixed(1)), reviewCount: reviews.length });

        res.status(201).json({ success: true, data: review });
    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
};
