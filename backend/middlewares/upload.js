const multer = require('multer');
const path = require('path');

// ✅ In-memory storage (supports Flutter Web & Mobile)
const storage = multer.memoryStorage();

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB max
  fileFilter: (req, file, cb) => {
    const allowed = /jpeg|jpg|png|webp|gif/;
    const ext = path.extname(file.originalname || '').toLowerCase();
    const mime = file.mimetype?.toLowerCase() || '';

    // ✅ Flutter Web sometimes sends 'application/octet-stream'
    if (mime === 'application/octet-stream') {
      console.log('⚠️ Flutter Web upload detected — skipping strict mimetype check.');
      return cb(null, true);
    }

    if (allowed.test(ext) || allowed.test(mime)) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'));
    }
  },
});

module.exports = upload;
