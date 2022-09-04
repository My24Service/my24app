import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:upgrader/upgrader.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/home/blocs/preferences_bloc.dart';
import 'package:my24app/home/widgets/landingpage.dart';
import 'package:my24app/member/blocs/fetch_bloc.dart';
import 'package:my24app/member/blocs/fetch_states.dart';
import 'package:my24app/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/preferences_states.dart';

class My24App extends StatefulWidget {
  @override
  _My24AppState createState() => _My24AppState();
}

class _My24AppState extends State<My24App> {
  Locale _locale;
  String title = '';
  SharedPreferences _sharedPrefs;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    _sharedPrefs = await SharedPreferences.getInstance();
    await _setBaseUrl();
  }
  _setBaseUrl() async {
    var config = AppConfig();

    await _sharedPrefs.setString('apiBaseUrl', config.apiBaseUrl);
  }

  GetHomePreferencesBloc _initialCall() {
    GetHomePreferencesBloc bloc = GetHomePreferencesBloc();
    bloc.add(GetHomePreferencesEvent(status: HomeEventStatus.GET_PREFERENCES));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _initialCall(),
      listener: (BuildContext context, state) {},
      builder: (context, state) {
        return _getBody(state);
      },
    );
  }

  Widget _getBody(state) {
    if (!(state is HomePreferencesState)) {
      return SizedBox(height: 1);
    }

    _locale = utils.lang2locale(state.languageCode);
    final client = StreamChatClient(
      '9n2ze2pftnfs',
      logLevel: Level.WARNING,
    );

    client.on().where((Event event) => event.totalUnreadCount != null).listen((Event event) {
      _sharedPrefs.setInt('chat_unread_count', event.totalUnreadCount);
    });

    if (state.doSkip == null) {
      return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          builder: (context, child) {
            return StreamChat(client: client, child: child);
          },
          locale: _locale,
          home: loadingNotice()
      );
    }

    // setup our bloc
    FetchMemberBloc createBloc;
    if (state.doSkip) {
      createBloc = FetchMemberBloc()
        ..add(
            FetchMemberEvent(
                status: MemberEventStatus.FETCH_MEMBER,
                value: state.memberPk));
    } else {
      createBloc = FetchMemberBloc()
        ..add(
            FetchMemberEvent(
                status: MemberEventStatus.FETCH_MEMBERS));
    }

    Map<int, Color> color =
    {
      50:Color.fromARGB(255, 255, 153, 51),
      100:Color.fromARGB(255, 255, 153, 51),
      200:Color.fromARGB(255, 255, 153, 51),
      300:Color.fromARGB(255, 255, 153, 51),
      400:Color.fromARGB(255, 255, 153, 51),
      500:Color.fromARGB(255, 255, 153, 51),
      600:Color.fromARGB(255, 255, 153, 51),
      700:Color.fromARGB(255, 255, 153, 51),
      800:Color.fromARGB(255, 255, 153, 51),
      900:Color.fromARGB(255, 255, 153, 51),
    };

    MaterialColor colorCustom = MaterialColor(0xFFf28c00, color);

    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: _locale,
      builder: (context, child) {
        return StreamChat(client: client, child: child);
      },
      theme: ThemeData(
          primarySwatch: colorCustom,
          bottomAppBarColor: colorCustom
      ),
      home: BuildLandingPageScaffold(
          createBloc: createBloc, doSkip: state.doSkip),
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
        body: UpgradeAlert(
          child: Container(
              child: Column(
                children: [
                  BlocProvider(
                      create: (BuildContext context) => createBloc,
                      child: LandingPageWidget(doSkip: doSkip)
                  )
                ],
              )
          )
        )
    );
  }
}
