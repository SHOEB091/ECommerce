const productController = require('../../controllers/productController');
const Product = require('../../models/productModel');
const s3 = require('../../config/s3');
const { success, error } = require('../../utils/response');

jest.mock('../../models/productModel');
jest.mock('../../config/s3', () => ({
  uploadBufferToS3: jest.fn(),
  deleteFromS3: jest.fn(),
  keyFromS3Url: jest.fn(),
}));
jest.mock('../../utils/response');

describe('Product Controller', () => {
  let mockReq, mockRes;

  beforeEach(() => {
    mockReq = {
      body: {},
      params: {},
      file: null,
    };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    jest.clearAllMocks();
  });

  describe('createProduct', () => {
    it('should create product without image', async () => {
      const mockProduct = {
        _id: '507f1f77bcf86cd799439011',
        name: 'Test Product',
        description: 'Test Description',
        price: 100,
        stock: 10,
        category: '507f1f77bcf86cd799439012',
      };
      mockReq.body = {
        name: 'Test Product',
        description: 'Test Description',
        price: 100,
        stock: 10,
        category: '507f1f77bcf86cd799439012',
      };
      Product.create.mockResolvedValue(mockProduct);
      success.mockImplementation((res, data, message) => {
        res.json({ success: true, data, message });
      });

      await productController.createProduct(mockReq, mockRes);

      expect(Product.create).toHaveBeenCalledWith({
        name: 'Test Product',
        description: 'Test Description',
        price: 100,
        stock: 10,
        category: '507f1f77bcf86cd799439012',
        image: '',
        imageKey: '',
      });
      expect(success).toHaveBeenCalled();
    });

    it('should create product with image', async () => {
      const mockProduct = {
        _id: '507f1f77bcf86cd799439011',
        name: 'Test Product',
        image: 'https://cloudinary.com/image.jpg',
      };
      mockReq.body = {
        name: 'Test Product',
        price: 100,
        stock: 10,
      };
      mockReq.file = {
        mimetype: 'image/jpeg',
        buffer: Buffer.from('fake-image-data'),
      };
      s3.uploadBufferToS3.mockResolvedValue({
        url: 'https://s3.amazonaws.com/bucket/products/image.jpg',
        key: 'products/image.jpg',
      });
      Product.create.mockResolvedValue(mockProduct);

      await productController.createProduct(mockReq, mockRes);

      expect(s3.uploadBufferToS3).toHaveBeenCalled();
      expect(Product.create).toHaveBeenCalledWith(
        expect.objectContaining({
          image: 'https://s3.amazonaws.com/bucket/products/image.jpg',
          imageKey: 'products/image.jpg',
        })
      );
      expect(success).toHaveBeenCalled();
    });
  });

  describe('getAllProducts', () => {
    it('should return all products', async () => {
      const mockProducts = [
        { _id: '1', name: 'Product 1', price: 100 },
        { _id: '2', name: 'Product 2', price: 200 },
      ];
      Product.find.mockReturnValue({
        populate: jest.fn().mockResolvedValue(mockProducts),
      });

      await productController.getAllProducts(mockReq, mockRes);

      expect(Product.find).toHaveBeenCalled();
      expect(success).toHaveBeenCalled();
    });
  });

  describe('getProduct', () => {
    it('should return product if found', async () => {
      const mockProduct = {
        _id: '507f1f77bcf86cd799439011',
        name: 'Test Product',
        price: 100,
      };
      mockReq.params.id = '507f1f77bcf86cd799439011';
      Product.findById.mockReturnValue({
        populate: jest.fn().mockResolvedValue(mockProduct),
      });

      await productController.getProduct(mockReq, mockRes);

      expect(Product.findById).toHaveBeenCalledWith('507f1f77bcf86cd799439011');
      expect(success).toHaveBeenCalled();
    });

    it('should return 404 if product not found', async () => {
      mockReq.params.id = '507f1f77bcf86cd799439011';
      Product.findById.mockReturnValue({
        populate: jest.fn().mockResolvedValue(null),
      });
      error.mockImplementation((res, message, status) => {
        res.status(status || 500).json({ success: false, message });
      });

      await productController.getProduct(mockReq, mockRes);

      expect(error).toHaveBeenCalledWith(mockRes, 'Product not found', 404);
    });
  });

  describe('updateProduct', () => {
    it('should return 404 if product not found', async () => {
      mockReq.params.id = '507f1f77bcf86cd799439011';
      Product.findById.mockResolvedValue(null);
      error.mockImplementation((res, message, status) => {
        res.status(status || 500).json({ success: false, message });
      });

      await productController.updateProduct(mockReq, mockRes);

      expect(error).toHaveBeenCalledWith(mockRes, 'Product not found', 404);
    });

    it('should update product successfully', async () => {
      const existingProduct = {
        _id: '507f1f77bcf86cd799439011',
        name: 'Old Name',
        image: 'https://old-image.jpg',
      };
      const updatedProduct = {
        _id: '507f1f77bcf86cd799439011',
        name: 'New Name',
        image: 'https://old-image.jpg',
      };
      mockReq.params.id = '507f1f77bcf86cd799439011';
      mockReq.body = { name: 'New Name' };
      Product.findById.mockResolvedValue(existingProduct);
      Product.findByIdAndUpdate.mockResolvedValue(updatedProduct);

      await productController.updateProduct(mockReq, mockRes);

      expect(Product.findByIdAndUpdate).toHaveBeenCalled();
      expect(success).toHaveBeenCalled();
    });
  });

  describe('deleteProduct', () => {
    it('should return 404 if product not found', async () => {
      mockReq.params.id = '507f1f77bcf86cd799439011';
      Product.findById.mockResolvedValue(null);
      error.mockImplementation((res, message, status) => {
        res.status(status || 500).json({ success: false, message });
      });

      await productController.deleteProduct(mockReq, mockRes);

      expect(error).toHaveBeenCalledWith(mockRes, 'Product not found', 404);
    });

    it('should delete product and image successfully', async () => {
      const mockProduct = {
        _id: '507f1f77bcf86cd799439011',
        name: 'Test Product',
        image: 'https://s3.amazonaws.com/bucket/products/abc123.jpg',
        imageKey: 'products/abc123.jpg',
      };
      mockReq.params.id = '507f1f77bcf86cd799439011';
      Product.findById.mockResolvedValue(mockProduct);
      Product.findByIdAndDelete.mockResolvedValue(mockProduct);

      await productController.deleteProduct(mockReq, mockRes);

      expect(s3.deleteFromS3).toHaveBeenCalledWith('products/abc123.jpg');
      expect(Product.findByIdAndDelete).toHaveBeenCalledWith('507f1f77bcf86cd799439011');
      expect(success).toHaveBeenCalled();
    });
  });
});

