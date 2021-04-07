import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EventStatus { CHECK }

class CheckMemberSkipEvent {
  final EventStatus status;

  const CheckMemberSkipEvent({this.status});
}

class CheckMemberSkipBloc extends Bloc<CheckMemberSkipEvent, bool> {
  @override
  Stream<bool> mapEventToState(event) async* {
    if (event.status == EventStatus.CHECK) {
      final doSkip = await _checkSkipMemberList();
      yield doSkip;
    }
  }

  CheckMemberSkipBloc() : super(false) {}

  void dispose() {}

  Future<bool> _checkSkipMemberList() async {
    // check if we should skip the member list
    bool doSkip = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('skip_member_list')) {
      bool skip = prefs.getBool('skip_member_list');

      if (skip) {
        int memberPk = prefs.getInt('prefered_member_pk');

        if (memberPk != null) {
          await prefs.setInt('member_pk', memberPk);
          doSkip = true;
        }
      }
    }

    return doSkip;
  }
}
