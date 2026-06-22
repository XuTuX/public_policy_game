import 'package:get/get.dart';
import '../models/user_answer_model.dart';
import '../repositories/user_repository.dart';

/// 사용자의 누적 의정 활동 기록을 관리하는 컨트롤러
class HistoryController extends GetxController {
  final UserRepository _userRepository = UserRepository();

  final historyList = <UserAnswerModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  /// 누적 투표 기록 가져오기
  Future<void> loadHistory() async {
    try {
      isLoading.value = true;
      final history = await _userRepository.getVoteHistory();
      // 최신 표결일수록 상단에 오도록 역순 정렬
      history.sort((a, b) => b.answeredAt.compareTo(a.answeredAt));
      historyList.value = history;
    } catch (e) {
      Get.snackbar('오류', '의정 기록을 불러오는 데 실패했습니다.');
    } finally {
      isLoading.value = false;
    }
  }
}
