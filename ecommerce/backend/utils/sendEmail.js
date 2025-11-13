// utils/sendEmail.js
const nodemailer = require("nodemailer");

const host = process.env.EMAIL_HOST;
const port = parseInt(process.env.EMAIL_PORT || "587", 10);
const user = process.env.EMAIL_USER;
const pass = process.env.EMAIL_PASS;

if (!host || !port || !user || !pass) {
  console.warn("EMAIL config incomplete. Set EMAIL_HOST, EMAIL_PORT, EMAIL_USER, EMAIL_PASS in your .env");
}

const transporter = nodemailer.createTransport({
  host,
  port,
  secure: port === 465, // true for 465, false for other ports (use STARTTLS)
  auth: {
    user,
    pass,
  },
  // OPTIONAL: temporary debugging helper if you run into TLS issues.
  // Remove or set rejectUnauthorized: true in production.
  tls: {
    rejectUnauthorized: process.env.NODE_ENV === "production" ? true : false,
  },
});

// Verify connection at startup
transporter.verify()
  .then(() => console.log("✅ SMTP connection verified"))
  .catch((err) => console.error("❌ SMTP connection failed:", err && err.message ? err.message : err));

/**
 * sendEmail
 * @param {string} to - recipient email
 * @param {string} subject
 * @param {string} textOrHtml - plaintext or HTML (if html param is omitted)
 * @param {object} [opts] - optional { html, text }
 */
async function sendEmail(to, subject, textOrHtml, opts = {}) {
  try {
    const mailOptions = {
      from: user,
      to,
      subject,
      text: opts.text || (!opts.html ? textOrHtml : undefined),
      html: opts.html || (opts.text ? undefined : textOrHtml),
    };

    const info = await transporter.sendMail(mailOptions);
    console.log(`📧 Email sent to ${to} (messageId: ${info.messageId})`);
    return info;
  } catch (err) {
    // Log full error for debugging (do NOT expose to clients)
    console.error("Email send error:", err);
    // Re-throw so caller (route) can return proper HTTP status
    throw err;
  }
}

module.exports = sendEmail;
