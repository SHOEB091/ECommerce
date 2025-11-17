const Category = require('../models/categoryModel');
const { uploadBufferToS3, deleteFromS3, keyFromS3Url } = require('../config/s3');
const { success, error } = require('../utils/response');

async function uploadCategoryImage(file) {
  if (!file) return { image: '', imageKey: '' };
  const uploaded = await uploadBufferToS3({
    buffer: file.buffer,
    mimetype: file.mimetype,
    originalName: file.originalname,
    folder: 'categories',
  });

  return { image: uploaded.url, imageKey: uploaded.key };
}

async function deleteCategoryImage(category) {
  if (!category) return;
  const key = category.imageKey || keyFromS3Url(category.image);
  if (!key) return;
  try {
    await deleteFromS3(key);
  } catch (err) {
    console.error('Failed to delete category image from S3:', err.message);
  }
}

// Create category
exports.createCategory = async (req, res) => {
  try {
    let imageUrl = '';
    let imageKey = '';
    if (req.file) {
      ({ image: imageUrl, imageKey } = await uploadCategoryImage(req.file));
    }

    const category = await Category.create({
      name: req.body.name,
      description: req.body.description,
      image: imageUrl,
      imageKey,
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
    let imageKey = category.imageKey;
    if (req.file) {
      await deleteCategoryImage(category);
      ({ image: imageUrl, imageKey } = await uploadCategoryImage(req.file));
    }

    category = await Category.findByIdAndUpdate(
      req.params.id,
      { name: req.body.name, description: req.body.description, image: imageUrl, imageKey },
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
    await deleteCategoryImage(category);
    success(res, category, 'Category deleted');
  } catch (err) {
    error(res, err.message);
  }
};
