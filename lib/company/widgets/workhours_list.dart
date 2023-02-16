import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/company/models/models.dart';
import 'package:my24app/company/pages/workhours_form.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/core/widgets/widgets.dart';
import '../blocs/workhours_bloc.dart';

class UserWorkHoursListWidget extends StatefulWidget {
  final UserWorkHoursPaginated results;
  final DateTime startDate;
  final bool isPlanning;

  UserWorkHoursListWidget({
    Key key,
    this.results,
    this.startDate,
    this.isPlanning,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _UserWorkHoursListWidgetState();
}

class _UserWorkHoursListWidgetState extends State<UserWorkHoursListWidget> {
  bool _inAsyncCall = false;
  BuildContext _context;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return ModalProgressHUD(
        child:_showMainView(context),
        inAsyncCall: _inAsyncCall
    );
  }

  Widget _showMainView(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildHeaderRow(),
                  createDefaultElevatedButton(
                      'company.workhours.header_add'.tr(),
                      () { _handleNew(context); }
                  ),
                  _buildWorkHoursSection(context)
                ]
            )
        )
    );
  }

  Widget _buildHeaderRow() {
    final int week = utils.weekNumber(widget.startDate);
    final String startDateTxt = utils.formatDate(widget.startDate);
    final String endDateTxt = utils.formatDate(widget.startDate.add(Duration(days: 7)));
    final String header = "Week $week ($startDateTxt - $endDateTxt)";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.blue,
            size: 36.0,
            semanticLabel: 'Back',
          ),
          onPressed: () { _navWeekBack(); }
        ),
        Text(header),
        IconButton(
          icon: Icon(
            Icons.arrow_forward,
            color: Colors.blue,
            size: 36.0,
            semanticLabel: 'Forward',
          ),
          onPressed: () { _navWeekForward(); }
        ),
      ],
    );
  }

  _navWeekBack() {
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);
    final DateTime startDate = widget.startDate.subtract(Duration(days: 7));

    bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
    bloc.add(UserWorkHoursEvent(
        status: UserWorkHoursEventStatus.FETCH_ALL,
        startDate: startDate
    ));
  }

  _navWeekForward() {
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);
    final DateTime startDate = widget.startDate.add(Duration(days: 7));

    bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
    bloc.add(UserWorkHoursEvent(
        status: UserWorkHoursEventStatus.FETCH_ALL,
        startDate: startDate
    ));
  }

  Widget _buildWorkHoursSection(BuildContext context) {
    assert(context != null);
    String header = widget.isPlanning ? 'company.workhours.info_header_table_planning'.tr() : 'company.workhours.info_header_table'.tr();
    return buildItemsSection(
      context,
      header,
      widget.results.results,
      (UserWorkHours item) {
        List<Widget> items = [];
        String project = item.projectName != null ? item.projectName : "-";
        print(widget.isPlanning);

        if (widget.isPlanning) {
          items.addAll(buildItemListKeyValueList(
              'company.workhours.info_user'.tr(),
              "${item.fullName}"
          ));
        }

        items.addAll(buildItemListKeyValueList(
            'company.workhours.info_start_date'.tr(),
            "${item.startDate}"
        ));
        items.addAll(buildItemListKeyValueList(
            'company.workhours.info_project'.tr(),
            project
        ));
        items.addAll(buildItemListKeyValueList(
            'assigned_orders.activity.info_work_start_end'.tr(),
            "${utils.timeNoSeconds(item.workStart)} - ${utils.timeNoSeconds(item.workEnd)}"
        ));

        if (item.travelTo != null || item.travelBack != null) {
          items.addAll(buildItemListKeyValueList(
              'assigned_orders.activity.info_travel_to_back'.tr(),
              "${utils.timeNoSeconds(item.travelTo)} - ${utils.timeNoSeconds(item.travelBack)}"
          ));
        }

        if (item.distanceTo != 0 || item.distanceBack != 0) {
          items.addAll(buildItemListKeyValueList(
              'assigned_orders.activity.info_distance_to_back'.tr(),
              "${item.distanceTo} - ${item.distanceBack}"
          ));
        }

        return items;
      },
      (UserWorkHours item) {
        return [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              createEditButton(
                () { _handleEdit(item, context); }
              ),
              SizedBox(width: 10),
              createDeleteButton(
                "company.workhours.button_delete".tr(),
                () { _showDeleteDialog(item); }
              ),
            ],
          )
        ];
      },
    );
  }

  void _handleEdit(UserWorkHours hours, BuildContext context) {
    final page = UserWorkHoursFormPage(pk: hours.id);

    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => page)
    );
  }

  void _handleNew(BuildContext context) {
    final page = UserWorkHoursFormPage();

    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => page)
    );
  }

  _showDeleteDialog(UserWorkHours hours) {
    showDeleteDialogWrapper(
        'generic.delete_dialog_title_document'.tr(),
        'company.workhours.delete_dialog_content'.tr(),
        () => _doDelete(hours.id),
        _context
    );
  }

  _doDelete(int pk) async {
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);

    bloc.add(UserWorkHoursEvent(
        status: UserWorkHoursEventStatus.DELETE, pk: pk));
  }

}
