import { initializeApp } from "firebase/app";
import { getAuth, createUserWithEmailAndPassword } from "firebase/auth";
import { getFirestore, doc, setDoc, Timestamp } from "firebase/firestore";

// Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyAwhNSVlZXBcT39LPRgZ1ofamOpsHuNGT0",
  authDomain: "interviewapp-36272.firebaseapp.com",
  projectId: "interviewapp-36272",
  storageBucket: "interviewapp-36272.firebasestorage.app",
  messagingSenderId: "945431547501",
  appId: "1:945431547501:web:da8005f9c3e6f598bb7964",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// Admin account details - CẬP NHẬT THÔNG TIN NÀY THEO Ý BẠN
const ADMIN_EMAIL = "admin@interviewapp.com";
const ADMIN_PASSWORD = "admin123456";
const ADMIN_DISPLAY_NAME = "Admin User";

async function createDefaultAdmin() {
  try {
    console.log("\n🔐 === TẠO TÀI KHOẢN ADMIN MẶC ĐỊNH ===\n");
    console.log("📧 Email:", ADMIN_EMAIL);
    console.log("👤 Display Name:", ADMIN_DISPLAY_NAME);
    console.log("\n⏳ Đang tạo tài khoản admin...\n");

    // Create user in Firebase Authentication
    const userCredential = await createUserWithEmailAndPassword(
      auth,
      ADMIN_EMAIL,
      ADMIN_PASSWORD,
    );
    const user = userCredential.user;

    console.log("✅ Tạo tài khoản Firebase Authentication thành công!");
    console.log(`   User UID: ${user.uid}`);

    // Create user document in Firestore with admin role
    const userData = {
      uid: user.uid,
      email: ADMIN_EMAIL,
      displayName: ADMIN_DISPLAY_NAME,
      role: "admin",
      isAdmin: true,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      sessionIds: [],
    };

    await setDoc(doc(db, "users", user.uid), userData);

    console.log("✅ Tạo user document trong Firestore thành công!");
    console.log("\n🎉 === TẠO ADMIN ACCOUNT THÀNH CÔNG ===\n");
    console.log("📋 Thông tin đăng nhập:");
    console.log("   ═══════════════════════════════════");
    console.log(`   📧 Email: ${ADMIN_EMAIL}`);
    console.log(`   🔒 Password: ${ADMIN_PASSWORD}`);
    console.log("   ═══════════════════════════════════");
    console.log(`   👤 Display Name: ${ADMIN_DISPLAY_NAME}`);
    console.log(`   🆔 UID: ${user.uid}`);
    console.log(`   👑 Role: admin`);
    console.log("\n✨ Bạn có thể đăng nhập vào web admin với thông tin trên!");
    console.log("💡 URL web admin: http://localhost:5173\n");
  } catch (error) {
    console.error("\n❌ Lỗi khi tạo admin account:");
    if (error.code === "auth/email-already-in-use") {
      console.error("   ⚠️  Email này đã được sử dụng!");
      console.error("   💡 Nếu bạn đã tạo admin rồi, hãy sử dụng thông tin:");
      console.error(`      📧 Email: ${ADMIN_EMAIL}`);
      console.error(`      🔒 Password: ${ADMIN_PASSWORD}`);
    } else if (error.code === "auth/invalid-email") {
      console.error("   Email không hợp lệ!");
    } else if (error.code === "auth/weak-password") {
      console.error("   Mật khẩu quá yếu!");
    } else {
      console.error(`   ${error.message}`);
    }
  } finally {
    process.exit();
  }
}

// Run the script
createDefaultAdmin();
