const { S3Client, PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const crypto = require('crypto');
const path = require('path');

const bucket = process.env.AWS_S3_BUCKET;
const region = process.env.AWS_REGION;

if (!bucket) {
  console.warn('⚠️  AWS_S3_BUCKET is not set. Image uploads will fail until it is provided.');
}

const s3 = new S3Client({
  region,
  credentials:
    process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY
      ? {
          accessKeyId: process.env.AWS_ACCESS_KEY_ID,
          secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
        }
      : undefined, // falls back to default provider chain (useful for IAM roles)
});

const buildObjectKey = ({ folder = 'uploads', originalName = 'file', mimetype }) => {
  const safeName = originalName
    .replace(/\s+/g, '-')
    .replace(/[^a-zA-Z0-9.\-_]/g, '')
    .toLowerCase();
  const extFromMime = mimetype && mimetype.includes('/') ? mimetype.split('/')[1] : '';
  const extFromName = path.extname(safeName);
  const extension = (extFromName || (extFromMime ? `.${extFromMime}` : '') || '.bin').replace(/^\.+/, '.');

  return `${folder}/${Date.now()}-${crypto.randomUUID()}${extension}`;
};

const getPublicUrl = (key) => {
  if (!bucket || !key) return '';
  if (process.env.AWS_S3_PUBLIC_BASE_URL) {
    return `${process.env.AWS_S3_PUBLIC_BASE_URL.replace(/\/$/, '')}/${key}`;
  }

  if (region) {
    return `https://${bucket}.s3.${region}.amazonaws.com/${key}`;
  }

  return `https://${bucket}.s3.amazonaws.com/${key}`;
};

const uploadBufferToS3 = async ({ buffer, mimetype, folder, originalName }) => {
  if (!bucket) {
    throw new Error('AWS_S3_BUCKET is not configured.');
  }
  if (!buffer) {
    throw new Error('No file buffer provided for upload.');
  }

  const key = buildObjectKey({ folder, originalName, mimetype });
  const command = new PutObjectCommand({
    Bucket: bucket,
    Key: key,
    Body: buffer,
    ContentType: mimetype,
    ACL: 'public-read',
  });

  await s3.send(command);

  return { key, url: getPublicUrl(key) };
};

const deleteFromS3 = async (key) => {
  if (!bucket || !key) return;
  const command = new DeleteObjectCommand({
    Bucket: bucket,
    Key: key,
  });

  await s3.send(command);
};

const keyFromS3Url = (url = '') => {
  if (!url) return null;
  try {
    const parsedUrl = new URL(url);
    // Handle virtual-hosted–style and path-style URLs
    if (parsedUrl.hostname.startsWith(`${bucket}.s3`)) {
      return parsedUrl.pathname.replace(/^\/+/, '');
    }

    // If using custom domain, just return path
    return parsedUrl.pathname.replace(/^\/+/, '');
  } catch {
    return null;
  }
};

module.exports = {
  uploadBufferToS3,
  deleteFromS3,
  keyFromS3Url,
  getPublicUrl,
};


