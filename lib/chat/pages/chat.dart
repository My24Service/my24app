import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../widgets/chat.dart';

class ChatPage extends StatefulWidget {
  ChatPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _ChatPageState();
}

StreamChatClient buildStreamChatClient(
    String apiKey, {
      Level logLevel = Level.INFO,
    }) {
  return StreamChatClient(
    apiKey,
  );
}

class _ChatPageState extends State<ChatPage> {
  InitData _initData;

  Future<InitData> _initConnection() async {
    String apiKey, userId, token;

    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    apiKey = '9n2ze2pftnfs';
    userId = sharedPrefs.getString('email');
    token = sharedPrefs.getString('stream_token');

    final client = buildStreamChatClient(apiKey);

    if (userId != null && token != null) {
      await client.connectUser(
        User(id: userId),
        token,
      );
    }

    final prefs = await StreamingSharedPreferences.instance;

    return InitData(client, prefs);
  }

  @override
  void initState() {
    _initConnection().then(
          (initData) {
        setState(() {
          _initData = initData;
        });
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_initData != null)
          PreferenceBuilder<int>(
            preference: _initData.preferences.getInt(
              'theme',
              defaultValue: 0,
            ),
            builder: (context, snapshot) => MaterialApp(
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: {
                -1: ThemeMode.dark,
                0: ThemeMode.system,
                1: ThemeMode.light,
              }[snapshot],
              builder: (context, child) => StreamChatTheme(
                data: StreamChatThemeData(
                  brightness: Theme.of(context).brightness,
                ),
                child: child,
              ),
          )
        )
      ],
    );
  }

  Widget _getBody(context) {
      return ChatWidget();
  }
}

class InitData {
  final StreamChatClient client;
  final StreamingSharedPreferences preferences;

  InitData(this.client, this.preferences);
}
