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
      namedArgs: {'count': "${timeRegistration!.data!.length}"}
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
              TimeData timeData = timeRegistration!.data![index];

              List<Widget> items = [];
              String? project = timeData.projectName != null ? timeData.projectName : "-";

              items.addAll(buildItemListKeyValueList(
                  $trans('info_date'),
                  "${timeData.date}"
              ));
              items.addAll(buildItemListKeyValueList(
                  $trans('info_project'),
                  project
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
                  if (index < timeRegistration!.data!.length-1)
                    getMy24Divider(context)
                ],
              );
            },
            childCount: timeRegistration!.data!.length,
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

    return SizedBox(height: 1);
  }

  Widget _buildTotalsUser(BuildContext context) {
    // grid, scroll horizontally

    // every row in totals is data for a time unit (day/week) in dateList

    // annotate_fields are rows that should be rendered by what's in field_types[index] (duration/int)

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalsHeaderRow(context),
          ..._buildValuesRows(context)
        ],
      ),
    );
  }



  List<Widget> _buildValuesRows(BuildContext context) {
    List<UserData> results = [];
    List<Widget> rows = [];
    Map<String, UserData> userDataMap = {};

    // [user_id] = {
    //             user: obj,
    //             interval_totals: [],
    //             user_totals: {} / []
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
          'user_totals': {}
        };

        for (int k = 0; k < timeRegistration!.annotateFields!.length; k++) {
          if (timeRegistration!.fieldTypes![k] == 'duration') {
            userDataMap[rowObj['user_id']]!['user_totals'][timeRegistration!
                .annotateFields![k]] = Duration();
          } else {
            userDataMap[rowObj['user_id']]!['user_totals'][timeRegistration!
                .annotateFields![k]] = 0;
          }
        }
      }

      // fill user data
      for (int j = 0; j < timeRegistration!.dateList!.length; j++) {
        String bucketDate = DateFormat("d/MMMM/y").format(
            timeRegistration!.totals![i].bucket!);
        String dateListDate = DateFormat("d/MMMM/y").format(
            timeRegistration!.dateList![j]);
        if (bucketDate != dateListDate) {
          continue;
        }

        List intervalData = [];
        for (int k = 0; k < timeRegistration!.annotateFields!.length; k++) {
          dynamic value = timeRegistration!.totals![i].getValueByString(
              timeRegistration!.annotateFields![k]);
          intervalData.add(value);
          dynamic oldVal = userDataMap[rowObj['user_id']]!['user_totals'][this
              .timeRegistration!.annotateFields![k]];
          userDataMap[rowObj['user_id']]!['user_totals'][this.timeRegistration!
              .annotateFields![k]] = oldVal + value;
        }

        userDataMap[rowObj['user_id']]!['interval_totals'][j] = intervalData;
      }

      // add the final user
      if (userDataMap.keys.length > 0) {
        results = _addUserDataToResults(userDataMap, results);
      }
    }

    // first handle planning, list of users
    if (isPlanning) {
      for (int i = 0; i < results.length; i++) {
        List<Widget> columns = [];

        columns.add(
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

      return rows;
    } // end if planning

    // normal users
    List<Widget> columns = [];

    for (int i = 0; i < timeRegistration!.annotateFields!.length; i++) {
      String field = timeRegistration!.annotateFields![i];

      columns.add(
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
              child: Text(_formatValue(results[0]['interval_totals'][j][i], i)),
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
            child: Text(_formatValue(results[0]['user_totals'][i], i)),
          )
      );
    }

    return rows;
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
        if (timeRegistration!.fieldTypes![i] == 'duration') {
          result.add(utils.formatDuration(dayData[i]));
        } else {
          result.add(dayData[i]);
        }
      }
    }

    return result.length > 0 ? result.join(' | ') : '';
  }

  List<UserData> _addUserDataToResults(UserData userData, List<UserData> results) {
    // sum all totals for annotate fields so we can display them in an extra column by
    // annotation field index
    UserData data = userData[userData.keys.first];
    List<dynamic> userTotals = [];
    for (int k = 0; k < timeRegistration!.annotateFields!.length; k++) {
      if (timeRegistration!.fieldTypes![k] == 'duration') {
        userTotals.add(utils.formatDuration(data['user_totals'][timeRegistration!.annotateFields![k]]));
      } else {
        userTotals.add(data['user_totals'][timeRegistration!.annotateFields![k]]);
      }
    }
    data['user_totals'] = userTotals;
    results.add(data);

    return results;
  }

  String _formatValue(dynamic value, int fieldIndex) {
    if (value == null) {
      return "";
    }

    if (timeRegistration!.annotateFields![fieldIndex] == 'duration') {
      return utils.formatDuration(value);
    } else {
      return "$value";
    }
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
