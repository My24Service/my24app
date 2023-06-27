import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/company/blocs/time_registration_bloc.dart';
import 'package:my24app/company/models/time_registration/models.dart';
import 'mixins.dart';

typedef UserData = Map<String, dynamic>;

class TimeRegistrationListWidget extends BaseSliverListStatelessWidget with TimeRegistrationMixin, i18nMixin {
  final String basePath = "company.time_registration";
  final TimeRegistration? timeRegistration;
  final PaginationInfo? paginationInfo;
  final String? memberPicture;
  final DateTime? startDate;
  final bool isPlanning;
  final String mode;
  final double totalsCellWidth = 120.0;
  final double totalsCellHeight = 60.0;

  TimeRegistrationListWidget({
    Key? key,
    required this.timeRegistration,
    required this.paginationInfo,
    required this.memberPicture,
    required this.startDate,
    required this.isPlanning,
    required this.mode,
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture
  );

  @override
  String getAppBarSubtitle(BuildContext context) {
    return $trans('app_bar_subtitle',
      namedArgs: {'count': "${timeRegistration!.workhourData!.length}"}
    );
  }

  @override
  SliverList getPreSliverListContent(BuildContext context) {
    // totals, planning has users in it, time navigation?
    return SliverList(
        delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
            return Column(
              children: [
                _buildHeaderRow(context),
                SizedBox(height: 10),
                _buildTotals(context),
                getMy24Divider(context),
              ],
            );
          },
          childCount: 1,
        )
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              WorkHourData timeData = timeRegistration!.workhourData![index];

              List<Widget> items = [];
              String? description = timeData.description != null ? timeData.description : "-";

              items.addAll(buildItemListKeyValueList(
                  $trans('info_date'),
                  "${timeData.date}"
              ));
              items.addAll(buildItemListKeyValueList(
                  $trans('info_description'),
                  description
              ));
              items.addAll(buildItemListKeyValueList(
                  $trans('info_work_start_end', pathOverride: 'assigned_orders.activity'),
                  "${utils.timeNoSeconds(timeData.workStart)} - ${utils.timeNoSeconds(timeData.workEnd)}"
              ));

              if (timeData.travelTo != null || timeData.travelBack != null) {
                items.addAll(buildItemListKeyValueList(
                    $trans('info_travel_to_back', pathOverride: 'assigned_orders.activity'),
                    "${utils.timeNoSeconds(timeData.travelTo)} - ${utils.timeNoSeconds(timeData.travelBack)}"
                ));
              }

              if (timeData.distanceTo != 0 || timeData.distanceBack != 0) {
                items.addAll(buildItemListKeyValueList(
                    $trans('info_distance_to_back', pathOverride: 'assigned_orders.activity'),
                    "${timeData.distanceTo} - ${timeData.distanceBack}"
                ));
              }

              return Column(
                children: [
                  ...items,
                  SizedBox(height: 10),
                  if (index < timeRegistration!.workhourData!.length-1)
                    getMy24Divider(context)
                ],
              );
            },
            childCount: timeRegistration!.workhourData!.length,
        )
    );
  }

  // private methods
  Widget _buildTotals(BuildContext context) {
    if (isPlanning) {
      return _buildTotalsPlanning(context);
    }

    return _buildTotalsUser(context);
  }

  Widget _buildTotalsPlanning(BuildContext context) {
    // grid, scroll horizontally where the first column (user) stays fixed
    Map<String, List<Widget>> result = _buildValuesRowsPlanning(context);
    // Row headers = _buildTotalsHeaderRow(context);

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: result['firstColumn']!,
          ),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: result['rows']!,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTotalsUser(BuildContext context) {
    // grid, scroll horizontally where the first column (time data type) stays fixed
    Map<String, List<Widget>> result = _buildValuesRowsUser(context);

    return SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result['firstColumn']!,
            ),
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: result['rows']!,
                ),
              ),
            )
          ],
        ),
    );
  }

  List<UserData> _normalizeData(BuildContext context) {
    List<UserData> results = [];
    Map<String, UserData> userDataMap = {};

    // [user_id] = {
    //             user: obj,
    //             interval_totals: [],
    //             user_totals: []
    //           }

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
          'interval_totals': [],
          'user_totals': []
        };
      }

      // fill user data
      for (int j = 0; j < timeRegistration!.intervals!.length; j++) {
        if (timeRegistration!.totals![i].interval !=
            timeRegistration!.intervals![j]) {
          continue;
        }

        List intervalData = [];
        for (int k = 0; k < timeRegistration!.totalsFields!.length; k++) {
          final String field = timeRegistration!.totalsFields![k];
          dynamic value = timeRegistration!.totals![i].getValueByKey(field);
          intervalData.add({
            'total': value.intervalTotal,
            'field': field,
          });
        }

        userDataMap[rowObj['user_id']]!['interval_totals'][j] = intervalData;
      } // end for all intervals

      if (userDataMap[rowObj['user_id']]!['user_totals'].length == 0) {
        for (int k = 0; k < timeRegistration!.totalsFields!.length; k++) {
          final String field = timeRegistration!.totalsFields![k];
          dynamic value = timeRegistration!.totals![i].getValueByKey(field);
          userDataMap[rowObj['user_id']]!['user_totals'].add({
            'total': value.total,
            'field': field,
          });
        }
      }
    }

    // add the final user
    if (userDataMap.keys.length > 0) {
      results = _addUserDataToResults(userDataMap, results);
    }

    return results;
  }

  Map<String, List<Widget>> _buildValuesRowsPlanning(BuildContext context) {
    // planning, list of users
    List<UserData> results = _normalizeData(context);
    List<Widget> firstColumn = [];
    List<Widget> rows = [];

    for (int i = 0; i < results.length; i++) {
      List<Widget> columns = [];

      firstColumn.add(
          Container(
            alignment: Alignment.center,
            width: totalsCellWidth,
            height: totalsCellHeight,
            color: Colors.white,
            margin: EdgeInsets.all(4.0),
            child: Text(results[i]['user']['full_name']),
          )
      );

      for (int j = 0; j < results[i]['interval_totals'].length; j++) {
        columns.add(
            Container(
              alignment: Alignment.center,
              width: totalsCellWidth,
              height: totalsCellHeight,
              color: Colors.white,
              margin: EdgeInsets.all(4.0),
              child: Text(_formatIntervalList(results[i]['interval_totals'][j])),
            )
        );
      }

      // add totals
      columns.add(
          Container(
            alignment: Alignment.center,
            width: totalsCellWidth,
            height: totalsCellHeight,
            color: Colors.white,
            margin: EdgeInsets.all(4.0),
            child: Text(_formatIntervalList(results[i]['user_totals'])),
          )
      );

      rows.add(
          Row(
            children: columns,
          )
      );
    }

    return {
      'firstColumn': firstColumn,
      'rows': rows
    };
  }

  Map<String, List<Widget>> _buildValuesRowsUser(BuildContext context) {
    List<Widget> rows = [];
    List<Widget> firstColumn = [];
    List<UserData> results = _normalizeData(context);
    List<Widget> columns = [];

    for (int i = 0; i < timeRegistration!.totalsFields!.length; i++) {
      String field = timeRegistration!.totalsFields![i];

      firstColumn.add(
          Container(
            alignment: Alignment.center,
            width: totalsCellWidth,
            height: totalsCellHeight,
            color: Colors.white,
            margin: EdgeInsets.all(4.0),
            child: Text(_translateHoursField(field)),
          )
      );

      for (int j = 0; j < results[0]['interval_totals'].length; j++) {
        columns.add(
            Container(
              alignment: Alignment.center,
              width: totalsCellWidth,
              height: totalsCellHeight,
              color: Colors.white,
              margin: EdgeInsets.all(4.0),
              child: Text(_formatValue(results[0]['interval_totals'][j][i])),
            )
        );
      }

      // add total
      columns.add(
          Container(
            alignment: Alignment.center,
            width: totalsCellWidth,
            height: totalsCellHeight,
            color: Colors.white,
            margin: EdgeInsets.all(4.0),
            child: Text(_formatValue(results[0]['user_totals'][i])),
          )
      );
    }

    return {
      'firstColumn': firstColumn,
      'rows': rows
    };
  }

  String _translateHoursField(String field) {
    switch (field) {
      case 'work_total': {
        return $trans("Travel to total");
      }

      case 'travel_total': {
        return $trans('Travel to total');
      }

      case 'distance_total': {
        return $trans('Distance total');
      }

      case 'extra_work': {
        return $trans('Total extra work');
      }

      case 'actual_work': {
        return $trans('Total actual work');
      }

      case 'distance_fixed_rate_amount': {
        return $trans('Total trips');
      }

      default: {
        throw Exception("unknown field to translate: $field");
      }
    }
  }

  String _formatIntervalList(List dayData) {
    List<String> result = [];
    for(int i=0; i<dayData.length; i++) {
      if (dayData[i] != null) {
        result.add(dayData[i]);
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

    return "$value";
  }

  Row _buildTotalsHeaderRow(BuildContext context) {
    List<Widget> columns = [];

    for (int i=0; i<timeRegistration!.dateList!.length; i++) {
      columns.add(
        Container(
          alignment: Alignment.center,
          width: totalsCellWidth,
          height: totalsCellHeight,
          color: Colors.white,
          margin: EdgeInsets.all(4.0),
          child: Text(_formatDateHeader(timeRegistration!.dateList![i])),
        )
      );
    }

    return Row(
      children: columns,
    );
  }

  String _formatDateHeader(DateTime dt) {
    switch (mode) {
      case 'week':
        {
          return DateFormat("E d").format(dt);
        }

      case 'month':
        {
          final int week = utils.weekNumber(dt);
          return "week $week";
        }

      default:
        {
          return DateFormat("d/MMMM/y").format(dt);
        }
    }
  }

  Widget _buildHeaderRow(BuildContext context) {
    DateTime _startDate = startDate == null ? DateTime.now() : startDate!;
    final int week = utils.weekNumber(_startDate);
    final String startDateTxt = utils.formatDate(_startDate);
    final String endDateTxt = utils.formatDate(_startDate.add(Duration(days: 7)));
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
            onPressed: () { _navWeekBack(context); }
        ),
        Text(header),
        IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: Colors.blue,
              size: 36.0,
              semanticLabel: 'Forward',
            ),
            onPressed: () { _navWeekForward(context); }
        ),
      ],
    );
  }

  _navWeekBack(BuildContext context) {
    final bloc = BlocProvider.of<TimeRegistrationBloc>(context);
    final DateTime _startDate = startDate!.subtract(Duration(days: 7));

    bloc.add(TimeRegistrationEvent(status: TimeRegistrationEventStatus.DO_ASYNC));
    bloc.add(TimeRegistrationEvent(
        status: TimeRegistrationEventStatus.FETCH_ALL,
        startDate: _startDate
    ));
  }

  _navWeekForward(BuildContext context) {
    final bloc = BlocProvider.of<TimeRegistrationBloc>(context);
    final DateTime _startDate = startDate!.add(Duration(days: 7));

    bloc.add(TimeRegistrationEvent(status: TimeRegistrationEventStatus.DO_ASYNC));
    bloc.add(TimeRegistrationEvent(
        status: TimeRegistrationEventStatus.FETCH_ALL,
        startDate: _startDate
    ));
  }
}
