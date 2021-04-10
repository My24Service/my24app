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

Widget loadingNotice() {
  return Center(
      child: Column(
        children: [
          SizedBox(height: 30),
          Text('generic.loading'.tr())
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

ElevatedButton createBlueElevatedButton(String text, Function callback, { primaryColor=Colors.blue, onPrimary=Colors.white}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      primary: primaryColor, // background
      onPrimary: onPrimary, // foreground
    ),
    child: new Text(text),
    onPressed: callback,
  );
}



Widget createHeader(String text) {
  return Container(child: Column(
    children: [
      SizedBox(
        height: 10.0,
      ),
      Text(text, style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.grey
      )),
      SizedBox(
        height: 10.0,
      ),
    ],
  ));
}
