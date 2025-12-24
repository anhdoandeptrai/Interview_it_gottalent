class UserStatistics {
  final int totalSessions;
  final double averageScore;
  final Duration totalPracticeTime;
  final double improvementRate;

  UserStatistics({
    required this.totalSessions,
    required this.averageScore,
    required this.totalPracticeTime,
    required this.improvementRate,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalSessions: json['totalSessions'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      totalPracticeTime: Duration(seconds: json['totalPracticeTime'] ?? 0),
      improvementRate: (json['improvementRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'averageScore': averageScore,
      'totalPracticeTime': totalPracticeTime.inSeconds,
      'improvementRate': improvementRate,
    };
  }
}
