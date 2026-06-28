import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_answer_model.dart';
import '../models/vote_model.dart';
import '../app/routes/app_routes.dart';
import '../repositories/user_repository.dart';
import '../repositories/bill_repository.dart';
import '../repositories/vote_repository.dart';
import '../models/assembly_member_model.dart';
import '../app/constants/app_constants.dart';

/// 결과 화면 컨트롤러
class ResultController extends GetxController {
  final GlobalKey shareKey = GlobalKey();
  final UserRepository _userRepository = UserRepository();
  final BillRepositoryImpl _billRepository = BillRepositoryImpl();
  final VoteRepositoryImpl _voteRepository = VoteRepositoryImpl();

  late final List<UserAnswerModel> answers;

  // ── Observable State ──
  final categoryStats = <String, double>{}.obs; // 카테고리 -> 찬성 비율 (0.0 ~ 1.0)
  final isStatsLoading = true.obs;
  final statsErrorMessage = ''.obs;

  final bestMatch = Rxn<AssemblyMemberModel>();
  final worstMatch = Rxn<AssemblyMemberModel>();

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
      statsErrorMessage.value = '';

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

      // 3. 매칭 의원 계산
      final members = await _voteRepository.getMatchedMembers(answers);
      final validMembers = members
          .where((m) => m.comparisons.isNotEmpty)
          .toList();

      if (validMembers.isNotEmpty) {
        bestMatch.value = validMembers.first;
        if (validMembers.length > 1) {
          worstMatch.value = validMembers.last;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ResultController._saveAndCalculateStats failed: $e');
      }
      statsErrorMessage.value = '일부 결과 분석을 완료하지 못했습니다. 잠시 후 다시 시도해 주세요.';
    } finally {
      isStatsLoading.value = false;
    }
  }

  String get matchingRuleText =>
      '일치율은 사용자와 의원의 찬성·반대·기권 선택이 같은 비율입니다. '
      '불참·미투표는 계산에서 제외하고, 동률은 비교 가능한 법안 수와 의원명 순서로 정렬합니다.';

  int get totalBills => answers.length;

  int get yesCount => answers.where((a) => a.answer == VoteType.yes).length;

  int get noCount => answers.where((a) => a.answer == VoteType.no).length;

  int get abstainCount =>
      answers.where((a) => a.answer == VoteType.abstain).length;

  double get yesRatio => totalBills > 0 ? yesCount / totalBills : 0.0;
  double get noRatio => totalBills > 0 ? noCount / totalBills : 0.0;
  double get abstainRatio => totalBills > 0 ? abstainCount / totalBills : 0.0;

  /// 결과 SNS 공유 (이미지 캡쳐 공유 우선, 실패 시 텍스트 공유)
  Future<void> shareResult() async {
    try {
      final boundary =
          shareKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        await _shareTextOnly();
        return;
      }

      // 이미지를 비트맵으로 캡처 (고화질을 위해 3.0 배수 지정)
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        await _shareTextOnly();
        return;
      }
      final pngBytes = byteData.buffer.asUint8List();

      // 임시 파일 생성 대신 cross_file의 fromData를 통해 공유 파일 생성
      final xFile = XFile.fromData(
        pngBytes,
        name: 'my_assembly_result.png',
        mimeType: 'image/png',
      );

      final appLink = AppConstants.publicAppUrl.isEmpty
          ? ''
          : '\n\n직접 참여하기: ${AppConstants.publicAppUrl}';
      final text =
          '[오늘부터 국회의원] 표결 성향 분석 결과\n'
          '나와 의견 일치율이 높은 국회의원 결과를 확인해 보세요.$appLink';

      await Share.shareXFiles([xFile], text: text);
    } catch (e) {
      await _shareTextOnly();
    }
  }

  Future<void> _shareTextOnly() async {
    final appLink = AppConstants.publicAppUrl.isEmpty
        ? ''
        : '\n\n직접 참여하기: ${AppConstants.publicAppUrl}';
    final text =
        '[오늘부터 국회의원] 표결 성향 분석 결과\n\n'
        '• 찬성: $yesCount건\n'
        '• 반대: $noCount건\n'
        '• 기권: $abstainCount건\n\n'
        '나와 의견 일치율이 높은 국회의원을 확인해 보세요.'
        '$appLink';
    await Share.share(text);
  }

  void goHome() {
    Get.offAllNamed(AppRoutes.home);
  }
}
