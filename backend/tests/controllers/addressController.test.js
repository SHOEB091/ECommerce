const addressController = require('../../controllers/address.controller');
const Address = require('../../models/address.model');

jest.mock('../../models/address.model');

describe('Address Controller', () => {
  let mockReq, mockRes;

  beforeEach(() => {
    mockReq = {
      body: {},
      params: {},
      user: {
        _id: '507f1f77bcf86cd799439011',
      },
    };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    jest.clearAllMocks();
  });

  describe('getAddresses', () => {
    it('should return addresses for authenticated user', async () => {
      const mockAddresses = [
        {
          _id: '507f1f77bcf86cd799439012',
          userId: '507f1f77bcf86cd799439011',
          street: '123 Main St',
          city: 'Test City',
          isDefault: true,
        },
      ];
      const mockSort = jest.fn().mockResolvedValue(mockAddresses);
      Address.find = jest.fn().mockReturnValue({
        sort: mockSort,
      });

      await addressController.getAddresses(mockReq, mockRes);

      expect(Address.find).toHaveBeenCalledWith({
        userId: '507f1f77bcf86cd799439011',
      });
      expect(mockSort).toHaveBeenCalledWith({ createdAt: -1 });
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        addresses: mockAddresses,
        count: mockAddresses.length,
      });
    });
  });

  describe('createAddress', () => {
    it('should create address with userId from authenticated user', async () => {
      const mockAddress = {
        _id: '507f1f77bcf86cd799439012',
        userId: '507f1f77bcf86cd799439011',
        street: '123 Main St',
        city: 'Test City',
      };
      mockReq.body = {
        street: '123 Main St',
        city: 'Test City',
        state: 'Test State',
        zipCode: '12345',
      };
      Address.create.mockResolvedValue(mockAddress);

      await addressController.createAddress(mockReq, mockRes);

      expect(Address.create).toHaveBeenCalledWith(
        expect.objectContaining({
          userId: '507f1f77bcf86cd799439011',
          street: '123 Main St',
          city: 'Test City',
        })
      );
      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        address: mockAddress,
      });
    });
  });

  describe('updateAddress', () => {
    it('should update address if user owns it', async () => {
      const updatedAddress = {
        _id: '507f1f77bcf86cd799439012',
        userId: '507f1f77bcf86cd799439011',
        street: '456 New St',
      };
      mockReq.params.id = '507f1f77bcf86cd799439012';
      mockReq.body = { street: '456 New St' };
      Address.findOneAndUpdate.mockResolvedValue(updatedAddress);

      await addressController.updateAddress(mockReq, mockRes);

      expect(Address.findOneAndUpdate).toHaveBeenCalledWith(
        {
          _id: '507f1f77bcf86cd799439012',
          userId: '507f1f77bcf86cd799439011',
        },
        { street: '456 New St' },
        { new: true }
      );
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        address: updatedAddress,
      });
    });

    it('should return 404 if address not found', async () => {
      mockReq.params.id = '507f1f77bcf86cd799439012';
      mockReq.body = { street: '456 New St' };
      Address.findOneAndUpdate.mockResolvedValue(null);

      await addressController.updateAddress(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Address not found',
      });
    });
  });

  describe('deleteAddress', () => {
    it('should delete address if user owns it', async () => {
      const deletedAddress = {
        _id: '507f1f77bcf86cd799439012',
        userId: '507f1f77bcf86cd799439011',
      };
      mockReq.params.id = '507f1f77bcf86cd799439012';
      Address.findOneAndDelete.mockResolvedValue(deletedAddress);

      await addressController.deleteAddress(mockReq, mockRes);

      expect(Address.findOneAndDelete).toHaveBeenCalledWith({
        _id: '507f1f77bcf86cd799439012',
        userId: '507f1f77bcf86cd799439011',
      });
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Deleted successfully',
      });
    });

    it('should return 404 if address not found', async () => {
      mockReq.params.id = '507f1f77bcf86cd799439012';
      Address.findOneAndDelete.mockResolvedValue(null);

      await addressController.deleteAddress(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Address not found',
      });
    });
  });
});

