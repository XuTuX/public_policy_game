import 'package:get/get.dart';
import '../models/user_answer_model.dart';
import '../models/vote_model.dart';
import '../repositories/user_repository.dart';
import '../app/routes/app_routes.dart';

/// 결과 화면 컨트롤러
class ResultController extends GetxController {
  final UserRepository _userRepository = UserRepository();

  // ── Observable State ──
  final answers = <UserAnswerModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is List<UserAnswerModel>) {
      answers.value = args;
    }
    _saveResults();
  }

  /// 결과 저장
  Future<void> _saveResults() async {
    try {
      isLoading.value = true;
      await _userRepository.saveVoteHistory(answers);
      await _userRepository.updateAfterVoting(answers.length);
    } catch (e) {
      // 저장 실패 시에도 결과는 보여줌
    } finally {
      isLoading.value = false;
    }
  }

  /// 총 참여 법안 수
  int get totalBills => answers.length;

  /// 찬성 수
  int get yesCount =>
      answers.where((a) => a.answer == VoteType.yes).length;

  /// 반대 수
  int get noCount =>
      answers.where((a) => a.answer == VoteType.no).length;

  /// 찬성 비율 (0.0 ~ 1.0)
  double get yesRatio =>
      totalBills > 0 ? yesCount / totalBills : 0.0;

  /// 반대 비율 (0.0 ~ 1.0)
  double get noRatio =>
      totalBills > 0 ? noCount / totalBills : 0.0;

  /// 나와 비슷한 의원 찾기
  void goToRanking() {
    Get.toNamed(AppRoutes.ranking, arguments: answers.toList());
  }

  /// 홈으로 돌아가기
  void goHome() {
    Get.offAllNamed(AppRoutes.home);
  }
}
