import { 
  collection, 
  query, 
  where, 
  getDocs, 
  doc, 
  getDoc,
  updateDoc,
  deleteDoc,
  addDoc,
  orderBy,
  limit,
  Timestamp
} from 'firebase/firestore';
import { db } from '../config/firebase';

// Users
export const getUsers = async (filters = {}) => {
  try {
    let q = collection(db, 'users');
    
    if (filters.role) {
      q = query(q, where('role', '==', filters.role));
    }
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error('Error getting users:', error);
    throw error;
  }
};

export const getUserById = async (userId) => {
  try {
    const docRef = doc(db, 'users', userId);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      return { id: docSnap.id, ...docSnap.data() };
    }
    return null;
  } catch (error) {
    console.error('Error getting user:', error);
    throw error;
  }
};

export const updateUser = async (userId, data) => {
  try {
    const docRef = doc(db, 'users', userId);
    await updateDoc(docRef, data);
  } catch (error) {
    console.error('Error updating user:', error);
    throw error;
  }
};

export const deleteUser = async (userId) => {
  try {
    const docRef = doc(db, 'users', userId);
    await deleteDoc(docRef);
  } catch (error) {
    console.error('Error deleting user:', error);
    throw error;
  }
};

// Practice Sessions
export const getSessions = async (filters = {}) => {
  try {
    let q = collection(db, 'practice_sessions');
    
    if (filters.userId) {
      q = query(q, where('userId', '==', filters.userId));
    }
    
    if (filters.mode) {
      q = query(q, where('mode', '==', filters.mode));
    }
    
    q = query(q, orderBy('startTime', 'desc'));
    
    if (filters.limit) {
      q = query(q, limit(filters.limit));
    }
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error('Error getting sessions:', error);
    throw error;
  }
};

export const getSessionById = async (sessionId) => {
  try {
    const docRef = doc(db, 'practice_sessions', sessionId);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      return { id: docSnap.id, ...docSnap.data() };
    }
    return null;
  } catch (error) {
    console.error('Error getting session:', error);
    throw error;
  }
};

// Questions
export const getQuestions = async (filters = {}) => {
  try {
    let q = collection(db, 'questions');
    
    if (filters.mode) {
      q = query(q, where('mode', '==', filters.mode));
    }
    
    if (filters.category) {
      q = query(q, where('category', '==', filters.category));
    }
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error('Error getting questions:', error);
    throw error;
  }
};

export const addQuestion = async (data) => {
  try {
    const docRef = await addDoc(collection(db, 'questions'), {
      ...data,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now()
    });
    return docRef.id;
  } catch (error) {
    console.error('Error adding question:', error);
    throw error;
  }
};

export const updateQuestion = async (questionId, data) => {
  try {
    const docRef = doc(db, 'questions', questionId);
    await updateDoc(docRef, {
      ...data,
      updatedAt: Timestamp.now()
    });
  } catch (error) {
    console.error('Error updating question:', error);
    throw error;
  }
};

export const deleteQuestion = async (questionId) => {
  try {
    const docRef = doc(db, 'questions', questionId);
    await deleteDoc(docRef);
  } catch (error) {
    console.error('Error deleting question:', error);
    throw error;
  }
};

// Statistics
export const getStatistics = async () => {
  try {
    const [users, sessions, questions] = await Promise.all([
      getDocs(collection(db, 'users')),
      getDocs(collection(db, 'practice_sessions')),
      getDocs(collection(db, 'questions'))
    ]);

    const stats = {
      totalUsers: users.size,
      totalSessions: sessions.size,
      totalQuestions: questions.size,
      activeUsers: 0,
      avgScore: 0
    };

    // Calculate active users (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    let totalScore = 0;
    let scoreCount = 0;

    sessions.forEach(doc => {
      const data = doc.data();
      const sessionDate = data.startTime?.toDate();
      
      if (sessionDate && sessionDate > thirtyDaysAgo) {
        stats.activeUsers++;
      }

      if (data.analytics?.averageScore) {
        totalScore += data.analytics.averageScore;
        scoreCount++;
      }
    });

    stats.avgScore = scoreCount > 0 ? (totalScore / scoreCount) : 0;

    return stats;
  } catch (error) {
    console.error('Error getting statistics:', error);
    throw error;
  }
};

// Leaderboard
export const getLeaderboard = async (period = 'month', mode = null) => {
  try {
    let q = collection(db, 'practice_sessions');
    
    // Calculate date range
    const now = new Date();
    let startDate = new Date();
    
    if (period === 'week') {
      startDate.setDate(now.getDate() - 7);
    } else if (period === 'month') {
      startDate.setMonth(now.getMonth() - 1);
    } else if (period === 'year') {
      startDate.setFullYear(now.getFullYear() - 1);
    }
    
    q = query(q, where('startTime', '>=', Timestamp.fromDate(startDate)));
    
    if (mode) {
      q = query(q, where('mode', '==', mode));
    }
    
    const snapshot = await getDocs(q);
    
    // Group by user and calculate stats
    const userStats = {};
    
    snapshot.forEach(doc => {
      const data = doc.data();
      const userId = data.userId;
      
      if (!userStats[userId]) {
        userStats[userId] = {
          userId,
          totalSessions: 0,
          totalScore: 0,
          bestScore: 0
        };
      }
      
      const score = data.analytics?.averageScore || 0;
      
      userStats[userId].totalSessions++;
      userStats[userId].totalScore += score;
      userStats[userId].bestScore = Math.max(userStats[userId].bestScore, score);
    });
    
    // Convert to array and sort
    const leaderboard = Object.values(userStats)
      .map(stats => ({
        ...stats,
        avgScore: stats.totalScore / stats.totalSessions
      }))
      .sort((a, b) => b.avgScore - a.avgScore);
    
    // Get user details
    const enriched = await Promise.all(
      leaderboard.slice(0, 100).map(async (item) => {
        const user = await getUserById(item.userId);
        return {
          ...item,
          userName: user?.displayName || user?.email || 'Unknown',
          userEmail: user?.email
        };
      })
    );
    
    return enriched;
  } catch (error) {
    console.error('Error getting leaderboard:', error);
    throw error;
  }
};
