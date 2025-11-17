// utils/sendEmail.js
const nodemailer = require("nodemailer");
const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");

const host = process.env.EMAIL_HOST;
const port = parseInt(process.env.EMAIL_PORT || "587", 10);
const user = process.env.EMAIL_USER;
const pass = process.env.EMAIL_PASS;
const emailFrom = process.env.EMAIL_FROM || user;

let transporter = null;
if (host && port && user && pass) {
  transporter = nodemailer.createTransport({
    host,
    port,
    secure: port === 465, // true for 465, false for other ports (use STARTTLS)
    auth: {
      user,
      pass,
    },
    tls: {
      rejectUnauthorized: process.env.NODE_ENV === "production",
    },
  });

  transporter
    .verify()
    .then(() => console.log("✅ SMTP connection verified"))
    .catch((err) =>
      console.error("❌ SMTP connection failed:", err && err.message ? err.message : err)
    );
} else {
  console.warn("SMTP config incomplete. Looking for AWS SES fallback...");
}

const sesRegion = process.env.AWS_SES_REGION || process.env.AWS_REGION;
const sesCredentials =
  process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY
    ? {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      }
    : undefined;

let sesClient = null;
const sesSender = process.env.AWS_SES_FROM || emailFrom;
if (sesRegion && sesSender) {
  sesClient = new SESClient({
    region: sesRegion,
    credentials: sesCredentials,
  });
  console.log("📨 AWS SES client configured");
}

if (!transporter && !sesClient) {
  console.warn(
    "⚠️  No email provider configured. Set SMTP (EMAIL_HOST/PORT/USER/PASS) or AWS SES environment variables."
  );
}

/**
 * sendEmail
 * @param {string} to - recipient email
 * @param {string} subject
 * @param {string} textOrHtml - plaintext or HTML (if html param is omitted)
 * @param {object} [opts] - optional { html, text }
 */
async function sendEmail(to, subject, textOrHtml, opts = {}) {
  try {
    const textContent = opts.text || (!opts.html ? textOrHtml : undefined);
    const htmlContent = opts.html || (opts.text ? undefined : textOrHtml);

    if (transporter) {
      const mailOptions = {
        from: emailFrom,
        to,
        subject,
        text: textContent,
        html: htmlContent,
      };

      const info = await transporter.sendMail(mailOptions);
      console.log(`📧 Email sent via SMTP to ${to} (messageId: ${info.messageId})`);
      return info;
    }

    if (sesClient) {
      const command = new SendEmailCommand({
        Destination: { ToAddresses: [to] },
        Source: sesSender,
        Message: {
          Subject: { Data: subject, Charset: "UTF-8" },
          Body: {
            ...(htmlContent ? { Html: { Data: htmlContent, Charset: "UTF-8" } } : {}),
            ...(textContent ? { Text: { Data: textContent, Charset: "UTF-8" } } : {}),
          },
        },
      });

      const response = await sesClient.send(command);
      console.log(`📧 Email sent via SES to ${to} (messageId: ${response.MessageId})`);
      return response;
    }

    throw new Error("Email service not configured");
  } catch (err) {
    // Log full error for debugging (do NOT expose to clients)
    console.error("Email send error:", err);
    // Re-throw so caller (route) can return proper HTTP status
    throw err;
  }
}

module.exports = sendEmail;
