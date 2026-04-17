const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Authentication routes
router.post('/register', authController.register);
router.post('/login', authController.login);

// Protected routes (require authentication)
// router.get('/profile', authenticate, authController.getProfile);
// router.put('/profile', authenticate, authController.updateProfile);
// router.post('/favorites/:serviceId', authenticate, authController.addFavorite);
// router.delete('/favorites/:serviceId', authenticate, authController.removeFavorite);
// router.post('/search-history', authenticate, authController.addSearchHistory);
// router.post('/location', authenticate, authController.updateLocation);

module.exports = router;
