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

  /// 1위 의원
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
