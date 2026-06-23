import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:public_policy_game/views/onboarding_page.dart';

void main() {
  testWidgets('낮은 화면에서도 시작 버튼까지 스크롤할 수 있다', (tester) async {
    tester.view.physicalSize = const Size(800, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(Get.reset);

    await tester.pumpWidget(
      const GetMaterialApp(home: OnboardingPage()),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byKey(const Key('onboarding_scroll')),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    final button = find.widgetWithText(ElevatedButton, '시작하기');
    expect(button, findsOneWidget);
    expect(tester.getCenter(button).dy, lessThan(500));
    expect(tester.takeException(), isNull);
  });
}
