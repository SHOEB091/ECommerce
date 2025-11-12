const Product = require('../models/productModel');
const cloudinary = require('../config/cloudinary');
const { success, error } = require('../utils/response');

// ✅ Extract Cloudinary public_id from image URL
function getPublicIdFromUrl(url) {
  try {
    const parts = url.split('/');
    const fileWithExt = parts[parts.length - 1]; // ex: abcdxyz.png
    const folder = parts[parts.length - 2]; // ex: products
    const publicId = fileWithExt.split('.')[0]; // ex: abcdxyz
    return `${folder}/${publicId}`;
  } catch {
    return null;
  }
}

// ✅ Create product
exports.createProduct = async (req, res) => {
  try {
    let image = '';
    if (req.file) {
      // Upload directly from memory buffer
      const base64 = `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`;
      const result = await cloudinary.uploader.upload(base64, { folder: 'products' });
      image = result.secure_url;
    }

    const product = await Product.create({
      name: req.body.name,
      description: req.body.description,
      price: req.body.price,
      stock: req.body.stock,
      category: req.body.category,
      image,
    });

    success(res, product, '✅ Product created successfully');
  } catch (err) {
    console.error(err);
    error(res, err.message);
  }
};

// ✅ Get all products
exports.getAllProducts = async (req, res) => {
  try {
    const products = await Product.find().populate('category', 'name');
    success(res, products);
  } catch (err) {
    error(res, err.message);
  }
};

// ✅ Get single product
exports.getProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id).populate('category', 'name');
    if (!product) return error(res, 'Product not found', 404);
    success(res, product);
  } catch (err) {
    error(res, err.message);
  }
};

// ✅ Update product (with image replacement)
exports.updateProduct = async (req, res) => {
  try {
    let product = await Product.findById(req.params.id);
    if (!product) return error(res, 'Product not found', 404);

    let image = product.image;

    if (req.file) {
      // Delete old Cloudinary image if exists
      if (product.image) {
        const publicId = getPublicIdFromUrl(product.image);
        if (publicId) await cloudinary.uploader.destroy(publicId);
      }

      const base64 = `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`;
      const result = await cloudinary.uploader.upload(base64, { folder: 'products' });
      image = result.secure_url;
    }

    product = await Product.findByIdAndUpdate(
      req.params.id,
      {
        name: req.body.name,
        description: req.body.description,
        price: req.body.price,
        stock: req.body.stock,
        category: req.body.category,
        image,
      },
      { new: true }
    );

    success(res, product, '✅ Product updated successfully');
  } catch (err) {
    console.error(err);
    error(res, err.message);
  }
};

// ✅ Delete product (and its Cloudinary image)
exports.deleteProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return error(res, 'Product not found', 404);

    if (product.image) {
      const publicId = getPublicIdFromUrl(product.image);
      if (publicId) await cloudinary.uploader.destroy(publicId);
    }

    await Product.findByIdAndDelete(req.params.id);
    success(res, product, '🗑️ Product deleted and image removed');
  } catch (err) {
    console.error(err);
    error(res, err.message);
  }
};
