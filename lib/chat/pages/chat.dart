import 'package:flutter/material.dart';
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
  Future<InitData> _initConnection(StreamChatClient client) async {
    String userId, token, channelId, channelTitle, fullName;
    StreamInfo streamInfo = await utils.getStreamInfo();
    userId = streamInfo.memberUserId!;
    token = streamInfo.token!;
    channelId = streamInfo.channelId!;
    channelTitle = streamInfo.channelTitle!;
    fullName = streamInfo.user!.fullName!;

    await client.disconnectUser();

    OwnUser ownUser;

    ownUser = await client.connectUser(
      User(
        id: userId,
        name: fullName,
        extraData: {
          'name': fullName,
        },
      ),
      token,
    );

    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    final String? memberLogo = sharedPrefs.getString('member_logo_url');
    sharedPrefs.setString('channel_id', channelId);
    sharedPrefs.setInt('chat_unread_count', ownUser.totalUnreadCount);

    final channel = client.channel(
      "team",
      id: channelId,
      extraData: {
        "name": channelTitle,
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

    return FutureBuilder<InitData>(
        future: _initConnection(client),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          InitData? initData = snapshot.data;
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
