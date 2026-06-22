import 'package:get/get.dart';
import '../models/assembly_member_model.dart';

/// 의원 상세 화면 컨트롤러
class MemberDetailController extends GetxController {
  final member = Rxn<AssemblyMemberModel>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is AssemblyMemberModel) {
      member.value = args;
    }
  }

  /// 일치한 법안 수
  int get matchCount =>
      member.value?.comparisons.where((c) => c.isMatch).length ?? 0;

  /// 불일치 법안 수
  int get mismatchCount =>
      member.value?.comparisons.where((c) => !c.isMatch).length ?? 0;

  /// 총 비교 수
  int get totalCount =>
      member.value?.comparisons.length ?? 0;
}
