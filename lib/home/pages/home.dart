import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/home/blocs/preferences_bloc.dart';
import 'package:my24app/home/widgets/landingpage.dart';
import 'package:my24app/member/blocs/fetch_bloc.dart';
import 'package:my24app/member/blocs/fetch_states.dart';

class My24App extends StatefulWidget {
  @override
  _My24AppState createState() => _My24AppState();
}

class _My24AppState extends State<My24App> {
  Locale _locale;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetHomePreferencesBloc, HomePreferencesState>(
        builder: (context, state) {
          final bloc = BlocProvider.of<GetHomePreferencesBloc>(context);
          bloc.add(GetHomePreferencesEvent(
              status: HomeEventStatus.GET_PREFERENCES,
              value: context.locale.languageCode)
          );

          _locale = lang2locale(state.languageCode);

          if (state.doSkip == null) {
            return MaterialApp(
                home: Text('loading')
            );
          }

          // setup our bloc
          FetchMemberBloc createBloc;
          if(state.doSkip) {
            createBloc = FetchMemberBloc(MemberFetchInitialState())..add(FetchMemberEvent(status: MemberEventStatus.FETCH_MEMBER, value: state.memberPk));
          } else {
            createBloc = FetchMemberBloc(MemberFetchInitialState())..add(FetchMemberEvent(status: MemberEventStatus.FETCH_MEMBERS));
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
                  title: Text(state.doSkip ? 'main.app_bar_title_continue'.tr() : 'main.app_bar_title'.tr()),
                ),
                body: Container(
                    child: Column(
                      children: [
                        BlocProvider(
                          create: (BuildContext context) => createBloc,
                          child: LandingPageWidget(doSkip: state.doSkip)
                        )
                      ],
                    )
                )
            ),
          );
        }
    );
  }
}
