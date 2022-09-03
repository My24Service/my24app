import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../../company/models/models.dart';
import '../../core/utils.dart';
import '../widgets/channel.dart';

class ChatPage extends StatefulWidget {
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

  Future<InitData> _initConnection(StreamChatClient client) async {
    String userId, token;
    StreamInfo streamInfo = await utils.getStreamInfo();
    userId = streamInfo.memberUserId;
    token = streamInfo.token;

    if (client.state.currentUser == null) {
      if (userId != null && token != null) {
        print('connecting user');
        await client.connectUser(
          User(
            id: userId,
            name: streamInfo.user.fullName,
            extraData: {
              'name': streamInfo.user.fullName,
            },
          ),
          token,
        );
      } else {
        print('EMPTY? userId: $userId, token: $token');
      }
    } else {
      print('user already connected?');
      print(client.state.currentUser);
    }

    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    final String memberLogo = sharedPrefs.getString('member_logo_url');

    final channel = client.channel(
      "team",
      id: streamInfo.channelId,
      extraData: {
        "name": streamInfo.channelTitle,
        "image": memberLogo,
      },
    );

    await channel.watch();

    final prefs = await StreamingSharedPreferences.instance;

    return InitData(client, prefs, channel, streamInfo);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final client = StreamChat.of(context).client;

    return FutureBuilder(
        future: _initConnection(client),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          InitData initData = snapshot.data;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (initData != null)
                PreferenceBuilder<int>(
                  preference: initData.preferences.getInt(
                    'theme',
                    defaultValue: 0,
                  ),
                  builder: (context, snapshot) => StreamChatTheme(
                    data: StreamChatThemeData(
                      brightness: Theme.of(context).brightness,
                    ),
                    child: ChannelWidget(initData: initData, directMessageChannel: null),
                  ),
                )
            ],
          );
      }
    );
  }
}

class InitData {
  final StreamChatClient client;
  final StreamingSharedPreferences preferences;
  final Channel channel;
  final StreamInfo streamInfo;

  InitData(
      this.client,
      this.preferences,
      this.channel,
      this.streamInfo
    );
}
