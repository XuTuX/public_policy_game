import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_answer_model.dart';
import '../models/vote_model.dart';
import '../app/routes/app_routes.dart';
import '../repositories/user_repository.dart';
import '../repositories/bill_repository.dart';
import '../app/constants/app_constants.dart';

/// 결과 화면 컨트롤러
class ResultController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  final BillRepositoryImpl _billRepository = BillRepositoryImpl();

  late final List<UserAnswerModel> answers;

  // ── Observable State ──
  final categoryStats = <String, double>{}.obs; // 카테고리 -> 찬성 비율 (0.0 ~ 1.0)
  final isStatsLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is List<UserAnswerModel>) {
      answers = Get.arguments as List<UserAnswerModel>;
    } else if (Get.arguments is List) {
      answers = (Get.arguments as List).cast<UserAnswerModel>();
    } else {
      answers = <UserAnswerModel>[];
    }

    _saveAndCalculateStats();
  }

  /// 결과 영구 저장 및 카테고리별 찬성 경향 분석
  Future<void> _saveAndCalculateStats() async {
    try {
      isStatsLoading.value = true;

      // 1. 로컬 저장소에 표결 결과 누적 저장 및 레벨/배지 갱신
      if (answers.isNotEmpty) {
        await _userRepository.saveVoteHistory(answers);
        await _userRepository.updateAfterVoting(answers.length);
      }

      // 2. 카테고리 통계 빌드
      final bills = await _billRepository.getBills();
      final Map<String, List<VoteType>> categoryVotes = {};

      for (final answer in answers) {
        final bill = bills.where((b) => b.id == answer.billId).firstOrNull;
        if (bill != null) {
          categoryVotes.putIfAbsent(bill.category, () => []).add(answer.answer);
        }
      }

      final Map<String, double> stats = {};
      categoryVotes.forEach((category, votes) {
        final total = votes.length;
        final yesCount = votes.where((v) => v == VoteType.yes).length;
        stats[category] = total > 0 ? yesCount / total : 0.0;
      });

      categoryStats.value = stats;
    } catch (e) {
      // 로깅 실패 무시
    } finally {
      isStatsLoading.value = false;
    }
  }

  int get totalBills => answers.length;

  int get yesCount => answers.where((a) => a.answer == VoteType.yes).length;

  int get noCount => answers.where((a) => a.answer == VoteType.no).length;

  int get abstainCount =>
      answers.where((a) => a.answer == VoteType.abstain).length;

  double get yesRatio => totalBills > 0 ? yesCount / totalBills : 0.0;
  double get noRatio => totalBills > 0 ? noCount / totalBills : 0.0;
  double get abstainRatio => totalBills > 0 ? abstainCount / totalBills : 0.0;

  /// 결과 SNS 공유
  Future<void> shareResult() async {
    final appLink = AppConstants.publicAppUrl.isEmpty
        ? ''
        : '\n\n직접 참여하기 👉 ${AppConstants.publicAppUrl}';
    final text = '🗳️ [오늘부터 국회의원] 나의 의정 활동 결과!\n\n'
        '• 찬성: $yesCount건\n'
        '• 반대: $noCount건\n'
        '• 기권: $abstainCount건\n\n'
        '나와 가장 잘 맞는 정치 소울메이트 국회의원과 가치관 유형을 확인해 보세요!'
        '$appLink';
    await Share.share(text);
  }

  void goToRanking() {
    Get.toNamed(AppRoutes.ranking, arguments: answers);
  }

  void goHome() {
    Get.offAllNamed(AppRoutes.home);
  }
}
