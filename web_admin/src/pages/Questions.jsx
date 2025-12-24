import { useState, useEffect } from 'react';
import { 
  Plus, 
  Search, 
  Filter,
  Edit2,
  Trash2,
  MessageSquare
} from 'lucide-react';
import { 
  getQuestions, 
  addQuestion, 
  updateQuestion, 
  deleteQuestion 
} from '../services/api';

const Questions = () => {
  const [questions, setQuestions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterMode, setFilterMode] = useState('all');
  const [filterCategory, setFilterCategory] = useState('all');
  const [showModal, setShowModal] = useState(false);
  const [editingQuestion, setEditingQuestion] = useState(null);
  const [formData, setFormData] = useState({
    question: '',
    mode: 'interview',
    category: 'technical',
    difficulty: 'medium',
    suggestedAnswer: ''
  });

  useEffect(() => {
    loadQuestions();
  }, []);

  const loadQuestions = async () => {
    try {
      setLoading(true);
      const data = await getQuestions();
      setQuestions(data);
    } catch (error) {
      console.error('Error loading questions:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      if (editingQuestion) {
        await updateQuestion(editingQuestion.id, formData);
      } else {
        await addQuestion(formData);
      }
      
      await loadQuestions();
      handleCloseModal();
    } catch (error) {
      console.error('Error saving question:', error);
      alert('Không thể lưu câu hỏi');
    }
  };

  const handleEdit = (question) => {
    setEditingQuestion(question);
    setFormData({
      question: question.question,
      mode: question.mode,
      category: question.category,
      difficulty: question.difficulty,
      suggestedAnswer: question.suggestedAnswer || ''
    });
    setShowModal(true);
  };

  const handleDelete = async (questionId) => {
    if (!window.confirm('Bạn có chắc muốn xóa câu hỏi này?')) {
      return;
    }

    try {
      await deleteQuestion(questionId);
      setQuestions(questions.filter(q => q.id !== questionId));
    } catch (error) {
      console.error('Error deleting question:', error);
      alert('Không thể xóa câu hỏi');
    }
  };

  const handleCloseModal = () => {
    setShowModal(false);
    setEditingQuestion(null);
    setFormData({
      question: '',
      mode: 'interview',
      category: 'technical',
      difficulty: 'medium',
      suggestedAnswer: ''
    });
  };

  const filteredQuestions = questions.filter(q => {
    const matchesSearch = q.question.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesMode = filterMode === 'all' || q.mode === filterMode;
    const matchesCategory = filterCategory === 'all' || q.category === filterCategory;
    return matchesSearch && matchesMode && matchesCategory;
  });

  const categories = [
    { value: 'technical', label: 'Kỹ thuật' },
    { value: 'behavioral', label: 'Hành vi' },
    { value: 'situational', label: 'Tình huống' },
    { value: 'presentation', label: 'Thuyết trình' },
    { value: 'general', label: 'Chung' }
  ];

  const difficulties = [
    { value: 'easy', label: 'Dễ', color: 'bg-green-100 text-green-800' },
    { value: 'medium', label: 'Trung bình', color: 'bg-yellow-100 text-yellow-800' },
    { value: 'hard', label: 'Khó', color: 'bg-red-100 text-red-800' }
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
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Ngân hàng câu hỏi</h1>
          <p className="mt-1 text-sm text-gray-600">
            Quản lý câu hỏi phỏng vấn và thuyết trình
          </p>
        </div>
        <button
          onClick={() => setShowModal(true)}
          className="btn btn-primary btn-md"
        >
          <Plus className="w-5 h-5 mr-2" />
          Thêm câu hỏi
        </button>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="flex flex-col gap-4 sm:flex-row">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Tìm kiếm câu hỏi..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="input pl-10"
            />
          </div>
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
            value={filterCategory}
            onChange={(e) => setFilterCategory(e.target.value)}
            className="input"
          >
            <option value="all">Tất cả danh mục</option>
            {categories.map(cat => (
              <option key={cat.value} value={cat.value}>{cat.label}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Questions Grid */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        {filteredQuestions.map((question) => {
          const difficulty = difficulties.find(d => d.value === question.difficulty);
          
          return (
            <div key={question.id} className="card">
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center gap-2">
                  <span className={`badge ${
                    question.mode === 'interview' ? 'badge-info' : 'badge-warning'
                  }`}>
                    {question.mode === 'interview' ? 'Phỏng vấn' : 'Thuyết trình'}
                  </span>
                  <span className={`badge ${difficulty?.color}`}>
                    {difficulty?.label}
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => handleEdit(question)}
                    className="text-primary-600 hover:text-primary-900"
                  >
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(question.id)}
                    className="text-red-600 hover:text-red-900"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              <h3 className="text-lg font-medium text-gray-900 mb-2">
                {question.question}
              </h3>

              <p className="text-sm text-gray-600 mb-3">
                Danh mục: {categories.find(c => c.value === question.category)?.label}
              </p>

              {question.suggestedAnswer && (
                <div className="mt-3 p-3 bg-gray-50 rounded-lg">
                  <p className="text-xs font-medium text-gray-700 mb-1">Gợi ý trả lời:</p>
                  <p className="text-sm text-gray-600 line-clamp-2">
                    {question.suggestedAnswer}
                  </p>
                </div>
              )}
            </div>
          );
        })}
      </div>

      {filteredQuestions.length === 0 && (
        <div className="card text-center py-12">
          <MessageSquare className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-500">Không tìm thấy câu hỏi nào</p>
        </div>
      )}

      {/* Stats */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-3">
        <div className="card">
          <p className="text-sm font-medium text-gray-600">Tổng câu hỏi</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">{questions.length}</p>
        </div>
        <div className="card">
          <p className="text-sm font-medium text-gray-600">Phỏng vấn</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">
            {questions.filter(q => q.mode === 'interview').length}
          </p>
        </div>
        <div className="card">
          <p className="text-sm font-medium text-gray-600">Thuyết trình</p>
          <p className="mt-2 text-3xl font-bold text-gray-900">
            {questions.filter(q => q.mode === 'presentation').length}
          </p>
        </div>
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">
                {editingQuestion ? 'Chỉnh sửa câu hỏi' : 'Thêm câu hỏi mới'}
              </h2>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="label">Câu hỏi *</label>
                  <textarea
                    value={formData.question}
                    onChange={(e) => setFormData({ ...formData, question: e.target.value })}
                    className="input mt-1"
                    rows={3}
                    required
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="label">Chế độ *</label>
                    <select
                      value={formData.mode}
                      onChange={(e) => setFormData({ ...formData, mode: e.target.value })}
                      className="input mt-1"
                      required
                    >
                      <option value="interview">Phỏng vấn</option>
                      <option value="presentation">Thuyết trình</option>
                    </select>
                  </div>

                  <div>
                    <label className="label">Độ khó *</label>
                    <select
                      value={formData.difficulty}
                      onChange={(e) => setFormData({ ...formData, difficulty: e.target.value })}
                      className="input mt-1"
                      required
                    >
                      {difficulties.map(d => (
                        <option key={d.value} value={d.value}>{d.label}</option>
                      ))}
                    </select>
                  </div>
                </div>

                <div>
                  <label className="label">Danh mục *</label>
                  <select
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                    className="input mt-1"
                    required
                  >
                    {categories.map(cat => (
                      <option key={cat.value} value={cat.value}>{cat.label}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="label">Gợi ý trả lời</label>
                  <textarea
                    value={formData.suggestedAnswer}
                    onChange={(e) => setFormData({ ...formData, suggestedAnswer: e.target.value })}
                    className="input mt-1"
                    rows={4}
                    placeholder="Nhập gợi ý trả lời (tùy chọn)"
                  />
                </div>

                <div className="flex justify-end gap-3 pt-4">
                  <button
                    type="button"
                    onClick={handleCloseModal}
                    className="btn btn-secondary btn-md"
                  >
                    Hủy
                  </button>
                  <button type="submit" className="btn btn-primary btn-md">
                    {editingQuestion ? 'Cập nhật' : 'Thêm mới'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Questions;
