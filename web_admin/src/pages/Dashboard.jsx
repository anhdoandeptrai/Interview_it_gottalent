import { useState, useEffect } from 'react';
import { 
  Users as UsersIcon, 
  MessageSquare, 
  History, 
  TrendingUp,
  Award,
  Clock
} from 'lucide-react';
import { 
  LineChart, 
  Line, 
  BarChart,
  Bar,
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  Legend,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell
} from 'recharts';
import { getStatistics, getSessions, getUsers } from '../services/api';
import { format, subDays, startOfDay } from 'date-fns';

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalSessions: 0,
    totalQuestions: 0,
    activeUsers: 0,
    avgScore: 0
  });
  const [loading, setLoading] = useState(true);
  const [activityData, setActivityData] = useState([]);
  const [modeData, setModeData] = useState([]);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      
      // Get statistics
      const statistics = await getStatistics();
      setStats(statistics);

      // Get recent sessions for activity chart
      const sessions = await getSessions({ limit: 100 });
      
      // Group by date
      const last7Days = Array.from({ length: 7 }, (_, i) => {
        const date = subDays(new Date(), 6 - i);
        return {
          date: format(date, 'MM/dd'),
          fullDate: startOfDay(date),
          sessions: 0
        };
      });

      sessions.forEach(session => {
        const sessionDate = startOfDay(session.startTime?.toDate() || new Date());
        const dayData = last7Days.find(d => 
          d.fullDate.getTime() === sessionDate.getTime()
        );
        if (dayData) {
          dayData.sessions++;
        }
      });

      setActivityData(last7Days);

      // Mode distribution
      const modeCounts = { interview: 0, presentation: 0 };
      sessions.forEach(session => {
        if (session.mode === 'interview') modeCounts.interview++;
        else if (session.mode === 'presentation') modeCounts.presentation++;
      });

      setModeData([
        { name: 'Phỏng vấn', value: modeCounts.interview, color: '#0ea5e9' },
        { name: 'Thuyết trình', value: modeCounts.presentation, color: '#8b5cf6' }
      ]);

    } catch (error) {
      console.error('Error loading dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  const statCards = [
    {
      title: 'Tổng người dùng',
      value: stats.totalUsers,
      icon: UsersIcon,
      color: 'bg-blue-500',
      change: '+12%'
    },
    {
      title: 'Phiên luyện tập',
      value: stats.totalSessions,
      icon: History,
      color: 'bg-green-500',
      change: '+23%'
    },
    {
      title: 'Câu hỏi',
      value: stats.totalQuestions,
      icon: MessageSquare,
      color: 'bg-purple-500',
      change: '+8%'
    },
    {
      title: 'Điểm trung bình',
      value: (stats.avgScore * 100).toFixed(1) + '%',
      icon: Award,
      color: 'bg-orange-500',
      change: '+5%'
    }
  ];

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
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="mt-1 text-sm text-gray-600">
          Tổng quan hệ thống và thống kê
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {statCards.map((stat, index) => (
          <div key={index} className="card">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">
                  {stat.title}
                </p>
                <p className="mt-2 text-3xl font-bold text-gray-900">
                  {stat.value}
                </p>
                <p className="mt-2 text-sm text-green-600">
                  {stat.change} so với tháng trước
                </p>
              </div>
              <div className={`${stat.color} p-3 rounded-lg`}>
                <stat.icon className="w-6 h-6 text-white" />
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        {/* Activity Chart */}
        <div className="card">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Hoạt động 7 ngày qua
          </h2>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={activityData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="date" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line 
                type="monotone" 
                dataKey="sessions" 
                stroke="#0ea5e9" 
                strokeWidth={2}
                name="Phiên luyện tập"
              />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* Mode Distribution */}
        <div className="card">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Phân bố theo chế độ
          </h2>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={modeData}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                outerRadius={100}
                fill="#8884d8"
                dataKey="value"
              >
                {modeData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Recent Activity */}
      <div className="card">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">
          Hoạt động gần đây
        </h2>
        <div className="space-y-4">
          <div className="flex items-center p-3 bg-gray-50 rounded-lg">
            <Clock className="w-5 h-5 text-gray-400 mr-3" />
            <div className="flex-1">
              <p className="text-sm font-medium text-gray-900">
                Người dùng mới đăng ký
              </p>
              <p className="text-xs text-gray-500">5 phút trước</p>
            </div>
          </div>
          <div className="flex items-center p-3 bg-gray-50 rounded-lg">
            <TrendingUp className="w-5 h-5 text-green-500 mr-3" />
            <div className="flex-1">
              <p className="text-sm font-medium text-gray-900">
                Phiên luyện tập hoàn thành
              </p>
              <p className="text-xs text-gray-500">15 phút trước</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
