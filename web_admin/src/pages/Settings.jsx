import { useState } from 'react';
import { Save, Database, Bell, Shield, Mail } from 'lucide-react';

const Settings = () => {
  const [settings, setSettings] = useState({
    siteName: 'Interview Admin',
    emailNotifications: true,
    pushNotifications: false,
    autoBackup: true,
    backupFrequency: 'daily',
    maintenanceMode: false,
    allowRegistration: true,
    requireEmailVerification: true
  });

  const [saved, setSaved] = useState(false);

  const handleChange = (key, value) => {
    setSettings(prev => ({
      ...prev,
      [key]: value
    }));
  };

  const handleSave = async () => {
    // In a real app, save to database
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Cài đặt hệ thống</h1>
        <p className="mt-1 text-sm text-gray-600">
          Quản lý cấu hình và tùy chọn hệ thống
        </p>
      </div>

      {/* General Settings */}
      <div className="card">
        <div className="flex items-center mb-4">
          <Database className="w-5 h-5 text-primary-600 mr-2" />
          <h2 className="text-lg font-semibold text-gray-900">
            Cài đặt chung
          </h2>
        </div>

        <div className="space-y-4">
          <div>
            <label className="label">Tên hệ thống</label>
            <input
              type="text"
              value={settings.siteName}
              onChange={(e) => handleChange('siteName', e.target.value)}
              className="input mt-1"
            />
          </div>

          <div className="flex items-center justify-between py-3 border-t">
            <div>
              <p className="font-medium text-gray-900">Chế độ bảo trì</p>
              <p className="text-sm text-gray-600">
                Tạm dừng truy cập hệ thống cho người dùng
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.maintenanceMode}
                onChange={(e) => handleChange('maintenanceMode', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
            </label>
          </div>

          <div className="flex items-center justify-between py-3 border-t">
            <div>
              <p className="font-medium text-gray-900">Cho phép đăng ký</p>
              <p className="text-sm text-gray-600">
                Người dùng mới có thể tự đăng ký tài khoản
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.allowRegistration}
                onChange={(e) => handleChange('allowRegistration', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
            </label>
          </div>

          <div className="flex items-center justify-between py-3 border-t">
            <div>
              <p className="font-medium text-gray-900">Yêu cầu xác thực email</p>
              <p className="text-sm text-gray-600">
                Người dùng mới phải xác thực email trước khi sử dụng
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.requireEmailVerification}
                onChange={(e) => handleChange('requireEmailVerification', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
            </label>
          </div>
        </div>
      </div>

      {/* Notifications */}
      <div className="card">
        <div className="flex items-center mb-4">
          <Bell className="w-5 h-5 text-primary-600 mr-2" />
          <h2 className="text-lg font-semibold text-gray-900">
            Thông báo
          </h2>
        </div>

        <div className="space-y-4">
          <div className="flex items-center justify-between py-3">
            <div>
              <p className="font-medium text-gray-900">Thông báo Email</p>
              <p className="text-sm text-gray-600">
                Nhận thông báo qua email về hoạt động quan trọng
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.emailNotifications}
                onChange={(e) => handleChange('emailNotifications', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
            </label>
          </div>

          <div className="flex items-center justify-between py-3 border-t">
            <div>
              <p className="font-medium text-gray-900">Thông báo Push</p>
              <p className="text-sm text-gray-600">
                Nhận thông báo push về sự kiện hệ thống
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.pushNotifications}
                onChange={(e) => handleChange('pushNotifications', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
            </label>
          </div>
        </div>
      </div>

      {/* Backup Settings */}
      <div className="card">
        <div className="flex items-center mb-4">
          <Shield className="w-5 h-5 text-primary-600 mr-2" />
          <h2 className="text-lg font-semibold text-gray-900">
            Sao lưu dữ liệu
          </h2>
        </div>

        <div className="space-y-4">
          <div className="flex items-center justify-between py-3">
            <div>
              <p className="font-medium text-gray-900">Tự động sao lưu</p>
              <p className="text-sm text-gray-600">
                Tự động sao lưu dữ liệu theo lịch định kỳ
              </p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={settings.autoBackup}
                onChange={(e) => handleChange('autoBackup', e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
            </label>
          </div>

          {settings.autoBackup && (
            <div>
              <label className="label">Tần suất sao lưu</label>
              <select
                value={settings.backupFrequency}
                onChange={(e) => handleChange('backupFrequency', e.target.value)}
                className="input mt-1"
              >
                <option value="hourly">Mỗi giờ</option>
                <option value="daily">Mỗi ngày</option>
                <option value="weekly">Mỗi tuần</option>
                <option value="monthly">Mỗi tháng</option>
              </select>
            </div>
          )}
        </div>
      </div>

      {/* Save Button */}
      <div className="flex justify-end gap-3">
        {saved && (
          <div className="flex items-center text-green-600">
            <span className="text-sm font-medium">Đã lưu thành công!</span>
          </div>
        )}
        <button
          onClick={handleSave}
          className="btn btn-primary btn-md"
        >
          <Save className="w-5 h-5 mr-2" />
          Lưu cài đặt
        </button>
      </div>

      {/* Info */}
      <div className="card bg-blue-50 border-blue-200">
        <div className="flex items-start">
          <Mail className="w-5 h-5 text-blue-600 mr-3 mt-0.5" />
          <div>
            <h3 className="font-semibold text-blue-900 mb-1">Thông tin</h3>
            <p className="text-sm text-blue-700">
              Các cài đặt này sẽ ảnh hưởng đến toàn bộ hệ thống. 
              Vui lòng cân nhắc kỹ trước khi thay đổi.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Settings;
