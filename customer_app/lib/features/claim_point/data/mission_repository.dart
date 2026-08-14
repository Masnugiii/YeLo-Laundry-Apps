import 'package:yelo_laundry_customer/core/dev/dev_preview_data.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_gate.dart';
import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/features/claim_point/models/claim_mission.dart';

class MissionRepository {
  MissionRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<List<ClaimMission>> fetchMissions() async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.missions;
    }

    final data = await _api.get<List<dynamic>>(
      '/customer-app/missions',
      parser: (json) => json as List<dynamic>,
    );

    return data
        .map((item) => _mapMission(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> claimMission(String missionId) async {
    if (DevPreviewGate.isActive) {
      return;
    }

    await _api.post<Map<String, dynamic>>(
      '/customer-app/missions/$missionId/claim',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  ClaimMission _mapMission(Map<String, dynamic> json) {
    return ClaimMission(
      id: json['id'] as String,
      type: _mapType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rewardPoints: (json['rewardPoints'] as num?)?.toInt() ?? 0,
      status: json['status'] == 'completed'
          ? MissionStatus.completed
          : MissionStatus.available,
      ctaLabel: json['ctaLabel'] as String? ?? 'Mulai',
      progressLabel: json['progressLabel'] as String?,
    );
  }

  MissionType _mapType(String? value) {
    switch (value) {
      case 'link_account':
        return MissionType.linkAccount;
      case 'refer_friend':
        return MissionType.referFriend;
      case 'quiz':
      default:
        return MissionType.quiz;
    }
  }
}
