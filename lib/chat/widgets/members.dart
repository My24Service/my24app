import 'package:flutter/material.dart';
import 'package:my24app/chat/pages/chat.dart';
import 'package:my24app/chat/pages/private.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../company/models/models.dart';
import '../../core/utils.dart';
import '../../core/widgets/widgets.dart';

class MembersWidget extends StatefulWidget {
  final Channel channel;
  final InitData initData;

  const MembersWidget({
    Key key, this.channel,
    this.initData,
  }) : super(key: key);

  @override
  _MembersWidgetState createState() => _MembersWidgetState();
}

class _MembersWidgetState extends State<MembersWidget> {
  var _userListController = null;

  _MembersWidgetState();

  @override
  void initState() {
    List<String> members = widget.channel.state.members.map((e) => e.user.id).toList();

    _userListController = StreamUserListController(
      client: StreamChat.of(context).client,
      limit: 25,
      filter: Filter.and(
        [Filter.in_('id', members)],
      ),
      sort: [
        const SortOption(
          'name',
          direction: 1,
        ),
      ],
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _getList();
  }

  Future<void> _createAndJoinPrivateChannel(User otherUser) async {
    String channelId = await utils.createStreamPrivateChannel(otherUser.id);
    if (channelId == null) {
      displayDialog(context, "Error", "Error getting private channel");
      return false;
    }

    final client = StreamChat.of(context).client;
    final channel = client.channel(
      "messaging",
      id: channelId,
      extraData: {
        "members": [widget.initData.streamInfo.memberUserId, otherUser.id]
      },
    );

    channel.watch();

    final page = PrivatePage(directMessageChannel: channel, initData: widget.initData);
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  Widget _getList() {
    return RefreshIndicator(
      onRefresh: () => _userListController.refresh(),
      child: StreamUserListView(
        controller: _userListController,
        onUserTap: (user) async => {
          await _createAndJoinPrivateChannel(user)
        },
        // itemBuilder: (context, users, index, defaultWidget) {
        //   return Text(users[index].name);
        // },
      ),
    );
  }

}
