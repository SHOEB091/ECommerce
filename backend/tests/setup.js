// Test setup file
// This runs before all tests

// Mock environment variables
process.env.JWT_SECRET = 'test-jwt-secret-key-for-testing-only';
process.env.NODE_ENV = 'test';
process.env.MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/ecommerce_test';

// Increase timeout for async operations
jest.setTimeout(10000);

// Global test utilities
global.testUtils = {
  // Helper to create mock user
  createMockUser: (overrides = {}) => ({
    _id: '507f1f77bcf86cd799439011',
    name: 'Test User',
    email: 'test@example.com',
    password: '$2b$10$hashedpassword',
    role: 'user',
    ...overrides,
  }),

  // Helper to create mock request
  createMockRequest: (overrides = {}) => ({
    body: {},
    params: {},
    query: {},
    headers: {},
    user: null,
    ...overrides,
  }),

  // Helper to create mock response
  createMockResponse: () => {
    const res = {};
    res.status = jest.fn().mockReturnValue(res);
    res.json = jest.fn().mockReturnValue(res);
    res.send = jest.fn().mockReturnValue(res);
    return res;
  },
};

