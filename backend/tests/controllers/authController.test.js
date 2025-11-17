const authController = require('../../controllers/authController');
const userModels = require('../../models/userModels');
const EmailOtp = require('../../models/emailOtpModel');
const sendEmail = require('../../utils/sendEmail');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// Mock dependencies
jest.mock('../../models/userModels');
jest.mock('../../models/emailOtpModel');
jest.mock('../../utils/sendEmail');
jest.mock('bcrypt');
jest.mock('jsonwebtoken');

describe('Auth Controller', () => {
  let mockReq, mockRes;

  beforeEach(() => {
    mockReq = {
      body: {},
      user: null,
    };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    jest.clearAllMocks();
  });

  describe('sendEmailOtp', () => {
    it('should return 400 if email is missing', async () => {
      mockReq.body = {};

      await authController.sendEmailOtp(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'email is required',
        success: false,
      });
    });

    it('should return 400 if user already exists', async () => {
      mockReq.body = { email: 'existing@example.com' };
      userModels.findOne.mockResolvedValue({ email: 'existing@example.com' });

      await authController.sendEmailOtp(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'user already exists',
        success: false,
      });
    });

    it('should send OTP successfully', async () => {
      mockReq.body = { email: 'new@example.com' };
      userModels.findOne.mockResolvedValue(null);
      EmailOtp.deleteMany.mockResolvedValue({});
      EmailOtp.create.mockResolvedValue({});
      sendEmail.mockResolvedValue(true);

      await authController.sendEmailOtp(mockReq, mockRes);

      expect(EmailOtp.deleteMany).toHaveBeenCalledWith({ email: 'new@example.com' });
      expect(EmailOtp.create).toHaveBeenCalled();
      expect(sendEmail).toHaveBeenCalled();
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'otp sent to email',
        success: true,
      });
    });
  });

  describe('verifyEmailOtp', () => {
    it('should return 400 if required fields are missing', async () => {
      mockReq.body = { email: 'test@example.com' };

      await authController.verifyEmailOtp(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'all fields are required',
        success: false,
      });
    });

    it('should return 400 if OTP is invalid', async () => {
      mockReq.body = {
        email: 'test@example.com',
        otp: '123456',
        name: 'Test User',
        password: 'password123',
      };
      EmailOtp.findOne.mockResolvedValue({
        email: 'test@example.com',
        otp: '654321',
        expiresAt: new Date(Date.now() + 5 * 60 * 1000),
      });

      await authController.verifyEmailOtp(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'invalid otp',
        success: false,
      });
    });

    it('should register user successfully with valid OTP', async () => {
      const mockUser = {
        _id: '507f1f77bcf86cd799439011',
        name: 'Test User',
        email: 'test@example.com',
      };
      mockReq.body = {
        email: 'test@example.com',
        otp: '123456',
        name: 'Test User',
        password: 'password123',
      };
      EmailOtp.findOne.mockResolvedValue({
        email: 'test@example.com',
        otp: '123456',
        expiresAt: new Date(Date.now() + 5 * 60 * 1000),
      });
      bcrypt.hash.mockResolvedValue('hashedpassword');
      userModels.create.mockResolvedValue(mockUser);
      EmailOtp.deleteMany.mockResolvedValue({});
      jwt.sign.mockReturnValue('mock-jwt-token');

      await authController.verifyEmailOtp(mockReq, mockRes);

      expect(bcrypt.hash).toHaveBeenCalledWith('password123', 10);
      expect(userModels.create).toHaveBeenCalled();
      expect(EmailOtp.deleteMany).toHaveBeenCalledWith({ email: 'test@example.com' });
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'user registered successfully',
        token: 'mock-jwt-token',
        success: true,
        user: expect.objectContaining({
          id: mockUser._id,
          name: mockUser.name,
          email: mockUser.email,
        }),
      });
    });
  });

  describe('loginUser', () => {
    it('should return 400 if email or password is missing', async () => {
      mockReq.body = { email: 'test@example.com' };

      await authController.loginUser(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'email and password are required',
        success: false,
      });
    });

    it('should return 400 if user not found', async () => {
      mockReq.body = {
        email: 'test@example.com',
        password: 'password123',
      };
      userModels.findOne.mockResolvedValue(null);

      await authController.loginUser(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'invalid credentials',
        success: false,
      });
    });

    it('should return 400 if password is invalid', async () => {
      const mockUser = {
        _id: '507f1f77bcf86cd799439011',
        email: 'test@example.com',
        password: 'hashedpassword',
      };
      mockReq.body = {
        email: 'test@example.com',
        password: 'wrongpassword',
      };
      userModels.findOne.mockResolvedValue(mockUser);
      bcrypt.compare.mockResolvedValue(false);

      await authController.loginUser(mockReq, mockRes);

      expect(bcrypt.compare).toHaveBeenCalledWith('wrongpassword', 'hashedpassword');
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'invalid credentials',
        success: false,
      });
    });

    it('should login successfully with valid credentials', async () => {
      const mockUser = {
        _id: '507f1f77bcf86cd799439011',
        name: 'Test User',
        email: 'test@example.com',
        password: 'hashedpassword',
        role: 'user',
      };
      mockReq.body = {
        email: 'test@example.com',
        password: 'password123',
      };
      userModels.findOne.mockResolvedValue(mockUser);
      bcrypt.compare.mockResolvedValue(true);
      jwt.sign.mockReturnValue('mock-jwt-token');

      await authController.loginUser(mockReq, mockRes);

      expect(bcrypt.compare).toHaveBeenCalledWith('password123', 'hashedpassword');
      expect(jwt.sign).toHaveBeenCalled();
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'login successful',
        token: 'mock-jwt-token',
        success: true,
        user: expect.objectContaining({
          id: mockUser._id,
          name: mockUser.name,
          email: mockUser.email,
          role: mockUser.role,
        }),
      });
    });
  });

  describe('getMe', () => {
    it('should return 401 if user is not authenticated', async () => {
      mockReq.userId = null;
      mockReq.user = null;

      await authController.getMe(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: 'Unauthorized',
        success: false,
      });
    });

    it('should return user data if authenticated', async () => {
      const mockUser = {
        _id: '507f1f77bcf86cd799439011',
        name: 'Test User',
        email: 'test@example.com',
      };
      mockReq.userId = '507f1f77bcf86cd799439011';
      const mockSelect = jest.fn().mockResolvedValue(mockUser);
      userModels.findById = jest.fn().mockReturnValue({
        select: mockSelect,
      });

      await authController.getMe(mockReq, mockRes);

      expect(userModels.findById).toHaveBeenCalledWith('507f1f77bcf86cd799439011');
      expect(mockSelect).toHaveBeenCalledWith('-password');
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        user: mockUser,
      });
    });
  });

  describe('updateMe', () => {
    it('should return 401 if user is not authenticated', async () => {
      mockReq.user = null;

      await authController.updateMe(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Unauthorized',
      });
    });

    it('should return 400 if no fields provided', async () => {
      mockReq.user = { _id: '507f1f77bcf86cd799439011' };
      mockReq.body = {};

      await authController.updateMe(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'No fields provided',
      });
    });

    it('should return 400 if email already exists', async () => {
      const existingUser = { _id: '507f1f77bcf86cd799439012', email: 'existing@example.com' };
      mockReq.user = { _id: '507f1f77bcf86cd799439011' };
      mockReq.body = { email: 'existing@example.com' };
      userModels.findOne.mockResolvedValue(existingUser);

      await authController.updateMe(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Email already exists. Please use a different email.',
      });
    });

    it('should update user successfully', async () => {
      const updatedUser = {
        _id: '507f1f77bcf86cd799439011',
        name: 'Updated Name',
        email: 'test@example.com',
      };
      mockReq.user = { _id: '507f1f77bcf86cd799439011' };
      mockReq.body = { name: 'Updated Name' };
      userModels.findOne.mockResolvedValue(null);
      const mockSelect = jest.fn().mockResolvedValue(updatedUser);
      userModels.findByIdAndUpdate = jest.fn().mockReturnValue({
        select: mockSelect,
      });

      await authController.updateMe(mockReq, mockRes);

      expect(userModels.findByIdAndUpdate).toHaveBeenCalledWith(
        '507f1f77bcf86cd799439011',
        { name: 'Updated Name' },
        { new: true, runValidators: true }
      );
      expect(mockSelect).toHaveBeenCalledWith('-password');
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        user: updatedUser,
      });
    });
  });
});

