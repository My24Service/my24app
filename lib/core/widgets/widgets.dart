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
