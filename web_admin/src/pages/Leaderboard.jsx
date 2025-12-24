import { useState, useEffect } from 'react';
import { Trophy, Medal, Award, TrendingUp, Users } from 'lucide-react';
import { getLeaderboard } from '../services/api';

const Leaderboard = () => {
  const [leaderboard, setLeaderboard] = useState([]);
  const [loading, setLoading] = useState(true);
  const [period, setPeriod] = useState('month');
  const [mode, setMode] = useState(null);

  useEffect(() => {
    loadLeaderboard();
  }, [period, mode]);

  const loadLeaderboard = async () => {
    try {
      setLoading(true);
      const data = await getLeaderboard(period, mode);
      setLeaderboard(data);
    } catch (error) {
      console.error('Error loading leaderboard:', error);
    } finally {
      setLoading(false);
    }
  };

  const getRankIcon = (rank) => {
    if (rank === 1) return <Trophy className="w-6 h-6 text-yellow-500" />;
    if (rank === 2) return <Medal className="w-6 h-6 text-gray-400" />;
    if (rank === 3) return <Medal className="w-6 h-6 text-amber-700" />;
    return <span className="text-gray-600 font-semibold">#{rank}</span>;
  };

  const getRankBadge = (rank) => {
    if (rank === 1) return 'bg-gradient-to-r from-yellow-400 to-yellow-600 text-white';
    if (rank === 2) return 'bg-gradient-to-r from-gray-300 to-gray-500 text-white';
    if (rank === 3) return 'bg-gradient-to-r from-amber-600 to-amber-800 text-white';
    return 'bg-white border-2 border-gray-200';
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Bảng xếp hạng</h1>
          <p className="mt-1 text-sm text-gray-600">
            Top người dùng xuất sắc nhất
          </p>
        </div>
        <Trophy className="w-12 h-12 text-yellow-500" />
      </div>

      {/* Filters */}
      <div className="card">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
          <div className="flex items-center gap-2">
            <label className="text-sm font-medium text-gray-700">Thời gian:</label>
            <select
              value={period}
              onChange={(e) => setPeriod(e.target.value)}
              className="input"
            >
              <option value="week">Tuần này</option>
              <option value="month">Tháng này</option>
              <option value="year">Năm này</option>
              <option value="all">Toàn thời gian</option>
            </select>
          </div>

          <div className="flex items-center gap-2">
            <label className="text-sm font-medium text-gray-700">Chế độ:</label>
            <select
              value={mode || 'all'}
              onChange={(e) => setMode(e.target.value === 'all' ? null : e.target.value)}
              className="input"
            >
              <option value="all">Tất cả</option>
              <option value="interview">Phỏng vấn</option>
              <option value="presentation">Thuyết trình</option>
            </select>
          </div>
        </div>
      </div>

      {/* Top 3 Podium */}
      {leaderboard.length >= 3 && (
        <div className="grid grid-cols-3 gap-4 max-w-4xl mx-auto">
          {/* Second Place */}
          <div className="flex flex-col items-center pt-12">
            <div className={`${getRankBadge(2)} w-full p-6 rounded-lg shadow-lg text-center`}>
              <Medal className="w-8 h-8 mx-auto mb-2 text-gray-100" />
              <div className="h-16 w-16 mx-auto rounded-full bg-white flex items-center justify-center mb-3">
                <span className="text-2xl font-bold text-gray-700">
                  {leaderboard[1].userName?.charAt(0).toUpperCase()}
                </span>
              </div>
              <h3 className="font-bold text-lg mb-1 truncate">
                {leaderboard[1].userName}
              </h3>
              <p className="text-2xl font-bold mb-2">
                {(leaderboard[1].avgScore * 100).toFixed(0)}%
              </p>
              <p className="text-sm opacity-90">
                {leaderboard[1].totalSessions} phiên
              </p>
            </div>
          </div>

          {/* First Place */}
          <div className="flex flex-col items-center">
            <div className={`${getRankBadge(1)} w-full p-6 rounded-lg shadow-2xl text-center transform scale-110`}>
              <Trophy className="w-10 h-10 mx-auto mb-2" />
              <div className="h-20 w-20 mx-auto rounded-full bg-white flex items-center justify-center mb-3 ring-4 ring-white/50">
                <span className="text-3xl font-bold text-yellow-600">
                  {leaderboard[0].userName?.charAt(0).toUpperCase()}
                </span>
              </div>
              <h3 className="font-bold text-xl mb-1 truncate">
                {leaderboard[0].userName}
              </h3>
              <p className="text-3xl font-bold mb-2">
                {(leaderboard[0].avgScore * 100).toFixed(0)}%
              </p>
              <p className="text-sm opacity-90">
                {leaderboard[0].totalSessions} phiên
              </p>
            </div>
          </div>

          {/* Third Place */}
          <div className="flex flex-col items-center pt-12">
            <div className={`${getRankBadge(3)} w-full p-6 rounded-lg shadow-lg text-center`}>
              <Medal className="w-8 h-8 mx-auto mb-2 text-amber-100" />
              <div className="h-16 w-16 mx-auto rounded-full bg-white flex items-center justify-center mb-3">
                <span className="text-2xl font-bold text-amber-700">
                  {leaderboard[2].userName?.charAt(0).toUpperCase()}
                </span>
              </div>
              <h3 className="font-bold text-lg mb-1 truncate">
                {leaderboard[2].userName}
              </h3>
              <p className="text-2xl font-bold mb-2">
                {(leaderboard[2].avgScore * 100).toFixed(0)}%
              </p>
              <p className="text-sm opacity-90">
                {leaderboard[2].totalSessions} phiên
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Full Leaderboard Table */}
      <div className="card overflow-hidden p-0">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Hạng
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Người dùng
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Email
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Số phiên
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Điểm TB
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Điểm cao nhất
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {leaderboard.map((user, index) => (
                <tr key={user.userId} className={`
                  hover:bg-gray-50
                  ${index < 3 ? 'bg-gradient-to-r from-yellow-50/30 to-transparent' : ''}
                `}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center justify-center w-10">
                      {getRankIcon(index + 1)}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-10 w-10">
                        <div className="h-10 w-10 rounded-full bg-primary-100 flex items-center justify-center">
                          <span className="text-primary-700 font-semibold text-sm">
                            {user.userName?.charAt(0).toUpperCase()}
                          </span>
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">
                          {user.userName}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {user.userEmail}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center text-sm text-gray-900">
                      <Users className="w-4 h-4 mr-2 text-gray-400" />
                      {user.totalSessions}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <Award className="w-4 h-4 mr-2 text-primary-500" />
                      <span className="text-sm font-semibold text-gray-900">
                        {(user.avgScore * 100).toFixed(1)}%
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <TrendingUp className="w-4 h-4 mr-2 text-green-500" />
                      <span className="text-sm font-semibold text-gray-900">
                        {(user.bestScore * 100).toFixed(1)}%
                      </span>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {leaderboard.length === 0 && (
          <div className="text-center py-12">
            <Trophy className="w-16 h-16 text-gray-300 mx-auto mb-4" />
            <p className="text-gray-500">Chưa có dữ liệu xếp hạng</p>
          </div>
        )}
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-3">
        <div className="card">
          <p className="text-sm font-medium text-gray-600">Tổng người tham gia</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">{leaderboard.length}</p>
        </div>
        <div className="card">
          <p className="text-sm font-medium text-gray-600">Điểm TB hệ thống</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">
            {leaderboard.length > 0
              ? ((leaderboard.reduce((sum, u) => sum + u.avgScore, 0) / leaderboard.length) * 100).toFixed(0)
              : 0
            }%
          </p>
        </div>
        <div className="card">
          <p className="text-sm font-medium text-gray-600">Tổng phiên luyện tập</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">
            {leaderboard.reduce((sum, u) => sum + u.totalSessions, 0)}
          </p>
        </div>
      </div>
    </div>
  );
};

export default Leaderboard;
