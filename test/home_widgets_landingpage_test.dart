import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my24app/home/widgets/landingpage.dart';

void main() {
  testWidgets('LandingPageWidget loads', (WidgetTester tester) async {
    // LandingPageWidget(doSkip: state.doSkip, memberPk: state.memberPk)
    await tester.pumpWidget(LandingPageWidget(
    	doSkip: true, memberPk: 1));
  });
}
