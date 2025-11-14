# Backend Tests

This directory contains unit tests for the backend API.

## Quick Start

```bash
# Install dependencies (if not already done)
npm install

# Run all tests
npm test

# Run tests in watch mode (for development)
npm run test:watch

# Run tests with coverage report
npm test
# Coverage report will be in backend/coverage/
```

## Test Structure

- `setup.js` - Global test configuration and utilities
- `controllers/` - Tests for API controllers
- `middleware/` - Tests for Express middleware
- `utils/` - Tests for utility functions

## Writing Tests

All tests use Jest and follow this pattern:

```javascript
const module = require('../../path/to/module');
const Dependency = require('../../path/to/dependency');

jest.mock('../../path/to/dependency');

describe('Module Name', () => {
  let mockReq, mockRes;

  beforeEach(() => {
    mockReq = { body: {}, params: {} };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
  });

  it('should do something', async () => {
    // Arrange
    // Act
    // Assert
  });
});
```

## Mocking

- **Database Models**: Mock Mongoose models using `jest.mock()`
- **External Services**: Mock Cloudinary, email services, etc.
- **JWT**: Mock `jsonwebtoken` for authentication tests

## Coverage

Aim for high test coverage, especially for:
- Business logic in controllers
- Authentication and authorization
- Data validation
- Error handling

