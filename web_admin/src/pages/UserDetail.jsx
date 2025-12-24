import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { 
  ArrowLeft, 
  Mail, 
  Calendar,
  Award,
  TrendingUp,
  Clock,
  Target
} from 'lucide-react';
import { getUserById, getSessions } from '../services/api';
import { format } from 'date-fns';
import { 
  LineChart, 
  Line,
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer 
} from 'recharts';

const UserDetail = () => {
  const { userId } = useParams();
  const [user, setUser] = useState(null);
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    totalSessions: 0,
    avgScore: 0,
    bestScore: 0,
    totalTime: 0
  });

  useEffect(() => {
    loadUserData();
  }, [userId]);

  const loadUserData = async () => {
    try {
      setLoading(true);
      const [userData, sessionsData] = await Promise.all([
        getUserById(userId),
        getSessions({ userId })
      ]);

      setUser(userData);
      setSessions(sessionsData);

      // Calculate stats
      const totalSessions = sessionsData.length;
      let totalScore = 0;
      let bestScore = 0;
      let totalTime = 0;

      sessionsData.forEach(session => {
        const score = session.analytics?.averageScore || 0;
        totalScore += score;
        bestScore = Math.max(bestScore, score);
        
        if (session.analytics?.totalDuration) {
          totalTime += session.analytics.totalDuration.seconds || 0;
        }
      });

      setStats({
        totalSessions,
        avgScore: totalSessions > 0 ? totalScore / totalSessions : 0,
        bestScore,
        totalTime
      });
    } catch (error) {
      console.error('Error loading user data:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatDuration = (seconds) => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    return `${hours}h ${minutes}m`;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500">Không tìm thấy người dùng</p>
        <Link to="/users" className="btn btn-primary btn-sm mt-4">
          Quay lại
        </Link>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Back button */}
      <Link to="/users" className="inline-flex items-center text-gray-600 hover:text-gray-900">
        <ArrowLeft className="w-4 h-4 mr-2" />
        Quay lại danh sách
      </Link>

      {/* User Info */}
      <div className="card">
        <div className="flex items-start gap-6">
          <div className="flex-shrink-0">
            <div className="h-20 w-20 rounded-full bg-primary-100 flex items-center justify-center">
              <span className="text-primary-700 font-bold text-2xl">
                {user.displayName?.charAt(0).toUpperCase() || 'U'}
              </span>
            </div>
          </div>
          <div className="flex-1">
            <h1 className="text-2xl font-bold text-gray-900">
              {user.displayName || 'No name'}
            </h1>
            <div className="mt-2 space-y-2">
              <div className="flex items-center text-gray-600">
                <Mail className="w-4 h-4 mr-2" />
                {user.email}
              </div>
              <div className="flex items-center text-gray-600">
                <Calendar className="w-4 h-4 mr-2" />
                Tham gia {user.createdAt ? format(user.createdAt.toDate(), 'dd/MM/yyyy') : 'N/A'}
              </div>
            </div>
            <div className="mt-4">
              <span className={`badge ${user.role === 'admin' ? 'badge-info' : 'badge-success'}`}>
                {user.role === 'admin' ? 'Admin' : 'User'}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Tổng phiên</p>
              <p className="mt-2 text-3xl font-bold text-gray-900">
                {stats.totalSessions}
              </p>
            </div>
            <Target className="w-10 h-10 text-blue-500" />
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Điểm TB</p>
              <p className="mt-2 text-3xl font-bold text-gray-900">
                {(stats.avgScore * 100).toFixed(0)}%
              </p>
            </div>
            <Award className="w-10 h-10 text-green-500" />
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Điểm cao nhất</p>
              <p className="mt-2 text-3xl font-bold text-gray-900">
                {(stats.bestScore * 100).toFixed(0)}%
              </p>
            </div>
            <TrendingUp className="w-10 h-10 text-purple-500" />
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Thời gian</p>
              <p className="mt-2 text-3xl font-bold text-gray-900">
                {formatDuration(stats.totalTime)}
              </p>
            </div>
            <Clock className="w-10 h-10 text-orange-500" />
          </div>
        </div>
      </div>

      {/* Recent Sessions */}
      <div className="card">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">
          Lịch sử luyện tập gần đây
        </h2>
        <div className="space-y-3">
          {sessions.slice(0, 10).map((session) => (
            <Link
              key={session.id}
              to={`/sessions/${session.id}`}
              className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <div className="flex-1">
                <p className="font-medium text-gray-900">
                  {session.mode === 'interview' ? 'Phỏng vấn' : 'Thuyết trình'}
                </p>
                <p className="text-sm text-gray-500">
                  {session.startTime ? format(session.startTime.toDate(), 'dd/MM/yyyy HH:mm') : 'N/A'}
                </p>
              </div>
              <div className="text-right">
                <p className="text-lg font-semibold text-gray-900">
                  {((session.analytics?.averageScore || 0) * 100).toFixed(0)}%
                </p>
                <p className="text-sm text-gray-500">
                  {session.questions?.length || 0} câu hỏi
                </p>
              </div>
            </Link>
          ))}

          {sessions.length === 0 && (
            <p className="text-center text-gray-500 py-8">
              Chưa có phiên luyện tập nào
            </p>
          )}
        </div>
      </div>
    </div>
  );
};

export default UserDetail;
