import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

Widget errorNotice() {
  return Center(
          child: Column(
          children: [
            SizedBox(height: 30),
            Text('main.error_loading'.tr())
          ],
        )
      );
}

Widget buildMemberInfoCard(member) => SizedBox(
  height: 150,
  width: 1000,
  child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        ListTile(
          title: Text('${member.name}',
              style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
              '${member.address}\n${member.countryCode}-${member.postal}\n${member.city}'),
          leading: Icon(
            Icons.home,
            color: Colors.blue[500],
          ),
        ),
        ListTile(
          title: Text('${member.tel}',
              style: TextStyle(fontWeight: FontWeight.w500)),
          leading: Icon(
            Icons.contact_phone,
            color: Colors.blue[500],
          ),
        ),
      ],
    ),
  ),
);




Widget buildEmptyListFeedback() {
  return Column(
    children: [
      SizedBox(height: 1),
      Text('generic.empty_table'.tr(), style: TextStyle(fontStyle: FontStyle.italic))
    ],
  );
}
