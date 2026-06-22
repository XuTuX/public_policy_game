import 'package:get/get.dart';
import '../models/assembly_member_model.dart';
import '../models/user_answer_model.dart';
import '../repositories/vote_repository.dart';
import '../app/routes/app_routes.dart';

/// 국회의원 매칭 화면 컨트롤러
class RankingController extends GetxController {
  final VoteRepositoryImpl _voteRepository = VoteRepositoryImpl();

  // ── Observable State ──
  final rankedMembers = <AssemblyMemberModel>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;

  // ── 필터링 & 검색 상태 ──
  final searchQuery = ''.obs;
  final selectedParty = '전체'.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is List<UserAnswerModel>) {
      _calculateRanking(args);
    }
  }

  /// 일치율 계산 및 랭킹 생성
  Future<void> _calculateRanking(List<UserAnswerModel> answers) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final members = await _voteRepository.getMatchedMembers(answers);
      rankedMembers.value = members;
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// 검색과 정당 칩 필터링이 모두 적용된 최종 의원 목록
  List<AssemblyMemberModel> get filteredMembers {
    return rankedMembers.where((member) {
      final matchesQuery = searchQuery.value.isEmpty ||
          member.name.contains(searchQuery.value) ||
          member.district.contains(searchQuery.value);

      final matchesParty = selectedParty.value == '전체' ||
          member.party == selectedParty.value;

      return matchesQuery && matchesParty;
    }).toList();
  }

  /// 고유 정당 목록 도출
  List<String> get parties {
    final list = <String>['전체'];
    final uniqueParties = rankedMembers.map((m) => m.party).toSet().toList();
    uniqueParties.sort();
    list.addAll(uniqueParties);
    return list;
  }

  /// 전체 1위 의원 (필터링과 무관하게 원본 1위 유지)
  AssemblyMemberModel? get topMember =>
      rankedMembers.isNotEmpty ? rankedMembers.first : null;

  /// 상위 3명
  List<AssemblyMemberModel> get topThree =>
      rankedMembers.take(3).toList();

  /// 나머지 (4위 이후)
  List<AssemblyMemberModel> get restMembers =>
      rankedMembers.length > 3 ? rankedMembers.sublist(3) : [];

  /// 의원 상세 화면으로 이동
  void goToMemberDetail(AssemblyMemberModel member) {
    Get.toNamed(AppRoutes.memberDetail, arguments: member);
  }

  /// 홈으로 돌아가기
  void goHome() {
    Get.offAllNamed(AppRoutes.home);
  }
}
