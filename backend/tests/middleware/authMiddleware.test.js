const { protect, authorizeRoles } = require('../../middleware/authMiddleware');
const userModels = require('../../models/userModels');
const jwt = require('jsonwebtoken');

jest.mock('../../models/userModels');
jest.mock('jsonwebtoken');

describe('Auth Middleware', () => {
  let mockReq, mockRes, mockNext;

  beforeEach(() => {
    mockReq = {
      headers: {},
      user: null,
    };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    mockNext = jest.fn();
    jest.clearAllMocks();
  });

  describe('protect', () => {
    it('should return 401 if no authorization header', async () => {
      mockReq.headers = {};

      await protect(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'Not authorized, no token',
      });
      expect(mockNext).not.toHaveBeenCalled();
    });

    it('should return 401 if token does not start with Bearer', async () => {
      mockReq.headers = {
        authorization: 'Invalid token',
      };

      await protect(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'Not authorized, no token',
      });
      expect(mockNext).not.toHaveBeenCalled();
    });

    it('should return 401 if token is invalid', async () => {
      mockReq.headers = {
        authorization: 'Bearer invalid-token',
      };
      jwt.verify.mockImplementation(() => {
        throw new Error('Invalid token');
      });

      await protect(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'Token invalid or expired',
      });
      expect(mockNext).not.toHaveBeenCalled();
    });

    it('should return 404 if user not found', async () => {
      mockReq.headers = {
        authorization: 'Bearer valid-token',
      };
      jwt.verify.mockReturnValue({ id: '507f1f77bcf86cd799439011' });
      const mockSelect = jest.fn().mockResolvedValue(null);
      userModels.findById = jest.fn().mockReturnValue({
        select: mockSelect,
      });

      await protect(mockReq, mockRes, mockNext);

      expect(userModels.findById).toHaveBeenCalledWith('507f1f77bcf86cd799439011');
      expect(mockSelect).toHaveBeenCalledWith('-password');
      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'User not found',
      });
      expect(mockNext).not.toHaveBeenCalled();
    });

    it('should call next() if token is valid and user exists', async () => {
      const mockUser = {
        _id: '507f1f77bcf86cd799439011',
        name: 'Test User',
        email: 'test@example.com',
      };
      mockReq.headers = {
        authorization: 'Bearer valid-token',
      };
      jwt.verify.mockReturnValue({ id: '507f1f77bcf86cd799439011' });
      const mockSelect = jest.fn().mockResolvedValue(mockUser);
      userModels.findById = jest.fn().mockReturnValue({
        select: mockSelect,
      });

      await protect(mockReq, mockRes, mockNext);

      expect(jwt.verify).toHaveBeenCalledWith('valid-token', process.env.JWT_SECRET);
      expect(userModels.findById).toHaveBeenCalledWith('507f1f77bcf86cd799439011');
      expect(mockSelect).toHaveBeenCalledWith('-password');
      expect(mockReq.user).toEqual(mockUser);
      expect(mockNext).toHaveBeenCalled();
      expect(mockRes.status).not.toHaveBeenCalled();
    });
  });

  describe('authorizeRoles', () => {
    it('should return 403 if user role is not authorized', () => {
      mockReq.user = { role: 'user' };
      const middleware = authorizeRoles('admin', 'superadmin');

      middleware(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'Access denied: requires admin, superadmin role',
      });
      expect(mockNext).not.toHaveBeenCalled();
    });

    it('should call next() if user role is authorized', () => {
      mockReq.user = { role: 'admin' };
      const middleware = authorizeRoles('admin', 'superadmin');

      middleware(mockReq, mockRes, mockNext);

      expect(mockNext).toHaveBeenCalled();
      expect(mockRes.status).not.toHaveBeenCalled();
    });

    it('should call next() if user is superadmin', () => {
      mockReq.user = { role: 'superadmin' };
      const middleware = authorizeRoles('admin', 'superadmin');

      middleware(mockReq, mockRes, mockNext);

      expect(mockNext).toHaveBeenCalled();
      expect(mockRes.status).not.toHaveBeenCalled();
    });
  });
});

