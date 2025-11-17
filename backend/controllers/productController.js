const Product = require('../models/productModel');
const { uploadBufferToS3, deleteFromS3, keyFromS3Url } = require('../config/s3');
const { success, error } = require('../utils/response');

// ✅ Extract S3 object key from image URL (fallback for legacy data)
function getObjectKeyFromUrl(url) {
  try {
    return keyFromS3Url(url);
  } catch {
    return null;
  }
}

async function deleteExistingProductImage(product) {
  const key = product.imageKey || getObjectKeyFromUrl(product.image);
  if (!key) return;
  try {
    await deleteFromS3(key);
  } catch (err) {
    console.error('Failed to delete product image from S3:', err.message);
  }
}

// ✅ Create product
exports.createProduct = async (req, res) => {
  try {
    let image = '';
    let imageKey = '';
    if (req.file) {
      const uploaded = await uploadBufferToS3({
        buffer: req.file.buffer,
        mimetype: req.file.mimetype,
        folder: 'products',
        originalName: req.file.originalname,
      });
      image = uploaded.url;
      imageKey = uploaded.key;
    }

    const product = await Product.create({
      name: req.body.name,
      description: req.body.description,
      price: req.body.price,
      stock: req.body.stock,
      category: req.body.category,
      image,
      imageKey,
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
    let imageKey = product.imageKey;

    if (req.file) {
      await deleteExistingProductImage(product);

      const uploaded = await uploadBufferToS3({
        buffer: req.file.buffer,
        mimetype: req.file.mimetype,
        folder: 'products',
        originalName: req.file.originalname,
      });
      image = uploaded.url;
      imageKey = uploaded.key;
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
        imageKey,
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

    await deleteExistingProductImage(product);

    await Product.findByIdAndDelete(req.params.id);
    success(res, product, '🗑️ Product deleted and image removed');
  } catch (err) {
    console.error(err);
    error(res, err.message);
  }
};
