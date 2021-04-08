import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/home/blocs/preferences_bloc.dart';
import 'package:my24app/home/widgets/landingpage.dart';

class My24App extends StatefulWidget {
  @override
  _My24AppState createState() => _My24AppState();
}

class _My24AppState extends State<My24App> {
  Locale _locale;
  bool _doSkip = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetHomePreferencesBloc, HomePreferencesState>(
        builder: (context, state) {
          final block = BlocProvider.of<GetHomePreferencesBloc>(context);
          block.add(GetHomePreferencesEvent(
              status: EventStatus.GET_PREFERENCES,
              value: context.locale.languageCode)
          );

          _doSkip = state.doSkip;
          _locale = lang2locale(state.languageCode);

          if (state.doSkip == null) {
            return MaterialApp(
                home: Text('loading')
            );
          }

          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: _locale,
            theme: ThemeData(
                primaryColor: Color.fromARGB(255, 255, 153, 51)
            ),
            title: 'main.title'.tr(),
            home: Scaffold(
                appBar: AppBar(
                  title: Text(_doSkip ? 'main.app_bar_title_continue' : 'main.app_bar_title_members'.tr()),
                ),
                body: Container(
                    child: Column(
                      children: [
                        LandingPageWidget(doSkip: _doSkip)
                      ],
                    )
                )
            ),
          );
        }
    );
  }
}
