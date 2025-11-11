const Category = require('../models/categoryModel');
const cloudinary = require('../config/cloudinary');
const { success, error } = require('../utils/response');

// Create category
exports.createCategory = async (req, res) => {
  try {
    let imageUrl = '';
    if (req.file) {
      const result = await cloudinary.uploader.upload(req.file.path, {
        folder: 'categories',
      });
      imageUrl = result.secure_url;
    }

    const category = await Category.create({
      name: req.body.name,
      description: req.body.description,
      image: imageUrl,
    });

    success(res, category, 'Category created successfully');
  } catch (err) {
    error(res, err.message);
  }
};

// Get all categories
exports.getAllCategories = async (req, res) => {
  try {
    const categories = await Category.find().sort({ createdAt: -1 });
    success(res, categories);
  } catch (err) {
    error(res, err.message);
  }
};

// Get single category
exports.getCategory = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);
    if (!category) return error(res, 'Category not found', 404);
    success(res, category);
  } catch (err) {
    error(res, err.message);
  }
};

// Update category
exports.updateCategory = async (req, res) => {
  try {
    let category = await Category.findById(req.params.id);
    if (!category) return error(res, 'Category not found', 404);

    let imageUrl = category.image;
    if (req.file) {
      const result = await cloudinary.uploader.upload(req.file.path, {
        folder: 'categories',
      });
      imageUrl = result.secure_url;
    }

    category = await Category.findByIdAndUpdate(
      req.params.id,
      { name: req.body.name, description: req.body.description, image: imageUrl },
      { new: true }
    );

    success(res, category, 'Category updated');
  } catch (err) {
    error(res, err.message);
  }
};

// Delete category
exports.deleteCategory = async (req, res) => {
  try {
    const category = await Category.findByIdAndDelete(req.params.id);
    if (!category) return error(res, 'Category not found', 404);
    success(res, category, 'Category deleted');
  } catch (err) {
    error(res, err.message);
  }
};
