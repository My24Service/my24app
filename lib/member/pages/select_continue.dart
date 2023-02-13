import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:upgrader/upgrader.dart';

import '../blocs/fetch_bloc.dart';
import '../widgets/select_continue.dart';

class SelectContinueScaffold extends StatelessWidget {
  final bool doSkip;
  final FetchMemberBloc createBloc;

  SelectContinueScaffold({
    Key key,
    @required this.doSkip,
    @required this.createBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(doSkip ? 'main.app_bar_title_continue'.tr() : 'main.app_bar_title'.tr()),
          centerTitle: true,
        ),
        body: UpgradeAlert(
            child: BlocProvider(
                create: (BuildContext context) => createBloc,
                child: SelectContinueWidget(doSkip: doSkip)
            )
        )
    );
  }
}
