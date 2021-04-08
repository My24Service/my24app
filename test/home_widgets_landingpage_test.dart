import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/home/widgets/landingpage.dart';
import 'package:my24app/member/blocs/fetch_bloc.dart';


Widget createBlocProviderForWidget({Widget child}) {
  return BlocProvider(
    create: (_) => FetchMemberBloc(),
    child: child
  );
}

void main() {
  testWidgets('LandingPageWidget loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      createBlocProviderForWidget(child: LandingPageWidget(
      doSkip: true, memberPk: 1))
    );

    tester.pump(Duration(milliseconds: 1000));
  });
}
