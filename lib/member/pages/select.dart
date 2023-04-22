import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:upgrader/upgrader.dart';

import '../blocs/fetch_bloc.dart';
import '../widgets/select.dart';

class SelectPage extends StatelessWidget {
  SelectPage({
    Key key,
  }) : super(key: key);

  FetchMemberBloc _getInitialBloc() {
    FetchMemberBloc bloc = FetchMemberBloc();
    bloc.add(FetchMemberEvent(
        status: MemberEventStatus.FETCH_MEMBERS)
    );

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('main.app_bar_title'.tr()),
          centerTitle: true,
        ),
        body: UpgradeAlert(
            child: BlocProvider(
                create: (BuildContext context) => _getInitialBloc(),
                child: SelectWidget()
            )
        )
    );
  }
}
