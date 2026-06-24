import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import '../models/bill_model.dart';
import '../models/vote_model.dart';
import '../models/user_answer_model.dart';
import '../repositories/bill_repository.dart';
import '../app/routes/app_routes.dart';
import '../services/game_session_service.dart';
import '../app/constants/app_constants.dart';

/// 법안 표결 화면 컨트롤러
class BillController extends GetxController {
  final BillRepositoryImpl _billRepository = BillRepositoryImpl();

  // ── Observable State ──
  final bills = <BillModel>[].obs;
  final currentIndex = 0.obs;
  final answers = <UserAnswerModel>[].obs;
  final isLoading = true.obs;
  final isAnimating = false.obs;
  final lastVoteType = Rxn<VoteType>();
  final selectedTab = 0.obs; // 0: 기대 효과, 1: 우려 사항
  final visitedPros = true.obs;
  final visitedCons = false.obs;
  final isVoteMode = false.obs;
  final fastMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBills();
  }

  /// 법안 목록 로드
  Future<void> loadBills() async {
    try {
      isLoading.value = true;
      final allBills = await _billRepository.getBills();
      
      // 한번 플레이 시 최대 개수 제한 (매번 다양한 법안을 접할 수 있게 셔플)
      final shuffledBills = allBills.toList()..shuffle();
      bills.value = shuffledBills.take(AppConstants.maxBillsPerSession).toList();
    } catch (e) {
      final message = e is StateError ? e.message : '법안을 불러오는 데 실패했습니다';
      Get.snackbar('오류', message);
    } finally {
      isLoading.value = false;
    }
  }

  /// 현재 법안
  BillModel? get currentBill =>
      currentIndex.value < bills.length ? bills[currentIndex.value] : null;

  /// 진행률 (0.0 ~ 1.0)
  double get progress =>
      bills.isEmpty ? 0.0 : (currentIndex.value + 1) / bills.length;

  /// 진행률 텍스트 (예: "3 / 10")
  String get progressText => '${currentIndex.value + 1} / ${bills.length}';

  /// 남은 법안 수
  int get remainingBills => bills.length - currentIndex.value - 1;

  /// 기대 효과/우려 사항 탭 변경 및 표결 전환 로직
  void nextScene() {
    if (selectedTab.value == 0) {
      selectedTab.value = 1;
      visitedCons.value = true;
    } else if (selectedTab.value == 1) {
      isVoteMode.value = true;
    }
  }

  void previousScene() {
    if (isVoteMode.value) {
      isVoteMode.value = false;
    } else if (selectedTab.value == 1) {
      selectedTab.value = 0;
    }
  }

  void skipToDecision() {
    visitedPros.value = true;
    visitedCons.value = true;
    isVoteMode.value = true;
  }

  void selectTab(int index) {
    selectedTab.value = index;
    if (index == 0) visitedPros.value = true;
    if (index == 1) visitedCons.value = true;
  }

  void toggleFastMode() {
    fastMode.toggle();
  }

  /// O(찬성) 또는 X(반대) 선택
  Future<void> vote(VoteType voteType) async {
    if (isAnimating.value) return;
    if (currentBill == null) return;

    isAnimating.value = true;
    lastVoteType.value = voteType;

    // 진동 피드백
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 50);
      }
    } catch (_) {
      // 진동 미지원 기기 무시
    }

    // 응답 저장
    answers.add(
      UserAnswerModel(
        visitorId: 'local_user',
        billId: currentBill!.id,
        billName: currentBill!.billName,
        answer: voteType,
        answeredAt: DateTime.now(),
        gameSetId: GameSessionService().gameSetId,
      ),
    );

    // 애니메이션 대기
    await Future.delayed(const Duration(milliseconds: 900));

    isAnimating.value = false;

    // 다음 법안 또는 결과 화면으로
    if (currentIndex.value < bills.length - 1) {
      selectedTab.value = 0;
      visitedPros.value = true;
      visitedCons.value = false;
      isVoteMode.value = false;
      currentIndex.value++;
    } else {
      // 모든 법안 완료 → 결과 화면
      Get.offNamed(AppRoutes.result, arguments: answers.toList());
    }
  }

  /// 찬성 수
  int get yesCount => answers.where((a) => a.answer == VoteType.yes).length;

  /// 반대 수
  int get noCount => answers.where((a) => a.answer == VoteType.no).length;
}
