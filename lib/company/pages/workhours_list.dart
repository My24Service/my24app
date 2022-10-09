import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/company/blocs/workhours_bloc.dart';
import 'package:my24app/company/blocs/workhours_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';

import '../widgets/workhours_list.dart';

class UserWorkHoursListPage extends StatefulWidget {
  UserWorkHoursListPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _UserWorkHoursListPageState();
}

class _UserWorkHoursListPageState extends State<UserWorkHoursListPage> {
  bool firstTime = true;

  UserWorkHoursBloc _initialBlocCall() {
    UserWorkHoursBloc bloc = UserWorkHoursBloc();

    bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
    bloc.add(UserWorkHoursEvent(
        status: UserWorkHoursEventStatus.FETCH_ALL,
        startDate: utils.getMonday()
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initialBlocCall(),
        child: FutureBuilder<Widget>(
            future: getDrawerForUser(context),
            builder: (ctx, snapshot) {
              final Widget drawer = snapshot.data;

              return FutureBuilder<String>(
                  future: utils.getUserSubmodel(),
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData) {
                      return Scaffold(
                          appBar: AppBar(title: Text('')),
                          body: Container()
                      );
                    }

                    return BlocConsumer<UserWorkHoursBloc, UserWorkHoursState>(
                        listener: (context, state) {
                          _listeners(context, state);
                        },
                        builder: (context, state) {
                          return Scaffold(
                            appBar: AppBar(title: Text(
                                'company.workhours.app_bar_title_list'.tr())
                            ),
                            drawer: drawer,
                            body: GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).requestFocus(
                                      new FocusNode());
                                },
                                child: _getBody(context, state)
                            )
                        );
                      }
                    );
                  }
              );
            }
        )
    );
  }

  _listeners(BuildContext context, state) {
    final UserWorkHoursBloc bloc = BlocProvider.of<UserWorkHoursBloc>(context);

    if (state is UserWorkHoursDeletedState) {
      if (state.result) {
        print('deleted');
        createSnackBar(context, 'company.workhours.snackbar_deleted'.tr());

        bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
        bloc.add(UserWorkHoursEvent(
            status: UserWorkHoursEventStatus.FETCH_ALL,
            startDate: utils.getMonday()
        ));
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'company.workhours.error_deleting_dialog_content'.tr()
        );
      }
    }
  }

  Widget _getBody(BuildContext context, state) {
    final UserWorkHoursBloc bloc = BlocProvider.of<UserWorkHoursBloc>(context);

    if (state is UserWorkHoursErrorState) {
      return errorNoticeWithReload(
          state.message,
          bloc,
          UserWorkHoursEvent(
              status: UserWorkHoursEventStatus.FETCH_ALL,
          )
      );
    }

    if (state is UserWorkHoursLoadedState) {
      return UserWorkHoursListWidget(
        results: state.results,
        startDate: state.startDate,
      );
    }

    return loadingNotice();
  }
}
