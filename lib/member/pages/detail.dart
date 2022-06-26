import 'package:flutter/material.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/member/widgets/detail.dart';

class MemberPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MemberPageState();
  }
}

class _MemberPageState extends State<MemberPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: utils.getMemberName(),
      builder: (ctx, snapshot) {
        String memberName = snapshot.data;

        return FutureBuilder<bool>(
          future: utils.isLoggedInSlidingToken(),
          builder: (ctx, snapshot) {
            bool isLoggedIn = snapshot.data;

            return Scaffold(
              appBar: AppBar(
                title: Text(memberName != null ? memberName : ''),
              ),
              body: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: MemberDetailWidget(isLoggedIn)
              )
            );
          }
        );
      }
    );
  }
}
