import 'package:flutter/material.dart';

import 'routing_constants.dart';
//import 'main.dart';
import 'login.dart';


Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
//    case HomeViewRoute:
//      return MaterialPageRoute(builder: (context) => My24App());
    case LoginViewRoute:
      return MaterialPageRoute(builder: (context) => LoginPageWidget());
//    default:
//      return MaterialPageRoute(builder: (context) => My24App());
  }
}
