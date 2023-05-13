import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/home/blocs/preferences_bloc.dart';
import 'package:my24app/app_config.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/member/pages/select.dart';
import 'package:my24app/home/blocs/preferences_states.dart';
import 'package:my24app/member/pages/detail.dart';

class My24App extends StatelessWidget with i18nMixin {
  Future<bool> _setBasePrefs() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

    AppConfig config = AppConfig();

    await sharedPrefs.setString('apiBaseUrl', config.apiBaseUrl);
    await sharedPrefs.setInt('pageSize', config.pageSize);

    return true;
  }

  GetHomePreferencesBloc _initialCall() {
    GetHomePreferencesBloc bloc = GetHomePreferencesBloc();
    bloc.add(GetHomePreferencesEvent(status: HomeEventStatus.GET_PREFERENCES));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _setBasePrefs(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            return BlocConsumer(
              bloc: _initialCall(),
              listener: (BuildContext context, state) {},
              builder: (context, state) {
                return _getBody(context, state);
              },
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    $trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": snapshot.error}))
            );
          } else {
            return loadingNotice();
          }
        }
    );
  }

  Widget _getBody(BuildContext context, state) {
    if (!(state is HomePreferencesState)) {
      return loadingNotice();
    }

    Locale locale = utils.lang2locale(state.languageCode);
    // final client = StreamChatClient(
    //   '9n2ze2pftnfs',
    //   logLevel: Level.WARNING,
    // );
    //
    // client.on().where((Event event) => event.totalUnreadCount != null).listen((Event event) async {
    //   SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    //   sharedPrefs.setInt('chat_unread_count', event.totalUnreadCount);
    // });

    Map<int, Color> color = {
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
      locale: locale,
      // builder: (context, child) {
      //   return StreamChat(client: client, child: child);
      // },
      theme: ThemeData(
          primarySwatch: colorCustom,
          bottomAppBarTheme: BottomAppBarTheme(color: colorCustom)
      ),
      home: _getHomePageWidget(state.doSkip),
    );
  }

  Widget _getHomePageWidget(bool doSkip) {
    if (doSkip == false || doSkip == null) {
      return SelectPage();
    }

    return MemberPage();
  }
}
