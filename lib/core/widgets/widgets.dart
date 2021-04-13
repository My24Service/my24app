import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

Widget errorNotice(String message) {
  return Center(
          child: Column(
          children: [
            SizedBox(height: 30),
            Text(message),
            SizedBox(height: 30),
          ],
        )
      );
}

Widget errorNoticeWithReload(String message, dynamic reloadBloc, dynamic reloadEvent) {
  return RefreshIndicator(
    child: ListView(
      children: [
        errorNotice(message),
      ],
    ),
    onRefresh: () {
      return Future.delayed(
          Duration(milliseconds: 5),
              () {
                reloadBloc.add(reloadEvent);
              }
      );
    }
  );
}

Widget loadingNotice() {
  return Center(child: CircularProgressIndicator());
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

displayDialog(context, title, text) {
  return showDialog(
    context: context,
    builder: (context) {
      AlertDialog(
          title: Text(title),
          content: Text(text)
      );
    }
  );
}

showDeleteDialogWrapper(String title, String content, BuildContext context, Function deleteFunction) {
  // set up the button
  Widget cancelButton = TextButton(
      child: Text('utils.button_cancel'.tr()),
      onPressed: () => Navigator.of(context).pop(false)
  );
  Widget deleteButton = TextButton(
      child: Text('utils.button_delete'.tr()),
      onPressed: () => Navigator.of(context).pop(true)
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      cancelButton,
      deleteButton,
    ],
  );

  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  ).then((dialogResult) {
    if (dialogResult == null) return;

    if (dialogResult) {
      deleteFunction();
    }
  });
}

createSnackBar(BuildContext context, String content) {
  final snackBar = SnackBar(
    content: Text(content),
    // action: SnackBarAction(
    //   label: 'Undo',
    //   onPressed: () {
    //     // Some code to undo the change.
    //   },
    // ),
  );

  // Find the ScaffoldMessenger in the widget tree
  // and use it to show a SnackBar.
  try {
    Scaffold.of(context).showSnackBar(snackBar);
  } catch(e) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

Widget createTable(List<TableRow> rows) {
  return Table(
      border: TableBorder(horizontalInside: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid)),
      children: rows
  );
}

Widget createTableHeaderCell(String content) {
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: Text(content, style: TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget createTableColumnCell(String content) {
  return Padding(
    padding: EdgeInsets.all(4.0),
    child: Text(content != null ? content : ''),
  );
}
