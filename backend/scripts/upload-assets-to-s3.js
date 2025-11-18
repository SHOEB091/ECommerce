/* eslint-disable no-console */

const fs = require('fs');
const path = require('path');

const { uploadBufferToS3 } = require('../config/s3');

const IMAGE_EXTENSIONS = new Set([
  '.png',
  '.jpg',
  '.jpeg',
  '.gif',
  '.bmp',
  '.webp',
  '.svg',
]);

const guessMimeType = (filePath) => {
  const ext = path.extname(filePath).toLowerCase();
  switch (ext) {
    case '.png':
      return 'image/png';
    case '.jpg':
    case '.jpeg':
      return 'image/jpeg';
    case '.gif':
      return 'image/gif';
    case '.bmp':
      return 'image/bmp';
    case '.webp':
      return 'image/webp';
    case '.svg':
      return 'image/svg+xml';
    default:
      return 'application/octet-stream';
  }
};

const walk = async (dir) => {
  const entries = await fs.promises.readdir(dir, { withFileTypes: true });
  const files = await Promise.all(
    entries.map(async (entry) => {
      const resolved = path.resolve(dir, entry.name);
      if (entry.isDirectory()) {
        return walk(resolved);
      }
      return resolved;
    }),
  );
  return files.flat();
};

async function main() {
  const relativeAssetsDir = process.argv[2] || '../ECommerce/assets';
  const assetsDir = path.resolve(__dirname, relativeAssetsDir);

  console.log(`📂 Using assets directory: ${assetsDir}`);

  if (!fs.existsSync(assetsDir)) {
    console.error(`❌ Directory not found: ${assetsDir}`);
    process.exit(1);
  }

  if (!process.env.AWS_S3_BUCKET) {
    console.error('❌ AWS_S3_BUCKET is not set. Please configure AWS credentials before running this script.');
    process.exit(1);
  }

  const allFiles = await walk(assetsDir);
  const imageFiles = allFiles.filter((file) => IMAGE_EXTENSIONS.has(path.extname(file).toLowerCase()));

  if (!imageFiles.length) {
    console.log('ℹ️ No image files detected for upload.');
    return;
  }

  console.log(`🖼 Found ${imageFiles.length} image files, uploading to bucket "${process.env.AWS_S3_BUCKET}"...`);

  const results = [];
  let successCount = 0;
  let failureCount = 0;

  for (const filePath of imageFiles) {
    const relativePath = path.relative(assetsDir, filePath).replace(/\\/g, '/');
    const buffer = await fs.promises.readFile(filePath);
    const mimetype = guessMimeType(filePath);

    try {
      const { key, url } = await uploadBufferToS3({
        buffer,
        mimetype,
        folder: 'assets',
        originalName: path.basename(filePath),
      });

      results.push({ localPath: relativePath, s3Key: key, url });
      successCount += 1;
      console.log(`✅ ${relativePath} → ${url}`);
    } catch (err) {
      failureCount += 1;
      console.error(`❌ Failed ${relativePath}: ${err.message || err}`);
    }
  }

  console.log('-------------------------------------------------');
  console.log(`✔️ Upload finished. Success: ${successCount}, Failed: ${failureCount}`);
  console.log('📄 Mapping (localPath → S3 URL):');
  console.log(JSON.stringify(results, null, 2));
}

main().catch((err) => {
  console.error('Unexpected error:', err);
  process.exit(1);
});


