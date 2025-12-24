import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { createUserWithEmailAndPassword } from 'firebase/auth';
import { doc, setDoc } from 'firebase/firestore';
import { auth, db } from '../config/firebase';
import { Shield, Mail, Lock, User, AlertCircle } from 'lucide-react';

const Register = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    adminCode: ''
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  // Admin registration code - Change this to your secret code
  const ADMIN_REGISTRATION_CODE = 'ADMIN2024';

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    // Validation
    if (formData.password !== formData.confirmPassword) {
      setError('Mật khẩu không khớp');
      return;
    }

    if (formData.password.length < 6) {
      setError('Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }

    if (formData.adminCode !== ADMIN_REGISTRATION_CODE) {
      setError('Mã đăng ký Admin không đúng');
      return;
    }

    setLoading(true);

    try {
      // Create user in Firebase Auth
      const userCredential = await createUserWithEmailAndPassword(
        auth,
        formData.email,
        formData.password
      );

      // Create admin user document in Firestore
      await setDoc(doc(db, 'admins', userCredential.user.uid), {
        name: formData.name,
        email: formData.email,
        role: 'admin',
        isAdmin: true,
        createdAt: new Date(),
        createdBy: 'self-registration'
      });

      // Also add to users collection for compatibility
      await setDoc(doc(db, 'users', userCredential.user.uid), {
        name: formData.name,
        email: formData.email,
        role: 'admin',
        isAdmin: true,
        createdAt: new Date(),
        userType: 'admin'
      });

      // Success - redirect to login
      navigate('/login', { 
        state: { message: 'Đăng ký thành công! Vui lòng đăng nhập.' } 
      });
    } catch (error) {
      console.error('Registration error:', error);
      
      switch (error.code) {
        case 'auth/email-already-in-use':
          setError('Email đã được sử dụng');
          break;
        case 'auth/invalid-email':
          setError('Email không hợp lệ');
          break;
        case 'auth/weak-password':
          setError('Mật khẩu quá yếu');
          break;
        default:
          setError('Đăng ký thất bại: ' + error.message);
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-600 to-primary-800 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full">
        {/* Logo & Title */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-white rounded-full mb-4">
            <Shield className="w-10 h-10 text-primary-600" />
          </div>
          <h2 className="text-3xl font-bold text-white mb-2">
            Đăng ký Admin
          </h2>
          <p className="text-primary-100">
            Tạo tài khoản quản trị viên mới
          </p>
        </div>

        {/* Registration Form */}
        <div className="bg-white rounded-lg shadow-2xl p-8">
          {error && (
            <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start">
              <AlertCircle className="w-5 h-5 text-red-600 mr-2 flex-shrink-0 mt-0.5" />
              <span className="text-sm text-red-800">{error}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Name */}
            <div>
              <label className="label">
                <User className="w-4 h-4 mr-2" />
                Họ và tên
              </label>
              <input
                type="text"
                name="name"
                value={formData.name}
                onChange={handleChange}
                required
                className="input mt-1"
                placeholder="Nguyễn Văn A"
              />
            </div>

            {/* Email */}
            <div>
              <label className="label">
                <Mail className="w-4 h-4 mr-2" />
                Email
              </label>
              <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                required
                className="input mt-1"
                placeholder="admin@example.com"
              />
            </div>

            {/* Password */}
            <div>
              <label className="label">
                <Lock className="w-4 h-4 mr-2" />
                Mật khẩu
              </label>
              <input
                type="password"
                name="password"
                value={formData.password}
                onChange={handleChange}
                required
                minLength={6}
                className="input mt-1"
                placeholder="Ít nhất 6 ký tự"
              />
            </div>

            {/* Confirm Password */}
            <div>
              <label className="label">
                <Lock className="w-4 h-4 mr-2" />
                Xác nhận mật khẩu
              </label>
              <input
                type="password"
                name="confirmPassword"
                value={formData.confirmPassword}
                onChange={handleChange}
                required
                className="input mt-1"
                placeholder="Nhập lại mật khẩu"
              />
            </div>

            {/* Admin Code */}
            <div>
              <label className="label">
                <Shield className="w-4 h-4 mr-2" />
                Mã đăng ký Admin
              </label>
              <input
                type="text"
                name="adminCode"
                value={formData.adminCode}
                onChange={handleChange}
                required
                className="input mt-1"
                placeholder="Nhập mã bảo mật"
              />
              <p className="text-xs text-gray-500 mt-1">
                Liên hệ quản trị hệ thống để lấy mã này
              </p>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={loading}
              className="btn btn-primary btn-lg w-full"
            >
              {loading ? (
                <div className="flex items-center justify-center">
                  <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                  Đang đăng ký...
                </div>
              ) : (
                'Đăng ký'
              )}
            </button>
          </form>

          {/* Link to Login */}
          <div className="mt-6 text-center">
            <p className="text-sm text-gray-600">
              Đã có tài khoản?{' '}
              <Link to="/login" className="text-primary-600 hover:text-primary-700 font-medium">
                Đăng nhập ngay
              </Link>
            </p>
          </div>
        </div>

        {/* Security Notice */}
        <div className="mt-6 text-center">
          <p className="text-xs text-primary-100">
            🔒 Tài khoản admin có toàn quyền truy cập hệ thống
          </p>
        </div>
      </div>
    </div>
  );
};

export default Register;
