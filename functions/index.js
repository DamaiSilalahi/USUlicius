const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");
admin.initializeApp();

const sendGridApiKey = defineSecret("SENDGRID_API_KEY");

exports.sendOtpEmail = onCall({ secrets: [sendGridApiKey] }, async (request) => {
  sgMail.setApiKey(sendGridApiKey.value());

  const email = request.data.email;

  if (!email) {
    throw new HttpsError("invalid-argument", "Email wajib diisi.");
  }

  const otpCode = Math.floor(1000 + Math.random() * 9000).toString();

  const expiresAt = Date.now() + (5 * 60 * 1000); // 5 menit

  try {
    await admin.firestore().collection("otp_codes").doc(email).set({
      code: otpCode,
      expiresAt: expiresAt,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (err) {
    console.error("Gagal menyimpan ke Firestore:", err);
    throw new HttpsError("internal", "Gagal menyimpan kode OTP.");
  }

  const msg = {
    to: email,
    from: "asnalaia99@gmail.com",
    subject: "Kode Verifikasi USULicius",
    text: `Kode OTP Anda: ${otpCode}`,
    html: `
      <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
        <h2>Verifikasi Email USULicius</h2>
        <p>Masukkan kode 4 digit ini di aplikasi:</p>
        <h1 style="color: #800020; letter-spacing: 8px; font-size: 3em; margin: 20px 0;">${otpCode}</h1>
        <p>Kode berlaku 5 menit.</p>
      </div>
    `,
  };

  try {
    await sgMail.send(msg);
    return { success: true, message: "Email OTP berhasil dikirim." };
  } catch (error) {
    console.error("Error SendGrid:", error);
    throw new HttpsError("internal", "Gagal mengirim email.");
  }
});

exports.verifyOtp = onCall(async (request) => {
  const email = request.data.email;
  const userCode = request.data.code;

  if (!email || !userCode) {
    throw new HttpsError("invalid-argument", "Data tidak lengkap.");
  }

  const docRef = admin.firestore().collection("otp_codes").doc(email);
  const doc = await docRef.get();

  if (!doc.exists) {
    return { success: false, message: "Kode tidak ditemukan." };
  }

  const otpData = doc.data();

  if (Date.now() > otpData.expiresAt) {
    return { success: false, message: "Kode sudah kadaluarsa." };
  }

  if (String(otpData.code) !== String(userCode)) {
    return { success: false, message: "Kode salah." };
  }

  await docRef.delete();

  return { success: true, message: "Verifikasi berhasil!" };
});