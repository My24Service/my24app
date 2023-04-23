import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../widgets/channel.dart';
import 'chat.dart';

class PrivatePage extends StatefulWidget {
  final Channel directMessageChannel;
  final InitData initData;

  const PrivatePage({
    Key key,
    this.directMessageChannel,
    this.initData
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _PrivatePageState();
}

class _PrivatePageState extends State<PrivatePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('chat.private.app_bar_title'.tr())),
        backgroundColor: StreamChatTheme
            .of(context)
            .colorTheme
            .appBg,
        body: Container(
          child: ChannelWidget(directMessageChannel: widget.directMessageChannel, initData: widget.initData),
        )
    );
  }
}
