enum MissionType {
  quiz,
  linkAccount,
  referFriend,
}

enum MissionStatus {
  available,
  inProgress,
  completed,
}

class ClaimMission {
  const ClaimMission({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.rewardPoints,
    required this.status,
    required this.ctaLabel,
    this.progressLabel,
  });

  final String id;
  final MissionType type;
  final String title;
  final String description;
  final int rewardPoints;
  final MissionStatus status;
  final String ctaLabel;
  final String? progressLabel;

  bool get isCompleted => status == MissionStatus.completed;
}
