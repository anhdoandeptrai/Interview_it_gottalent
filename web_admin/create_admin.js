import { initializeApp } from "firebase/app";
import { getAuth, createUserWithEmailAndPassword } from "firebase/auth";
import { getFirestore, doc, setDoc, Timestamp } from "firebase/firestore";
import * as readline from "readline";

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

// Create readline interface for user input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

const question = (query) =>
  new Promise((resolve) => rl.question(query, resolve));

async function createAdminAccount() {
  try {
    console.log("\n🔐 === TẠO TÀI KHOẢN ADMIN MỚI ===\n");

    // Get admin details from user
    const email = await question("📧 Nhập email admin: ");
    const password = await question("🔒 Nhập mật khẩu (tối thiểu 6 ký tự): ");
    const displayName = await question("👤 Nhập tên hiển thị: ");

    if (!email || !password || !displayName) {
      throw new Error("Vui lòng nhập đầy đủ thông tin!");
    }

    if (password.length < 6) {
      throw new Error("Mật khẩu phải có ít nhất 6 ký tự!");
    }

    console.log("\n⏳ Đang tạo tài khoản admin...\n");

    // Create user in Firebase Authentication
    const userCredential = await createUserWithEmailAndPassword(
      auth,
      email,
      password,
    );
    const user = userCredential.user;

    console.log("✅ Tạo tài khoản Firebase Authentication thành công!");
    console.log(`   User UID: ${user.uid}`);

    // Create user document in Firestore with admin role
    const userData = {
      uid: user.uid,
      email: email,
      displayName: displayName,
      role: "admin",
      isAdmin: true,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      sessionIds: [],
    };

    await setDoc(doc(db, "users", user.uid), userData);

    console.log("✅ Tạo user document trong Firestore thành công!");
    console.log("\n🎉 === TẠO ADMIN ACCOUNT THÀNH CÔNG ===\n");
    console.log("📋 Thông tin tài khoản:");
    console.log(`   Email: ${email}`);
    console.log(`   Display Name: ${displayName}`);
    console.log(`   UID: ${user.uid}`);
    console.log(`   Role: admin`);
    console.log(
      "\n✨ Bạn có thể đăng nhập vào web admin với thông tin trên!\n",
    );
  } catch (error) {
    console.error("\n❌ Lỗi khi tạo admin account:");
    if (error.code === "auth/email-already-in-use") {
      console.error("   Email này đã được sử dụng!");
    } else if (error.code === "auth/invalid-email") {
      console.error("   Email không hợp lệ!");
    } else if (error.code === "auth/weak-password") {
      console.error("   Mật khẩu quá yếu!");
    } else {
      console.error(`   ${error.message}`);
    }
  } finally {
    rl.close();
    process.exit();
  }
}

// Run the script
createAdminAccount();
