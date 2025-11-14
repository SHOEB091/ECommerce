#!/bin/bash

# Script to update API URL in Flutter app
# Usage: ./update-api-url.sh <your-backend-url>

if [ -z "$1" ]; then
    echo "Usage: ./update-api-url.sh <your-backend-url>"
    echo "Example: ./update-api-url.sh https://my-app.railway.app"
    exit 1
fi

API_URL=$1
echo "Updating API URL to: $API_URL"

# Extract host from URL (remove https://)
HOST=$(echo $API_URL | sed 's|https\?://||' | sed 's|/.*||')

# Update api.dart
sed -i.bak "s|const String API_BASE = .*|const String API_BASE = '$API_URL/api/v1';|g" ecommerce/lib/utils/api.dart

# Update main.dart for cart service
sed -i.bak "s|host: 'localhost'|host: '$HOST', useHttps: true|g" ecommerce/lib/main.dart
sed -i.bak "s|port: 5000|port: 443|g" ecommerce/lib/main.dart

echo ""
echo "✅ API URL updated successfully!"
echo ""
echo "Files updated:"
echo "  - ecommerce/lib/utils/api.dart"
echo "  - ecommerce/lib/main.dart"
echo ""
echo "Next steps:"
echo "  1. cd ecommerce"
echo "  2. flutter clean"
echo "  3. flutter pub get"
echo "  4. flutter build apk --release"
echo ""

