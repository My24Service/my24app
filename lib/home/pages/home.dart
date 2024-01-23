import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:uni_links/uni_links.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/home/blocs/preferences_bloc.dart';
import 'package:my24app/app_config.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/member/pages/select.dart';
import 'package:my24app/home/blocs/preferences_states.dart';
import 'package:my24app/member/pages/detail.dart';

import '../../member/models/public/api.dart';
import '../../member/models/public/models.dart';

class My24App extends StatefulWidget {
  @override
  _My24AppState createState() => _My24AppState();
}

class _My24AppState extends State<My24App> with SingleTickerProviderStateMixin, i18nMixin {
  MemberByCompanycodePublicApi memberApi = MemberByCompanycodePublicApi();
  StreamSubscription? _sub;
  bool memberFromUri = false;
  StreamSubscription<Map>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
    _handleInitialUri();
    _listenDynamicLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _listenDynamicLinks() async {
    // int? memberPk = await utils.getPreferredMemberPk();
    // if (memberPk != null) {
    //   print("memberPk: $memberPk");
    //   return;
    // }
    _streamSubscription = FlutterBranchSdk.initSession().listen((data) async {
        print('listenDynamicLinks - DeepLink Data: $data');
        if (data.containsKey("+clicked_branch_link") &&
            data["+clicked_branch_link"] == true) {
          // Link clicked. Add logic to get link data
          if (data['cc'] == 'open') {
            return;
          }
          print('Company code: ${data["cc"]}');
          await _getMemberCompanycode(data['cc']);
          setState(() {});
          // _streamSubscription?.cancel();
        }
      }, onError: (error) {
        print('InitSession error: ${error.toString()}');
      });
  }


  Future<bool> _getMemberCompanycode(String companycode) async {
    // fetch member by company code
    try {
      final Member member = await memberApi.get(companycode);
      // print('got member: ${member.name}');

      await utils.storeMemberInfo(
          member.companycode!,
          member.pk!,
          member.name!,
          member.companylogoUrl!,
          member.hasBranches!
      );

      memberFromUri = true;

      return true;
    } catch (e) {
      print(e);
      print("Error fetching member public");
      return false;
    }
  }

  bool _isCompanycodeOkay(String host) {
    if (host == 'open' || host.contains('fsnmb') || host == 'link' || host == 'www') {
      return false;
    }

    return true;
  }

  void _handleIncomingLinks() async {
    // It will handle app links while the app is already started - be it in
    // the foreground or in the background.
    _sub = uriLinkStream.listen((Uri? uri) async {
      if (!mounted) return;
      print('got host: ${uri!.host}');
      List<String>? parts = uri.host.split('.');
      if (!_isCompanycodeOkay(parts[0])) return;
      await _getMemberCompanycode(parts[0]);
      setState(() {
      });
    }, onError: (Object err) {
      if (!mounted) return;
      // print('got err: $err');
      setState(() {});
    });
  }

  Future<void> _handleInitialUri() async {
    try {
      final uri = await getInitialUri();
      if (uri == null) {
        print('no initial uri');
      } else {
        if (!mounted) return;
        print('got initial uri: $uri');
        List<String>? parts = uri.host.split('.');
        if (!_isCompanycodeOkay(parts[0])) return;
        await _getMemberCompanycode(parts[0]);
        setState(() {});
      }
      setState(() {});
    } on PlatformException {
      // Platform messages may fail but we ignore the exception
      print('failed to get initial uri');
    } on FormatException catch (err) {
      if (!mounted) return;
      print('malformed initial uri: $err');
      setState(() {});
    }
  }

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

    return BlocProvider(
      create: (BuildContext context) => _initialCall(),
      child: BlocBuilder<GetHomePreferencesBloc, HomePreferencesBaseState>(
        builder: (context, dynamic state) {
          if (!(state is HomePreferencesState)) {
            return loadingNotice();
          }

          Locale? locale = utils.lang2locale(state.languageCode);

          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            builder: (context, child) =>
                MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
            locale: locale,
            // builder: (context, child) {
            //   return StreamChat(client: client, child: child);
            // },
            theme: ThemeData(
                primarySwatch: colorCustom,
                bottomAppBarTheme: BottomAppBarTheme(color: colorCustom)
            ),
            // home: _getHomePageWidget(state.doSkip),
            home: Scaffold(
              body: FutureBuilder<bool>(
                future: _setBasePrefs(),
                builder: (ctx, snapshot) {
                  if (snapshot.hasData) {
                    return _getHomePageWidget(state.doSkip);
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            $trans("error_arg", pathOverride: "generic",
                                namedArgs: {"error": "${snapshot.error}"}
                            )
                        )
                    );
                  } else {
                    return loadingNotice();
                  }
                }
              ),
            )
          );
        },
      ),
    );
  }

  Widget _getHomePageWidget(bool? doSkip) {
    if (memberFromUri) {
      return MemberPage();
    } else {
      print('no member from uri?');
    }

    if (doSkip == false || doSkip == null) {
      return SelectPage();
    }

    return MemberPage();
  }
}
