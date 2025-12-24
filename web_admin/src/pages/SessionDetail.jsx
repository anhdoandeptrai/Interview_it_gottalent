import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { 
  ArrowLeft, 
  Calendar,
  Clock,
  Award,
  MessageSquare,
  FileText,
  TrendingUp,
  User
} from 'lucide-react';
import { getSessionById, getUserById } from '../services/api';
import { format } from 'date-fns';

const SessionDetail = () => {
  const { sessionId } = useParams();
  const [session, setSession] = useState(null);
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadSessionData();
  }, [sessionId]);

  const loadSessionData = async () => {
    try {
      setLoading(true);
      const sessionData = await getSessionById(sessionId);
      setSession(sessionData);

      if (sessionData?.userId) {
        const userData = await getUserById(sessionData.userId);
        setUser(userData);
      }
    } catch (error) {
      console.error('Error loading session data:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatDuration = (duration) => {
    if (!duration || !duration.seconds) return '0 phút';
    const hours = Math.floor(duration.seconds / 3600);
    const minutes = Math.floor((duration.seconds % 3600) / 60);
    const seconds = duration.seconds % 60;
    
    if (hours > 0) {
      return `${hours}h ${minutes}m`;
    }
    return `${minutes}m ${seconds}s`;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  if (!session) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500">Không tìm thấy phiên luyện tập</p>
        <Link to="/sessions" className="btn btn-primary btn-sm mt-4">
          Quay lại
        </Link>
      </div>
    );
  }

  const analytics = session.analytics || {};

  return (
    <div className="space-y-6">
      {/* Back button */}
      <Link to="/sessions" className="inline-flex items-center text-gray-600 hover:text-gray-900">
        <ArrowLeft className="w-4 h-4 mr-2" />
        Quay lại danh sách
      </Link>

      {/* Session Info */}
      <div className="card">
        <div className="flex items-start justify-between mb-4">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">
              Chi tiết phiên luyện tập
            </h1>
            <p className="mt-1 text-sm text-gray-600">
              ID: {session.id}
            </p>
          </div>
          <span className={`badge ${
            session.mode === 'interview' ? 'badge-info' : 'badge-warning'
          } text-base px-4 py-2`}>
            {session.mode === 'interview' ? 'Phỏng vấn' : 'Thuyết trình'}
          </span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="flex items-center text-gray-700">
            <User className="w-5 h-5 mr-3 text-gray-400" />
            <div>
              <p className="text-sm text-gray-500">Người dùng</p>
              <Link 
                to={`/users/${session.userId}`}
                className="font-medium text-primary-600 hover:text-primary-700"
              >
                {user?.displayName || user?.email || 'Unknown'}
              </Link>
            </div>
          </div>

          <div className="flex items-center text-gray-700">
            <Calendar className="w-5 h-5 mr-3 text-gray-400" />
            <div>
              <p className="text-sm text-gray-500">Ngày giờ</p>
              <p className="font-medium">
                {session.startTime 
                  ? format(session.startTime.toDate(), 'dd/MM/yyyy HH:mm')
                  : 'N/A'
                }
              </p>
            </div>
          </div>

          <div className="flex items-center text-gray-700">
            <Clock className="w-5 h-5 mr-3 text-gray-400" />
            <div>
              <p className="text-sm text-gray-500">Thời gian</p>
              <p className="font-medium">{formatDuration(analytics.totalDuration)}</p>
            </div>
          </div>

          <div className="flex items-center text-gray-700">
            <MessageSquare className="w-5 h-5 mr-3 text-gray-400" />
            <div>
              <p className="text-sm text-gray-500">Số câu hỏi</p>
              <p className="font-medium">{session.questions?.length || 0} câu</p>
            </div>
          </div>
        </div>
      </div>

      {/* Analytics */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Điểm TB</p>
              <p className="mt-2 text-3xl font-bold text-gray-900">
                {((analytics.averageScore || 0) * 100).toFixed(0)}%
              </p>
            </div>
            <Award className="w-10 h-10 text-yellow-500" />
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Độ rõ ràng</p>
              <p className="mt-2 text-3xl font-bold text-gray-900">
                {((analytics.averageClarity || 0) * 100).toFixed(0)}%
              </p>
            </div>
            <TrendingUp className="w-10 h-10 text-green-500" />
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Tốc độ nói</p>
              <p className="mt-2 text-3xl font-bold text-gray-900">
                {(analytics.averageSpeakingSpeed || 0).toFixed(0)}
              </p>
              <p className="text-xs text-gray-500">từ/phút</p>
            </div>
            <MessageSquare className="w-10 h-10 text-blue-500" />
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Giao tiếp mắt</p>
              <p className="mt-2 text-3xl font-bold text-gray-900">
                {((analytics.averageEyeContactRatio || 0) * 100).toFixed(0)}%
              </p>
            </div>
            <TrendingUp className="w-10 h-10 text-purple-500" />
          </div>
        </div>
      </div>

      {/* Questions & Answers */}
      <div className="card">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">
          Câu hỏi và câu trả lời
        </h2>
        <div className="space-y-6">
          {session.questions?.map((question, index) => {
            const answer = session.answers?.[index];
            
            return (
              <div key={index} className="border-l-4 border-primary-500 pl-4">
                <div className="flex items-start justify-between mb-2">
                  <h3 className="font-medium text-gray-900">
                    Câu {index + 1}: {question}
                  </h3>
                  {answer?.score && (
                    <span className="badge badge-success ml-2">
                      {(answer.score * 100).toFixed(0)}%
                    </span>
                  )}
                </div>
                
                {answer?.transcript && (
                  <div className="mt-2 p-3 bg-gray-50 rounded-lg">
                    <p className="text-sm font-medium text-gray-700 mb-1">
                      Câu trả lời:
                    </p>
                    <p className="text-sm text-gray-600">
                      {answer.transcript}
                    </p>
                  </div>
                )}

                {answer?.feedback && (
                  <div className="mt-2 p-3 bg-blue-50 rounded-lg">
                    <p className="text-sm font-medium text-blue-700 mb-1">
                      Phản hồi:
                    </p>
                    <p className="text-sm text-blue-600">
                      {answer.feedback}
                    </p>
                  </div>
                )}
              </div>
            );
          })}

          {(!session.questions || session.questions.length === 0) && (
            <p className="text-center text-gray-500 py-8">
              Không có câu hỏi nào được ghi nhận
            </p>
          )}
        </div>
      </div>

      {/* Feedback */}
      {(analytics.strengths?.length > 0 || analytics.weaknesses?.length > 0 || analytics.improvements?.length > 0) && (
        <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          {analytics.strengths?.length > 0 && (
            <div className="card">
              <h3 className="text-lg font-semibold text-green-700 mb-3">
                Điểm mạnh
              </h3>
              <ul className="space-y-2">
                {analytics.strengths.map((strength, index) => (
                  <li key={index} className="text-sm text-gray-700 flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    {strength}
                  </li>
                ))}
              </ul>
            </div>
          )}

          {analytics.weaknesses?.length > 0 && (
            <div className="card">
              <h3 className="text-lg font-semibold text-red-700 mb-3">
                Điểm yếu
              </h3>
              <ul className="space-y-2">
                {analytics.weaknesses.map((weakness, index) => (
                  <li key={index} className="text-sm text-gray-700 flex items-start">
                    <span className="text-red-500 mr-2">✗</span>
                    {weakness}
                  </li>
                ))}
              </ul>
            </div>
          )}

          {analytics.improvements?.length > 0 && (
            <div className="card">
              <h3 className="text-lg font-semibold text-blue-700 mb-3">
                Cải thiện
              </h3>
              <ul className="space-y-2">
                {analytics.improvements.map((improvement, index) => (
                  <li key={index} className="text-sm text-gray-700 flex items-start">
                    <span className="text-blue-500 mr-2">→</span>
                    {improvement}
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}

      {/* PDF File Info */}
      {session.pdfFileName && (
        <div className="card">
          <div className="flex items-center">
            <FileText className="w-8 h-8 text-gray-400 mr-3" />
            <div>
              <p className="text-sm text-gray-600">File PDF đã tải lên</p>
              <p className="font-medium text-gray-900">{session.pdfFileName}</p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default SessionDetail;
