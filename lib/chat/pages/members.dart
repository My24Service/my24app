import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my24app/chat/widgets/members.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'chat.dart';

class MembersPage extends StatefulWidget {
  final Channel channel;
  final InitData initData;

  const MembersPage({
    Key key,
    this.channel,
    this.initData
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('chat.members.app_bar_title'.tr())),
        backgroundColor: StreamChatTheme
            .of(context)
            .colorTheme
            .appBg,
        body: Container(
            child: MembersWidget(channel: widget.channel, initData: widget.initData),
        )
    );
  }
}
