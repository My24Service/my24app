import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/company/blocs/time_registration_bloc.dart';
import 'package:my24app/company/models/time_registration/models.dart';
import 'package:my24app/company/pages/time_registration.dart';
import 'mixins.dart';

typedef UserData = Map<String, dynamic>;

class TimeRegistrationListWidget extends BaseSliverListStatelessWidget with TimeRegistrationMixin{
  final TimeRegistration? timeRegistration;
  final PaginationInfo? paginationInfo;
  final String? memberPicture;
  final DateTime startDate;
  final bool isPlanning;
  final int? userId;
  final String mode;
  final double tableCellWidthFirst = 140.0;
  final double tableCellWidth = 120.0;
  final double tableCellHeight = 40.0;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  final ScrollControllers _scs = ScrollControllers();

  TimeRegistrationListWidget({
    Key? key,
    required this.timeRegistration,
    required this.paginationInfo,
    required this.memberPicture,
    required this.startDate,
    required this.isPlanning,
    required this.mode,
    required this.userId,
    required this.widgetsIn,
    required this.i18nIn,
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture,
      widgets: widgetsIn,
      i18n: i18nIn
  );

  @override
  String getAppBarSubtitle(BuildContext context) {
    if (isPlanning && userId == null) {
      List<String> titleColumn = _makeTitleColumn(context);
      return i18nIn.$trans('app_bar_subtitle',
          namedArgs: {'count': "${titleColumn.length}"}
      );
    }

    return timeRegistration!.fullName!;
  }

  Widget getBottomSection(BuildContext context) {
    final Color backgroundColorWeek = mode == 'week' ? Colors.blue : Colors.white;
    final Color foregroundColorWeek = mode == 'week' ? Colors.white : Colors.grey;

    final Color backgroundColorMonth = mode == 'month' ? Colors.blue : Colors.white;
    final Color foregroundColorMonth = mode == 'month' ? Colors.white : Colors.grey;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widgetsIn.createElevatedButtonColored(
          i18nIn.$trans("label_week"),
          () => _viewWeek(context),
          backgroundColor: backgroundColorWeek,
          foregroundColor: foregroundColorWeek
        ),
        SizedBox(width: 20),
        widgetsIn.createElevatedButtonColored(
          i18nIn.$trans("label_month"),
          () => _viewMonth(context),
          backgroundColor: backgroundColorMonth,
          foregroundColor: foregroundColorMonth
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> titleColumns = _makeTitleColumn(context);

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            children: [
              Expanded(
                child: NestedScrollView(
                  controller: _scs.verticalBodyController,
                  body: CustomScrollView(
                      controller: _scs.verticalBodyController,
                      slivers: [
                        getAppBar(context),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: DateNavHeaderDelegate(
                            minHeight: 40.0,
                            maxHeight: 40.0,
                            child: _buildDateHeaderRow(context),
                          ),
                        ),
                        // if (isPlanning && userId == null)
                        SliverStickyHeader(
                          header: _buildHeadTabRowWidget(
                            legendCell: Text(
                                _getFirstTotalsHeaderText(context),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )
                            ),
                            columnsLength: titleColumns.length,
                            columnsTitleBuilder: (i) => Text(
                                titleColumns[i],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )
                            ),
                          ),
                          sliver: _getTotalsTable(context),
                        ),
                        if (!isPlanning || (isPlanning && userId != null))
                          SliverStickyHeader(
                            header: Container(
                              color: Colors.white,
                              child: widgetsIn.createHeader(i18nIn.$trans('title_leavehours')),
                            ),
                            sliver: getSliverListLeave(context),
                          ),
                        if (!isPlanning || (isPlanning && userId != null))
                          SliverStickyHeader(
                            header: Container(
                              color: Colors.white,
                              child: widgetsIn.createHeader(i18nIn.$trans('title_workhours')),
                            ),
                            sliver: getSliverList(context),
                          ),
                      ]
                  ),
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => _buildHeadWidget(context),
              )
            ),
            getBottomSection(context)
          ]
        )
      );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    print('printing ${timeRegistration!.workhourData!.length} workhours');
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              WorkHourData timeData = timeRegistration!.workhourData![index];

              List<Widget> column1 = [];
              String? description = timeData.description != null ? timeData.description : "-";

              column1.addAll(widgetsIn.buildItemListKeyValueList(
                  i18nIn.$trans('info_date'),
                  "${timeData.date}",
                  withPadding: false
              ));
              column1.addAll(widgetsIn.buildItemListKeyValueList(
                  i18nIn.$trans('info_description'),
                  description,
                  withPadding: false
              ));

              List<Widget> column2 = [];

              column2.addAll(widgetsIn.buildItemListKeyValueList(
                  i18nIn.$trans('info_work_start_end', pathOverride: 'assigned_orders.activity'),
                  "${coreUtils.timeNoSeconds(timeData.workStart)} - ${coreUtils.timeNoSeconds(timeData.workEnd)}",
                  withPadding: false
              ));

              column2.addAll(widgetsIn.buildItemListKeyValueList(
                  i18nIn.$trans('info_travel_to_back', pathOverride: 'assigned_orders.activity'),
                  "${coreUtils.timeNoSeconds(timeData.travelTo)} - ${coreUtils.timeNoSeconds(timeData.travelBack)}",
                  withPadding: false
              ));

              column2.addAll(widgetsIn.buildItemListKeyValueList(
                  i18nIn.$trans('info_distance_to_back', pathOverride: 'assigned_orders.activity'),
                  "${timeData.distanceTo} - ${timeData.distanceBack}",
                  withPadding: false
              ));

              print("index $index, length ${timeRegistration!.workhourData!.length}");

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: column1,
                      ),
                      SizedBox(width: 50),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: column2,
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  // if (index == timeRegistration!.workhourData!.length-1 && timeRegistration!.workhourData!.length < 5)
                  //   SizedBox(height: 300),
                  if (index < timeRegistration!.workhourData!.length-1)
                    widgetsIn.getMy24Divider(context)
                ],
              );
            },
            childCount: timeRegistration!.workhourData!.length,
        )
    );
  }

  SliverList getSliverListLeave(BuildContext context) {
    print('printing ${timeRegistration!.leaveData!.length} leave');
    return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            LeaveData leaveData = timeRegistration!.leaveData![index];

            List<Widget> column = [];

            column.addAll(widgetsIn.buildItemListKeyValueList(
                i18nIn.$trans('info_date'),
                "${leaveData.date}",
                withPadding: false
            ));

            column.addAll(widgetsIn.buildItemListKeyValueList(
                i18nIn.$trans('info_leave_type', pathOverride: 'company.leavehours'),
                "${leaveData.leaveType}",
                withPadding: false
            ));

            column.addAll(widgetsIn.buildItemListKeyValueList(
                i18nIn.$trans('info_leave_duration'),
                "${leaveData.leaveDuration}",
                withPadding: false
            ));

            print("leave data: index $index, length ${timeRegistration!.leaveData!.length}");

            return Column(
              children: [
                ...column,
                SizedBox(height: 20),
                if (index < timeRegistration!.leaveData!.length-1)
                  widgetsIn.getMy24Divider(context),
                // if (index == timeRegistration!.leaveData!.length-1 && timeRegistration!.leaveData!.length < 5)
                //   SizedBox(height: 600),
              ],
            );
          },
          childCount: timeRegistration!.leaveData!.length,
        )
    );
  }

  // private methods
  List<Widget> _buildHeadWidget(BuildContext context) {
    return [
      // getAppBar(context),
    ];
  }

  SliverToBoxAdapter _getTotalsTable(BuildContext context) {
    Map<String, List<dynamic>> result = isPlanning && userId == null ?
    _buildValuesRowsPlanning(context) :
    _buildValuesRowsDetail(context);

    List<String> titleColumn = _makeTitleColumn(context);
    List titleRow = result['firstColumn']!;
    List userIds = [];

    if (isPlanning && userId == null) {
      userIds = result['userIds']!;
    }

    Widget content = Container(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: StickyHeadersTableInNested(
          cellAlignments: CellAlignments.fixed(
              contentCellAlignment: Alignment.topLeft,
              stickyColumnAlignment: Alignment.topLeft,
              stickyRowAlignment: Alignment.topLeft,
              stickyLegendAlignment: Alignment.topLeft
          ),
          columnsLength: titleColumn.length,
          rowsLength: titleRow.length,
          scrollControllers: _scs,
          columnsTitleBuilder: (i) =>
              Text(
                  titleColumn[i]
              ),
          rowsTitleBuilder: (i) =>
              Text(
                  titleRow[i]
              ),
          contentCellBuilder: (column, row) {
            return Text(result['rows']![row][column]);
          },
          onRowTitlePressed: (j) => _handleRowTitleClick(context, j, userIds),
        )
    );

    return SliverToBoxAdapter(
      child: content
    );
  }

  _handleRowTitleClick(BuildContext context, int index, List userIds) {
    if (!isPlanning) {
      return;
    }

    final int userId = userIds[index];

    // nav to self for detail view
    final page = TimeRegistrationPage(
      bloc: TimeRegistrationBloc(),
      pk: userId,
      modeIn: mode,
      startDateIn: startDate,
    );

    Navigator.push(context, MaterialPageRoute(
        builder: (context) => page
    ));
  }

  List<dynamic> _getIntervalData(int userId) {
    List result = [];

    for (int i = 0; i < timeRegistration!.intervals!.length; i++) {
      List intervalData = [];

      for (int j = 0; j < timeRegistration!.totals!.length; j++) {
        if (timeRegistration!.totals![j].userId == userId &&
            timeRegistration!.totals![j].interval == timeRegistration!.intervals![i]) {
          for (int k = 0; k < timeRegistration!.totalsFields!.length; k++) {
            final String field = timeRegistration!.totalsFields![k];
            dynamic value = timeRegistration!.totals![j].getValueByKey(field);
            intervalData.add({
              'total': value.intervalTotal,
              'field': field,
            });
          }
        }
      }

      result.add(intervalData);
    }

    return result;
  }

  List<dynamic> _getUserTotals(int userId) {
    for (int i = 0; i < timeRegistration!.totals!.length; i++) {
      if (timeRegistration!.totals![i].userId == userId) {
        List<dynamic> result = [];
        for (int k = 0; k < timeRegistration!.totalsFields!.length; k++) {
          final String field = timeRegistration!.totalsFields![k];
          dynamic value = timeRegistration!.totals![i].getValueByKey(field);
          result.add({
            'total': value.total,
            'field': field,
          });
        }

        return result;
      }
    }

    return [];
  }

  List<UserData> _normalizeData(BuildContext context) {
    List<UserData> results = [];
    Map<String, UserData> userDataMap = {};

    for (int i = 0; i < timeRegistration!.totals!.length; i++) {
      Map<String, String> rowObj = {
        'full_name': timeRegistration!.totals![i].fullName!,
        'user_id': "${timeRegistration!.totals![i].userId!}"
      };

      if (!userDataMap.containsKey(rowObj['user_id'])) {
        if (userDataMap.keys.length > 0) {
          results = _addUserDataToResults(userDataMap, results);
          userDataMap = {};
        }

        // init new user data structure
        userDataMap[rowObj['user_id']!] = {
          'user': rowObj,
          'interval_totals': _getIntervalData(timeRegistration!.totals![i].userId!),
          'user_totals': _getUserTotals(timeRegistration!.totals![i].userId!)
        };
      }
    } // end for all totals

    // add the final user
    if (userDataMap.keys.length > 0) {
      results = _addUserDataToResults(userDataMap, results);
    }

    return results;
  }

  Map<String, List<dynamic>> _buildValuesRowsPlanning(BuildContext context) {
    // planning, list of users
    List<UserData> results = _normalizeData(context);
    List<String> firstColumn = [];
    List<int> userIds = [];
    List<List<String>> rows = [];

    for (int i = 0; i < results.length; i++) {
      List<String> columns = [];

      firstColumn.add(
          results[i]['user']['full_name']
      );

      userIds.add(
          int.parse(results[i]['user']['user_id'])
      );

      for (int j = 0; j < results[i]['interval_totals'].length; j++) {
        columns.add(
            _formatIntervalList(results[i]['interval_totals'][j]),
        );
      }

      // add totals
      columns.add(
          _formatIntervalList(results[i]['user_totals'])
      );

      rows.add(columns);
    }

    return {
      'firstColumn': firstColumn,
      'userIds': userIds,
      'rows': rows
    };
  }

  Map<String, List<dynamic>> _buildValuesRowsDetail(BuildContext context) {
    List<List<String>> rows = [];
    List<String> firstColumn = [];
    List<UserData> results = _normalizeData(context);

    for (int i = 0; i < timeRegistration!.totalsFields!.length; i++) {
      List<String> columns = [];
      String field = timeRegistration!.totalsFields![i];

      firstColumn.add(
          _translateHoursField(field)
      );

      if (results.length == 1) {
        for (int j = 0; j < results[0]['interval_totals'].length; j++) {
          if (results[0]['interval_totals'][j].length == 0) {
            columns.add("");
          } else {
            columns.add(
                _formatValue(results[0]['interval_totals'][j][i])
            );
          }
        }
      } else {
        for (int j = 0; j < timeRegistration!.intervals!.length; j++) {
          columns.add("");
        }
      }

      // add total
      if (results.length == 1) {
        columns.add(
            _formatValue(results[0]['user_totals'][i])
        );
      } else {
        columns.add("-");
      }

      rows.add(columns);
    }

    return {
      'firstColumn': firstColumn,
      'rows': rows
    };
  }

  String _translateHoursField(String field) {
    return i18nIn.$trans("label_$field");
  }

  String _formatIntervalList(List dayData) {
    List<String> result = [];
    for(int i=0; i<dayData.length; i++) {
      if (dayData[i] != null) {
        result.add(dayData[i]['total']);
      }
    }

    return result.length > 0 ? result.join(' | ') : '';
  }

  List<UserData> _addUserDataToResults(UserData userData, List<UserData> results) {
    UserData data = userData[userData.keys.first];
    results.add(data);

    return results;
  }

  String _formatValue(dynamic value) {
    if (value == null) {
      return "";
    }

    return "${value['total']}";
  }

  List<String> _makeTitleColumn(BuildContext context) {
    List<String> items = [];

    for (int i=0; i<timeRegistration!.dateList!.length; i++) {
      items.add(
          _formatDateHeader(timeRegistration!.dateList![i])
      );
    }

    items.add(i18nIn.$trans("label_total"));

    return items;
  }

  String _getFirstTotalsHeaderText(BuildContext context) {
    if (isPlanning && userId == null) {
      return i18nIn.$trans("label_user");
    }

    return i18nIn.$trans("label_field");
  }

  String _formatDateHeader(DateTime dt) {
    switch (mode) {
      case 'week':
        {
          return DateFormat("E d").format(dt);
        }

      case 'month':
        {
          final int week = coreUtils.weekNumber(dt);
          return "week $week";
        }

      default:
        {
          return DateFormat("d/MMMM/y").format(dt);
        }
    }
  }

  Widget _buildDateHeaderRow(BuildContext context) {
    DateTime _startDate = startDate;
    String header;
    Function forwardFunc;
    Function backFunc;

    if (mode == 'week') {
      final int week = coreUtils.weekNumber(_startDate);
      final String startDateTxt = coreUtils.formatDateDDMMYYYY(_startDate);
      final String endDateTxt = coreUtils.formatDateDDMMYYYY(_startDate.add(Duration(days: 7)));

      header = "Week $week ($startDateTxt - $endDateTxt)";
      forwardFunc = _navWeekForward;
      backFunc = _navWeekBack;
    } else {
      header = DateFormat("MMMM y").format(_startDate);
      forwardFunc = _navMonthForward;
      backFunc = _navMonthBack;
    }

    return Container(
        color: Colors.white,
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.blue,
                size: 36.0,
                semanticLabel: 'Back',
              ),
              onPressed: () { backFunc(context); }
          ),
          Spacer(),
          Text(header),
          Spacer(),
          IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.blue,
                size: 36.0,
                semanticLabel: 'Forward',
              ),
              onPressed: () { forwardFunc(context); }
          ),
        ],
      )
    );
  }

  _viewWeek(BuildContext context) {
    final bloc = BlocProvider.of<TimeRegistrationBloc>(context);

    bloc.add(TimeRegistrationEvent(status: TimeRegistrationEventStatus.DO_ASYNC));
    bloc.add(TimeRegistrationEvent(
        status: TimeRegistrationEventStatus.SWITCH_MODE,
        startDate: startDate,
        mode: 'week',
        userId: userId
    ));
  }

  _viewMonth(BuildContext context) {
    final bloc = BlocProvider.of<TimeRegistrationBloc>(context);

    bloc.add(TimeRegistrationEvent(status: TimeRegistrationEventStatus.DO_ASYNC));
    bloc.add(TimeRegistrationEvent(
        status: TimeRegistrationEventStatus.SWITCH_MODE,
        startDate: startDate,
        mode: 'month',
        userId: userId
    ));
  }

  _navWeekBack(BuildContext context) {
    final bloc = BlocProvider.of<TimeRegistrationBloc>(context);
    final DateTime _startDate = startDate.subtract(Duration(days: 7));

    bloc.add(TimeRegistrationEvent(status: TimeRegistrationEventStatus.DO_ASYNC));
    bloc.add(TimeRegistrationEvent(
        status: TimeRegistrationEventStatus.FETCH_ALL,
        startDate: _startDate,
        mode: 'week',
        userId: userId
    ));
  }

  _navWeekForward(BuildContext context) {
    final bloc = BlocProvider.of<TimeRegistrationBloc>(context);
    final DateTime _startDate = startDate.add(Duration(days: 7));

    bloc.add(TimeRegistrationEvent(status: TimeRegistrationEventStatus.DO_ASYNC));
    bloc.add(TimeRegistrationEvent(
        status: TimeRegistrationEventStatus.FETCH_ALL,
        startDate: _startDate,
        mode: 'week',
        userId: userId
    ));
  }

  _navMonthBack(BuildContext context) {
    final bloc = BlocProvider.of<TimeRegistrationBloc>(context);
    final DateTime _startDate = new DateTime(startDate.year, startDate.month - 1, startDate.day);

    bloc.add(TimeRegistrationEvent(status: TimeRegistrationEventStatus.DO_ASYNC));
    bloc.add(TimeRegistrationEvent(
        status: TimeRegistrationEventStatus.FETCH_ALL,
        startDate: _startDate,
        mode: 'month',
        userId: userId
    ));
  }

  _navMonthForward(BuildContext context) {
    final bloc = BlocProvider.of<TimeRegistrationBloc>(context);
    final DateTime _startDate = new DateTime(startDate.year, startDate.month + 1, startDate.day);

    bloc.add(TimeRegistrationEvent(status: TimeRegistrationEventStatus.DO_ASYNC));
    bloc.add(TimeRegistrationEvent(
        status: TimeRegistrationEventStatus.FETCH_ALL,
        startDate: _startDate,
        mode: 'month',
        userId: userId
    ));
  }

  Widget _buildHeadTabRowWidget(
      {required Widget legendCell,
        required Widget Function(int columnIndex) columnsTitleBuilder,
        required int columnsLength}) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 8, right: 8),
      child: Row(
        children: <Widget>[
          /// STICKY LEGEND
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Container(
              width: CellDimensions.base.stickyLegendWidth,
              height: CellDimensions.base.stickyLegendHeight,
              // alignment: CellAlignments.base.stickyLegendAlignment,
              alignment: Alignment.centerLeft,
              child: legendCell,
            ),
          ),

          /// STICKY ROW
          Expanded(
            child: NotificationListener<ScrollNotification>(
              child: Scrollbar(
                // Key is required to avoid 'The Scrollbar's ScrollController has no ScrollPosition attached.
                key: Key('Row ${false}'),
                thumbVisibility: false,
                controller: _scs.horizontalTitleController,
                child: SingleChildScrollView(
                  reverse: false,
                  physics: CustomScrollPhysics().stickyRow,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      columnsLength,
                      (i) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {},
                        child: Container(
                          // key: globalRowTitleKeys[i] ??= GlobalKey(),
                          width: CellDimensions.base.stickyWidth(i),
                          height: CellDimensions.base.stickyLegendHeight,
                          // alignment: CellAlignments.base.rowAlignment(i),
                          alignment: Alignment.centerLeft,
                          child: columnsTitleBuilder(i),
                        ),
                      ),
                    ),
                  ),
                  controller: _scs.horizontalTitleController,
                ),
              ),
              onNotification: (notification) =>
              _scs.customNotificationListener?.call(
                notification: notification,
                controller: _scs.horizontalTitleController,
              ) ??
                  false,
            ),
          )
        ],
      ),
    );
  }
}

class DateNavHeaderDelegate extends SliverPersistentHeaderDelegate {
  DateNavHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class CommonSilverAppBarDelegate extends SliverPersistentHeaderDelegate {
  CommonSilverAppBarDelegate(this._tabBar, {this.height = 70});

  final Widget _tabBar;

  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
