import 'package:flutter/material.dart';
import 'package:my24app/chat/pages/chat.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../company/models/models.dart';
import '../../core/utils.dart';
import '../pages/members.dart';

class ChannelWidget extends StatefulWidget {
  final int initialScrollIndex;
  final double initialAlignment;
  final bool highlightInitialMessage;
  final InitData initData;
  final Channel directMessageChannel;

  const ChannelWidget({
    this.initData,
    Key key,
    this.initialScrollIndex,
    this.initialAlignment,
    this.highlightInitialMessage = false,
    this.directMessageChannel,
  }) : super(key: key);

  @override
  _ChannelWidgetState createState() => _ChannelWidgetState();
}

class _ChannelWidgetState extends State<ChannelWidget> {
  FocusNode _focusNode;
  StreamMessageInputController _messageInputController =
      StreamMessageInputController();

  @override
  void initState() {
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _reply(Message message) {
    _messageInputController.quotedMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _focusNode.requestFocus();
    });
  }

  Future<StreamChatClient> _connectUser(client) async {
    String userId, token;
    StreamInfo streamInfo = await utils.getStreamInfo();

    userId = streamInfo.memberUserId;
    token = streamInfo.token;

    return client.connectUser(
      User(
        id: userId,
        name: streamInfo.user.fullName,
        extraData: {
          'name': streamInfo.user.fullName,
        },
      ),
      token,
    );
  }

  void _navMembersPage(Channel channel, InitData initData) {
    final page = MembersPage(channel: channel, initData: initData);

    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page)
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = StreamChat.of(context).client;
    final channel = widget.directMessageChannel != null ? widget.directMessageChannel : widget.initData.channel;

    return FutureBuilder(
        future: _connectUser(client),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return StreamChannel(
            channel: channel,
            child: Builder(
              builder: (context) {
                return Scaffold(
                  backgroundColor: StreamChatTheme
                      .of(context)
                      .colorTheme
                      .appBg,
                  appBar: StreamChannelHeader(
                    onTitleTap: () => {
                      _navMembersPage(widget.initData.channel, widget.initData)
                    },
                    showTypingIndicator: false,
                  ),
                  body: Column(
                    children: <Widget>[
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            StreamMessageListView(
                              initialScrollIndex: widget.initialScrollIndex,
                              initialAlignment: widget.initialAlignment,
                              highlightInitialMessage: widget
                                  .highlightInitialMessage,
                              onMessageSwiped: _reply,
                              // messageFilter: defaultFilter,
                              messageBuilder: (context, details, messages,
                                  defaultMessage) {
                                return defaultMessage.copyWith(
                                  onReplyTap: _reply,
                                );
                              },
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                color: StreamChatTheme
                                    .of(context)
                                    .colorTheme
                                    .appBg
                                    .withOpacity(.9),
                                child: StreamTypingIndicator(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  style: StreamChatTheme
                                      .of(context)
                                      .textTheme
                                      .footnote
                                      .copyWith(
                                      color: StreamChatTheme
                                          .of(context)
                                          .colorTheme
                                          .textLowEmphasis),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      StreamMessageInput(
                        disableAttachments: true,
                        focusNode: _focusNode,
                        messageInputController: _messageInputController,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
      );
    }

  // bool defaultFilter(Message m) {
  //   var _currentUser = StreamChat.of(context).currentUser;
  //   final isMyMessage = m.user?.id == _currentUser?.id;
  //   final isDeletedOrShadowed = m.isDeleted == true || m.shadowed == true;
  //   if (isDeletedOrShadowed && !isMyMessage) return false;
  //   return true;
  // }
}
