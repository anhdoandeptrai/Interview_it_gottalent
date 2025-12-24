import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { 
  Search, 
  Filter,
  Eye,
  Calendar,
  Clock,
  Award
} from 'lucide-react';
import { getSessions } from '../services/api';
import { format } from 'date-fns';

const Sessions = () => {
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterMode, setFilterMode] = useState('all');
  const [filterDate, setFilterDate] = useState('all');

  useEffect(() => {
    loadSessions();
  }, []);

  const loadSessions = async () => {
    try {
      setLoading(true);
      const data = await getSessions();
      setSessions(data);
    } catch (error) {
      console.error('Error loading sessions:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredSessions = sessions.filter(session => {
    const matchesMode = filterMode === 'all' || session.mode === filterMode;
    
    // Date filter
    let matchesDate = true;
    if (filterDate !== 'all' && session.startTime) {
      const sessionDate = session.startTime.toDate();
      const now = new Date();
      
      if (filterDate === 'today') {
        matchesDate = sessionDate.toDateString() === now.toDateString();
      } else if (filterDate === 'week') {
        const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        matchesDate = sessionDate >= weekAgo;
      } else if (filterDate === 'month') {
        const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        matchesDate = sessionDate >= monthAgo;
      }
    }

    return matchesMode && matchesDate;
  });

  const formatDuration = (duration) => {
    if (!duration || !duration.seconds) return '0m';
    const minutes = Math.floor(duration.seconds / 60);
    return `${minutes}m`;
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
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Lịch sử phiên luyện tập</h1>
        <p className="mt-1 text-sm text-gray-600">
          Xem và quản lý tất cả phiên luyện tập
        </p>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="flex flex-col gap-4 sm:flex-row">
          <select
            value={filterMode}
            onChange={(e) => setFilterMode(e.target.value)}
            className="input"
          >
            <option value="all">Tất cả chế độ</option>
            <option value="interview">Phỏng vấn</option>
            <option value="presentation">Thuyết trình</option>
          </select>

          <select
            value={filterDate}
            onChange={(e) => setFilterDate(e.target.value)}
            className="input"
          >
            <option value="all">Tất cả thời gian</option>
            <option value="today">Hôm nay</option>
            <option value="week">7 ngày qua</option>
            <option value="month">30 ngày qua</option>
          </select>
        </div>
      </div>

      {/* Sessions List */}
      <div className="card overflow-hidden p-0">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ID Phiên
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Chế độ
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ngày giờ
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Câu hỏi
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Thời gian
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Điểm số
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Hành động
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredSessions.map((session) => (
                <tr key={session.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-mono text-gray-900">
                      #{session.id.slice(0, 8)}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`badge ${
                      session.mode === 'interview' ? 'badge-info' : 'badge-warning'
                    }`}>
                      {session.mode === 'interview' ? 'Phỏng vấn' : 'Thuyết trình'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center text-sm text-gray-500">
                      <Calendar className="w-4 h-4 mr-2" />
                      {session.startTime 
                        ? format(session.startTime.toDate(), 'dd/MM/yyyy HH:mm')
                        : 'N/A'
                      }
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {session.questions?.length || 0} câu
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center text-sm text-gray-500">
                      <Clock className="w-4 h-4 mr-2" />
                      {formatDuration(session.analytics?.totalDuration)}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <Award className="w-4 h-4 mr-2 text-yellow-500" />
                      <span className="text-sm font-semibold text-gray-900">
                        {((session.analytics?.averageScore || 0) * 100).toFixed(0)}%
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <Link
                      to={`/sessions/${session.id}`}
                      className="text-primary-600 hover:text-primary-900 inline-flex items-center"
                    >
                      <Eye className="w-4 h-4 mr-1" />
                      Chi tiết
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {filteredSessions.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-500">Không tìm thấy phiên luyện tập nào</p>
          </div>
        )}
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-4">
        <div className="card">
          <p className="text-sm font-medium text-gray-600">Tổng phiên</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">{sessions.length}</p>
        </div>
        <div className="card">
          <p className="text-sm font-medium text-gray-600">Phỏng vấn</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">
            {sessions.filter(s => s.mode === 'interview').length}
          </p>
        </div>
        <div className="card">
          <p className="text-sm font-medium text-gray-600">Thuyết trình</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">
            {sessions.filter(s => s.mode === 'presentation').length}
          </p>
        </div>
        <div className="card">
          <p className="text-sm font-medium text-gray-600">Điểm TB</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">
            {sessions.length > 0 
              ? ((sessions.reduce((sum, s) => sum + (s.analytics?.averageScore || 0), 0) / sessions.length) * 100).toFixed(0)
              : 0
            }%
          </p>
        </div>
      </div>
    </div>
  );
};

export default Sessions;
