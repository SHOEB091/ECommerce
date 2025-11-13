const express = require('express');
const router = express.Router();
const upload = require('../middlewares/upload');
const categoryCtrl = require('../controllers/categoryController');

router.post('/', upload.single('image'), categoryCtrl.createCategory);
router.get('/', categoryCtrl.getAllCategories);
router.get('/:id', categoryCtrl.getCategory);
router.put('/:id', upload.single('image'), categoryCtrl.updateCategory);
router.delete('/:id', categoryCtrl.deleteCategory);

module.exports = router;
