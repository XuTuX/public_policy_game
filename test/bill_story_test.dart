import 'package:flutter_test/flutter_test.dart';

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

}
