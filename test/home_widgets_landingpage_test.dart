import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/home/widgets/landingpage.dart';
import 'package:my24app/member/blocs/fetch_bloc.dart';
import 'package:my24app/member/blocs/fetch_states.dart';


Widget createBlocProviderForWidget({Widget child}) {
  return MaterialApp(
    home: Scaffold(
        body: Container(
            child: BlocProvider(
                create: (_) => FetchMemberBloc(MemberFetchInitialState()),
                child: child
            )
        )
    ),
  );
}

void main() {
  testWidgets('LandingPageWidget loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      createBlocProviderForWidget(child: LandingPageWidget(
      doSkip: true))
    );

    tester.pump(Duration(milliseconds: 1000));
  });
}
