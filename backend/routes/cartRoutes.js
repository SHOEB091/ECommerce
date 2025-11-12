// routes/cartRoutes.js
const express = require('express');
const router = express.Router();

const cartCtrl = require('../controllers/cartController');
const { protect } = require('../middleware/authMiddleware');



router.use(protect); 

router.get('/', cartCtrl.getCart);
router.post('/item', cartCtrl.addItem);
router.put('/item/:productId', cartCtrl.updateItem);
router.delete('/item/:productId', cartCtrl.removeItem);
router.delete('/', cartCtrl.clearCart);

module.exports = router;
