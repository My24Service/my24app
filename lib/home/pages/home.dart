import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/core/widgets/widgets.dart';
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
  String title = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => GetHomePreferencesBloc(),
        child: BlocBuilder<GetHomePreferencesBloc, HomePreferencesState>(
          builder: (context, state) {
            final bloc = BlocProvider.of<GetHomePreferencesBloc>(context);
            bloc.add(GetHomePreferencesEvent(
                status: HomeEventStatus.GET_PREFERENCES,
                value: context.locale.languageCode)
            );

            _locale = utils.lang2locale(state.languageCode);

            if (state.doSkip == null) {
              return MaterialApp(
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: _locale,
                  home: loadingNotice()
              );
            }

            // setup our bloc
            FetchMemberBloc createBloc;
            if(state.doSkip) {
              createBloc = FetchMemberBloc(
                  MemberFetchInitialState())..add(
                  FetchMemberEvent(
                      status: MemberEventStatus.FETCH_MEMBER,
                      value: state.memberPk));
            } else {
              createBloc = FetchMemberBloc(
                  MemberFetchInitialState())..add(
                  FetchMemberEvent(
                      status: MemberEventStatus.FETCH_MEMBERS));
            }

            return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: _locale,
              theme: ThemeData(
                  primaryColor: Color.fromARGB(255, 255, 153, 51)
              ),
              home: BuildLandingPageScaffold(createBloc: createBloc, doSkip: state.doSkip),
            );
          }
      )
    );
  }
}

class BuildLandingPageScaffold extends StatelessWidget {
  final bool doSkip;
  final FetchMemberBloc createBloc;

  BuildLandingPageScaffold({
    Key key,
    @required this.doSkip,
    @required this.createBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(doSkip ? 'main.app_bar_title_continue'.tr() : 'main.app_bar_title'.tr()),
          centerTitle: true,
        ),
        body: Container(
            child: Column(
              children: [
                BlocProvider(
                    create: (BuildContext context) => createBloc,
                    child: LandingPageWidget(doSkip: doSkip)
                )
              ],
            )
        )
    );
  }
}
