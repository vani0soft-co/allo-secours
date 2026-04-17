const express = require('express');
const router = express.Router({ mergeParams: true });
const reviewController = require('../controllers/reviewController');

// GET /services/:serviceId/reviews
router.get('/', reviewController.getServiceReviews);

// POST /services/:serviceId/reviews
router.post('/', reviewController.createReview);

// Routes simplifiées (update/delete/like non implémentées dans ce backend)

module.exports = router;
