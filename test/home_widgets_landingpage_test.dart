import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/member/widgets/select.dart';
import 'package:my24app/member/blocs/fetch_bloc.dart';


Widget createBlocProviderForWidget({Widget child}) {
  return MaterialApp(
    home: Scaffold(
        body: Container(
            child: BlocProvider(
                create: (_) => FetchMemberBloc(),
                child: child
            )
        )
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('SelectContinueWidget loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      createBlocProviderForWidget(child: SelectWidget()
      )
    );

    tester.pump(Duration(milliseconds: 1000));
  });
}
