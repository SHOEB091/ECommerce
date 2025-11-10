const Product = require('../models/productModel');
const cloudinary = require('../config/cloudinary');
const { success, error } = require('../utils/response');

// Create product
exports.createProduct = async (req, res) => {
  try {
    let imageUrl = '';
    if (req.file) {
      const result = await cloudinary.uploader.upload(req.file.path, { folder: 'products' });
      imageUrl = result.secure_url;
    }

    const product = await Product.create({
      name: req.body.name,
      description: req.body.description,
      price: req.body.price,
      stock: req.body.stock,
      category: req.body.category,
      image: imageUrl,
    });

    success(res, product, 'Product created successfully');
  } catch (err) {
    error(res, err.message);
  }
};

// Get all products
exports.getAllProducts = async (req, res) => {
  try {
    const products = await Product.find().populate('category', 'name');
    success(res, products);
  } catch (err) {
    error(res, err.message);
  }
};

// Get single product
exports.getProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id).populate('category', 'name');
    if (!product) return error(res, 'Product not found', 404);
    success(res, product);
  } catch (err) {
    error(res, err.message);
  }
};

// Update product
exports.updateProduct = async (req, res) => {
  try {
    let product = await Product.findById(req.params.id);
    if (!product) return error(res, 'Product not found', 404);

    let imageUrl = product.image;
    if (req.file) {
      const result = await cloudinary.uploader.upload(req.file.path, { folder: 'products' });
      imageUrl = result.secure_url;
    }

    product = await Product.findByIdAndUpdate(
      req.params.id,
      {
        name: req.body.name,
        description: req.body.description,
        price: req.body.price,
        stock: req.body.stock,
        category: req.body.category,
        image: imageUrl,
      },
      { new: true }
    );

    success(res, product, 'Product updated');
  } catch (err) {
    error(res, err.message);
  }
};

// Delete product
exports.deleteProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndDelete(req.params.id);
    if (!product) return error(res, 'Product not found', 404);
    success(res, product, 'Product deleted');
  } catch (err) {
    error(res, err.message);
  }
};
