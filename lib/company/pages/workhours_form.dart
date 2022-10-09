import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24app/company/pages/workhours_list.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/company/blocs/workhours_bloc.dart';
import 'package:my24app/company/blocs/workhours_states.dart';
import 'package:my24app/company/widgets/workhours_form.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';

class UserWorkHoursFormPage extends StatefulWidget {
  final int pk;

  UserWorkHoursFormPage({
    Key key,
    this.pk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _UserWorkHoursFormPageState();
}

class _UserWorkHoursFormPageState extends State<UserWorkHoursFormPage> {
  bool firstTime = true;
  bool isEdit = false;

  UserWorkHoursBloc _initialBlocCall() {
    UserWorkHoursBloc bloc = UserWorkHoursBloc();

    if (widget.pk != null) {
      bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
      bloc.add(UserWorkHoursEvent(
          status: UserWorkHoursEventStatus.FETCH_DETAIL, pk: widget.pk));
      print('fetch detail ${widget.pk}');
    } else {
      bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.NEW));
    }

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
                                'company.workhours.app_bar_title_form'.tr())
                            ),
                            // drawer: drawer,
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
    if (state is UserWorkHoursInsertedState) {
      if (state.hours != null) {
        createSnackBar(context, 'company.workhours.snackbar_created'.tr());

        final page = UserWorkHoursListPage();

        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)
        );
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'company.workhours.error_inserting_dialog_content'.tr()
        );
      }
    }

    if (state is UserWorkHoursEditedState) {
      if (state.result) {
        createSnackBar(context, 'company.workhours.snackbar_updated'.tr());

        final page = UserWorkHoursListPage();

        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)
        );
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'company.workhours.error_updating_dialog_content'.tr()
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
              status: UserWorkHoursEventStatus.FETCH_DETAIL,
              pk: widget.pk
          )
      );
    }

    if (state is UserWorkHoursNewState) {
      return UserWorkHoursFormWidget();
    }

    if (state is UserWorkHoursDetailLoadedState) {
      return UserWorkHoursFormWidget(
        pk: widget.pk,
        hours: state.hours,
      );
    }

    return loadingNotice();
  }
}
