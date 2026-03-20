const express = require('express');
const router = express.Router();
const { addFuelRecord, getFuelRecords, getAllSystemRecords, deleteFuelRecord, generateBill } = require('../controllers/fuelController');
const { protect } = require('../middleware/authMiddleware');
const { adminOnly } = require('../middleware/roleMiddleware');

router.post('/add', protect, addFuelRecord);
router.get('/all', protect, getFuelRecords);
router.get('/global', protect, adminOnly, getAllSystemRecords); // Protected by both middlewares
router.delete('/:id', protect, deleteFuelRecord);
router.get('/:id/bill', protect, generateBill);

module.exports = router;
