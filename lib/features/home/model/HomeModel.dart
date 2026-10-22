class HomeModel {
  final String uid;
  final String name;
  final String email;

  // Home dashboard data
  final int gardenLevel;
  final int currentXp;
  final int nextLevelXp;
  final int streakDays;

  const HomeModel({
    required this.uid,
    required this.name,
    required this.email,
    this.gardenLevel = 1,
    this.currentXp = 0,
    this.nextLevelXp = 100,
    this.streakDays = 0,
  });

  factory HomeModel.fromMap(
      String uid,
      Map<String, dynamic> map,
      ) {
    return HomeModel(
      uid: uid,
      name: map['name'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      gardenLevel: (map['gardenLevel'] as num?)?.toInt() ?? 1,
      currentXp: (map['currentXp'] as num?)?.toInt() ?? 0,
      nextLevelXp: (map['nextLevelXp'] as num?)?.toInt() ?? 100,
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 0,
    );
  }
}