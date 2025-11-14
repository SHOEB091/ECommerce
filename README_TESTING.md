# Testing Guide

This project includes comprehensive unit testing for both the backend (Node.js/Express) and frontend (Flutter) components.

## Backend Testing

### Setup

The backend uses [Jest](https://jestjs.io/) as the testing framework. Install dependencies:

```bash
cd backend
npm install
```

### Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm test

# Run tests in CI mode
npm run test:ci
```

### Test Structure

- **Location**: `backend/tests/`
- **Test Files**: Follow the pattern `*.test.js`
- **Setup File**: `backend/tests/setup.js` - Contains global test configuration

### Test Coverage

Tests are organized by component type:

- **Controllers**: `tests/controllers/`
  - `authController.test.js` - Authentication tests
  - `productController.test.js` - Product management tests
  - `addressController.test.js` - Address management tests

- **Middleware**: `tests/middleware/`
  - `authMiddleware.test.js` - Authentication middleware tests

- **Utils**: `tests/utils/`
  - `response.test.js` - Response utility tests

### Writing New Tests

1. Create a test file following the naming convention: `*.test.js`
2. Import the module to test
3. Mock external dependencies (database, external APIs, etc.)
4. Write test cases using Jest's `describe` and `it` blocks
5. Use `beforeEach` to set up test fixtures

Example:

```javascript
const controller = require('../../controllers/myController');
const Model = require('../../models/myModel');

jest.mock('../../models/myModel');

describe('My Controller', () => {
  let mockReq, mockRes;

  beforeEach(() => {
    mockReq = { body: {}, params: {} };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
  });

  it('should handle request correctly', async () => {
    // Test implementation
  });
});
```

## Flutter Testing

### Setup

Flutter testing uses the built-in `flutter_test` package. No additional setup is required.

### Running Tests

```bash
cd ecommerce
flutter test

# Run specific test file
flutter test test/services/user_service_test.dart

# Run with coverage
flutter test --coverage
```

### Test Structure

- **Location**: `ecommerce/test/`
- **Test Files**: Follow the pattern `*_test.dart`

### Test Coverage

Tests are organized by component type:

- **Services**: `test/services/`
  - `user_service_test.dart` - User service tests
  - `cart_service_test.dart` - Cart service tests

- **Utils**: `test/utils/`
  - `api_test.dart` - API utility tests

- **Widgets**: `test/widgets/`
  - `custom_textfield_test.dart` - Custom text field widget tests

### Writing New Tests

1. Create a test file following the naming convention: `*_test.dart`
2. Import `package:flutter_test/flutter_test.dart`
3. Import the module to test
4. Write test cases using `test` and `testWidgets` functions
5. Use `setUp` to initialize test fixtures

Example:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce/services/my_service.dart';

void main() {
  group('MyService', () {
    late MyService service;

    setUp(() {
      service = MyService.instance;
    });

    test('should perform action correctly', () {
      // Test implementation
    });
  });
}
```

## Best Practices

1. **Isolation**: Each test should be independent and not rely on other tests
2. **Mocking**: Mock external dependencies (databases, APIs, file system)
3. **Coverage**: Aim for high test coverage, especially for critical business logic
4. **Naming**: Use descriptive test names that explain what is being tested
5. **Arrange-Act-Assert**: Structure tests with clear setup, execution, and verification phases

## Continuous Integration

Both test suites can be integrated into CI/CD pipelines:

- **Backend**: `npm run test:ci` - Runs tests in CI mode with coverage
- **Flutter**: `flutter test --coverage` - Runs tests with coverage report

## Coverage Reports

- **Backend**: Coverage reports are generated in `backend/coverage/`
- **Flutter**: Coverage reports can be generated using `flutter test --coverage`

## Troubleshooting

### Backend Tests

- **MongoDB Connection**: Tests use mocked models, so no actual database connection is needed
- **Environment Variables**: Test environment variables are set in `tests/setup.js`

### Flutter Tests

- **Platform Channels**: Some tests may require mocking platform channels
- **HTTP Requests**: Use `http` package mocking for API tests

