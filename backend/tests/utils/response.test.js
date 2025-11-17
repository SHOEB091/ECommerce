const { success, error } = require('../../utils/response');

describe('Response Utils', () => {
  let mockRes;

  beforeEach(() => {
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    jest.clearAllMocks();
  });

  describe('success', () => {
    it('should send success response with data and default message', () => {
      const data = { id: '123', name: 'Test' };
      success(mockRes, data);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Success',
        data,
      });
    });

    it('should send success response with custom message', () => {
      const data = { id: '123' };
      const message = 'Operation successful';
      success(mockRes, data, message);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message,
        data,
      });
    });
  });

  describe('error', () => {
    it('should send error response with default status 500', () => {
      const message = 'Something went wrong';
      error(mockRes, message);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message,
      });
    });

    it('should send error response with custom status', () => {
      const message = 'Not found';
      error(mockRes, message, 404);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message,
      });
    });
  });
});

