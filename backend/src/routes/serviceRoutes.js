const express = require('express');
const router = express.Router();
const serviceController = require('../controllers/serviceController');

// Routes publiques
router.get('/', serviceController.getAllServices);
router.get('/nearby', serviceController.getNearbyServices);
router.get('/:id', serviceController.getServiceById);
router.post('/', serviceController.createService);

// Routes protégées (admin)
// router.post('/', authenticate, authorize('admin'), serviceController.createService);
// router.put('/:id', authenticate, authorize('admin'), serviceController.updateService);
// router.delete('/:id', authenticate, authorize('admin'), serviceController.deleteService);

module.exports = router;
