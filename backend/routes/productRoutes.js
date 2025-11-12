const express = require('express');
const router = express.Router();
const upload = require('../middlewares/upload');
const productCtrl = require('../controllers/productController');

router.post('/', upload.single('image'), productCtrl.createProduct);
router.get('/', productCtrl.getAllProducts);
router.get('/:id', productCtrl.getProduct);
router.put('/:id', upload.single('image'), productCtrl.updateProduct);
router.delete('/:id', productCtrl.deleteProduct);

module.exports = router;
