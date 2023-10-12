import 'package:flutter/material.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/member/widgets/detail.dart';

import '../../core/widgets/widgets.dart';
import '../models/models.dart';

class MemberPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MemberDetailData>(
      future: utils.getMemberDetailData(),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          MemberDetailData detailData = snapshot.data!;

          return Scaffold(
              appBar: AppBar(
                title: Text(detailData.member!.name!),
              ),
              body: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: MemberDetailWidget(detailData: detailData)
              )
          );
        }  else if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text("An error occurred (${snapshot.error})"));
        } else {
          return Scaffold(
              body: loadingNotice()
          );
        }
      }
    );
  }
}
