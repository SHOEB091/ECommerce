#!/usr/bin/env node

/**
 * Script to update API base URL in Flutter app
 * Usage: node scripts/update-api-url.js <new-api-url>
 */

const fs = require('fs');
const path = require('path');

const apiUrl = process.argv[2];

if (!apiUrl) {
  console.error('❌ Please provide API URL');
  console.log('Usage: node scripts/update-api-url.js <api-url>');
  process.exit(1);
}

const apiFile = path.join(__dirname, '../../ecommerce/lib/utils/api.dart');

if (!fs.existsSync(apiFile)) {
  console.error('❌ API file not found:', apiFile);
  process.exit(1);
}

let content = fs.readFileSync(apiFile, 'utf8');

// Update API_BASE constant
const newApiBase = `const String API_BASE = '${apiUrl}/api/v1';`;
content = content.replace(/const String API_BASE = .*?;/g, newApiBase);

fs.writeFileSync(apiFile, content, 'utf8');

console.log('✅ Updated API base URL to:', apiUrl);
console.log('📝 File updated:', apiFile);

