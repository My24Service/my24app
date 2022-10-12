import 'package:flutter/material.dart';

GlobalKey<NavigatorState> _key;

GlobalKey<NavigatorState> getKey() {
  if (_key == null) {
    print('creating new key');
    _key = GlobalKey<NavigatorState>();
  } else {
    print('returning existing key');
  }

  return _key;
  // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

void deleteKey() {
  print('unsetting key');
  _key = null;
}
