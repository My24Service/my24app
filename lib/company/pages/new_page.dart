import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/common/utils.dart';
import 'package:my24app/company/blocs/leavehours_bloc.dart';
import 'package:my24app/company/blocs/leavehours_states.dart';
import 'package:my24app/company/models/leavehours/models.dart';
import 'package:my24app/common/widgets/drawers.dart';
import '../models/leavehours/form_data.dart';

String? initialLoadMode;
int? loadId;

class UserLeaveHoursPage extends StatelessWidget{
  final UserLeaveHoursBloc bloc;
  final Utils utils = Utils();
  final CoreWidgets widgets = CoreWidgets();
  final i18n = My24i18n(basePath: "company.leavehours");

  Future<UserLeaveHoursPageData> getPageData(BuildContext context) async {
    String? memberPicture = await this.utils.getMemberPicture();
    String? submodel = await this.utils.getUserSubmodel();

    UserLeaveHoursPageData result = UserLeaveHoursPageData(
        drawer: await getDrawerForUserWithSubmodel(context, submodel),
        memberPicture: memberPicture,
        isPlanning: submodel == 'planning_user'
    );

    return result;
  }

  UserLeaveHoursPage({
    Key? key,
    required this.bloc,
    String? initialMode,
    int? pk
  }) : super(key: key) {
    initialLoadMode = initialMode;
    loadId = pk;
  }

  UserLeaveHoursBloc _initialBlocCall(bool isPlanning) {
    // mostly used for testing the different return widgets, but allways
    // fetches a list for users, edits get triggered with a BLoC call inside
    // the list
    if (initialLoadMode == null) {
      bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
      bloc.add(UserLeaveHoursEvent(
          status: UserLeaveHoursEventStatus.FETCH_ALL,
          isPlanning: isPlanning
      ));
    } else if (initialLoadMode == 'edit') {
      bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));

      // new event: FORM that emits something that tells the form to load
      // formData for pk

      // bloc.add(UserLeaveHoursEvent(
      //     status: UserLeaveHoursEventStatus.FETCH_DETAIL,
      //     pk: loadId,
      //     isPlanning: isPlanning
      // ));
    } else if (initialLoadMode == 'new') {
      // new event: FORM that emits something that tells the form to init a new
      // formData (pk null)

      // bloc.add(UserLeaveHoursEvent(
      //     status: UserLeaveHoursEventStatus.NEW,
      //     isPlanning: isPlanning
      // ));
    } else if (initialLoadMode == 'unaccepted') {
      bloc.add(UserLeaveHoursEvent(
          status: UserLeaveHoursEventStatus.FETCH_UNACCEPTED,
          isPlanning: isPlanning
      ));
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserLeaveHoursPageData>(
        future: getPageData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            UserLeaveHoursPageData? pageData = snapshot.data;

            return BlocProvider<UserLeaveHoursBloc>(
                create: (context) => _initialBlocCall(pageData!.isPlanning),
                child: BlocConsumer<UserLeaveHoursBloc, UserLeaveHoursState>(
                    listener: (context, state) {
                      _handleListeners(context, state, pageData);
                    },
                    builder: (context, state) {
                      return Scaffold(
                        drawer: pageData!.drawer,
                        body: _getBody(context, state, pageData),
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            print('snapshot.error ${snapshot.error}');
            return Center(
                child: Text(
                    i18n.$trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": "${snapshot.error}"}
                    )
                )
            );
          } else {
            return Scaffold(
                body: widgets.loadingNotice()
            );
          }
        }
    );
  }

  void _handleListeners(BuildContext context, state,
      UserLeaveHoursPageData? pageData) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    if (state is UserLeaveHoursInsertedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_added'));

      bloc.add(UserLeaveHoursEvent(
          status: UserLeaveHoursEventStatus.FETCH_ALL,
          isPlanning: pageData!.isPlanning
      ));
    }

    // etc.
  }

  Widget _getBody(context, state, UserLeaveHoursPageData pageData) {
    // based on state, return stateless (list) of stateful (form) widget
    // where the model fetch happens in the bloc, that way we keep the loading spinner
    // as it is which is fine and troublesome in the initState()
    return UserLeaveHoursFormWidget(
      memberPicture: pageData.memberPicture,
      isPlanning: pageData.isPlanning,
      leaveHours: null,
    );
  }
}


class UserLeaveHoursFormWidget extends StatefulWidget {
  final String? memberPicture;
  final bool isPlanning;
  final UserLeaveHours? leaveHours;

  UserLeaveHoursFormWidget({
    Key? key,
    required this.memberPicture,
    required this.isPlanning,
    required this.leaveHours
  });

  @override
  State<StatefulWidget> createState() => new _UserLeaveHoursFormWidgetState();
}

class _UserLeaveHoursFormWidgetState extends State<UserLeaveHoursFormWidget> with TextEditingControllerMixin {
  // we want to create this here because it changes based on user input, not in outer page where a setState
  // does a rebuild and resets the formData
  UserLeaveHoursFormData? formData;

  @override
  void initState() {
    // new formData, from model if not null, empty otherwise
    // do we want to fetch any needed data here or inside the formData?
    // is that still testable (inside the formData)?

    // no api calls here because we can't mock this,
    // or create it in the pages and pass it on to the widgets so we can still
    // override the Page (widget.api.httpClient = client)

    // also, fetching data here means a second loading spinner

    super.initState();
  }

  void dispose() {
    disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return spinner if some fetch data is null?

    return BlocListener<UserLeaveHoursBloc, UserLeaveHoursState>(
      listener: (context, state) {
        // do stuff here based on UserLeaveHoursBloc's state
        // if needed for forms, for example here the API call to get totals
        // for changed data, but we could that via a setState()?
      },
      child: CustomScrollView(

      ),
    );
  }
}
