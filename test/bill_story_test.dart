import 'package:flutter_test/flutter_test.dart';
import 'package:public_policy_game/controllers/bill_controller.dart';
import 'package:public_policy_game/data/mock/mock_bills.dart';

void main() {
  group('법안 스토리 데이터', () {
    test('모든 법안에 상황형 대사와 핵심 영향이 있다', () {
      expect(MockBills.bills, hasLength(10));

      for (final bill in MockBills.bills) {
        final narrative = bill.narrative;
        expect(narrative, isNotNull, reason: bill.billName);
        expect(
          narrative!.backgroundDialogue,
          isNotEmpty,
          reason: bill.billName,
        );
        expect(narrative.positiveDialogue, isNotEmpty, reason: bill.billName);
        expect(narrative.concernDialogue, isNotEmpty, reason: bill.billName);
        expect(narrative.positiveImpact, isNotEmpty, reason: bill.billName);
        expect(narrative.concernImpact, isNotEmpty, reason: bill.billName);
      }
    });
  });

  group('장면 이동', () {
    test('일반 모드는 배경, 장점, 부작용, 결정 순서로 이동한다', () {
      final controller = BillController();

      expect(controller.sceneStep.value, 0);
      controller.nextScene();
      expect(controller.sceneStep.value, 1);
      controller.nextScene();
      expect(controller.sceneStep.value, 2);
      controller.previousScene();
      expect(controller.sceneStep.value, 1);
      controller.skipToDecision();
      expect(controller.sceneStep.value, 3);
    });

    test('빠른 진행은 배경 다음에 바로 결정으로 이동한다', () {
      final controller = BillController();

      controller.toggleFastMode();
      controller.nextScene();

      expect(controller.fastMode.value, isTrue);
      expect(controller.sceneStep.value, 3);
    });
  });
}
