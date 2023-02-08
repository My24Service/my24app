import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:my24app/company/api/company_api.dart';
import 'package:my24app/company/models/models.dart';

import 'package:my24app/core/widgets/widgets.dart';

import '../../core/utils.dart';
import '../blocs/workhours_bloc.dart';
import '../pages/workhours_list.dart';

class UserWorkHoursFormWidget extends StatefulWidget {
  final int pk;
  final UserWorkHours hours;

  UserWorkHoursFormWidget({
    Key key,
    this.pk,
    this.hours,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _UserWorkHoursFormWidgetState();
}

class _UserWorkHoursFormWidgetState extends State<UserWorkHoursFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _descriptionController = TextEditingController();
  var _startWorkHourController = TextEditingController();
  var _endWorkHourController = TextEditingController();
  var _travelToController = TextEditingController();
  var _travelBackController = TextEditingController();
  var _distanceToController = TextEditingController();
  var _distanceBackController = TextEditingController();

  var minutes = ['00', '05', '10', '15', '20', '25' ,'30', '35', '40', '45', '50', '55'];
  var _workStartMin = '00';
  var _workEndMin = '00';
  var _travelToMin = '00';
  var _travelBackMin = '00';

  DateTime _startDate = DateTime.now();

  ProjectsPaginated _projects;
  int _selectedProjectId;
  String _projectName;

  bool _inAsyncCall = false;

  @override
  void initState() {
    _onceGetProjects();
    
    if (widget.hours != null) {
      _startDate = DateFormat('yyyy-MM-dd').parse(widget.hours.startDate);
      _descriptionController.text = widget.hours.description;
      _selectedProjectId = widget.hours.project;
      _projectName = widget.hours.projectName;
    }
    super.initState();
  }

  _onceGetProjects() async {
    _projects = await companyApi.fetchProjectsForSelect();
    if (_projects.results.length > 0 && widget.hours == null) {
      _selectedProjectId = _projects.results[0].id;
      _projectName = _projects.results[0].name;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        child:_showMainView(),
        inAsyncCall: _inAsyncCall
    );
  }

  Widget _showMainView() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  createHeader(widget.hours != null ? 'company.workhours.header_edit'.tr() : 'company.workhours.header_add'.tr()),
                  Form(
                      key: _formKey,
                      child: _buildForm()
                  ),
                ]
            )
        )
    );
  }

  void _cancelEdit() {
    final page = UserWorkHoursListPage();

    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => page)
    );
  }

  _selectStartDate(BuildContext context) async {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        theme: DatePickerTheme(
            headerColor: Colors.orange,
            backgroundColor: Colors.blue,
            itemStyle: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            doneStyle: TextStyle(color: Colors.white, fontSize: 16)
        ),
        onChanged: (date) {
        },
        onConfirm: (date) {
          setState(() {
            _startDate = date;
          });
        },
        currentTime: _startDate,
        locale: LocaleType.en
    );
  }

  Widget _buildForm() {
    final double leftWidth = 100;
    final double rightWidth = 50;
    final double spaceBetween = 50;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('company.workhours.info_project'.tr()),
        DropdownButtonFormField<String>(
          value: _projectName,
          items: _projects == null || _projects.results.length == 0
              ? []
              : _projects.results.map((Project project) {
            return new DropdownMenuItem<String>(
              child: new Text(project.name),
              value: project.name,
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              Project project = _projects.results.firstWhere(
                      (_proj) => _proj.name == newValue);

              _selectedProjectId = project.id;
              _projectName = newValue;
            });
          },
        ),
        SizedBox(
          height: spaceBetween,
        ),
        Text('generic.info_description'.tr()),
        TextFormField(
            controller: _descriptionController,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: spaceBetween,
        ),
        Text('company.workhours.info_start_date'.tr()),
        createElevatedButtonColored(
            "${_startDate.toLocal()}".split(' ')[0],
            () => _selectStartDate(context),
            foregroundColor: Colors.white,
            backgroundColor: Colors.black
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('assigned_orders.activity.label_start_work'.tr()),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                        controller: _startWorkHourController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'assigned_orders.activity.validator_start_work_hour'.tr();
                          }
                          return null;
                        },
                        decoration: new InputDecoration(
                            labelText: 'assigned_orders.activity.info_hours'.tr()
                        ),
                      ),
                    ),
                    Container(
                        width: rightWidth,
                        child: _buildWorkStartMinutes()
                    )
                  ],
                )
              ],
            )
          ],
        ),
        SizedBox(
          height: spaceBetween,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('assigned_orders.activity.label_end_work'.tr()),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                          controller: _endWorkHourController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'assigned_orders.activity.validator_end_work_hour'.tr();
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                              labelText: 'assigned_orders.activity.info_hours'.tr()
                          )
                      ),
                    ),
                    Container(
                        width: rightWidth,
                        child: _buildWorkEndMinutes()
                    )
                  ],
                )
              ],
            )
          ],
        ),
        SizedBox(
          height: spaceBetween,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('assigned_orders.activity.label_travel_to'.tr()),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                          controller: _travelToController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return null;
                          },
                          decoration: new InputDecoration(
                              labelText: 'assigned_orders.activity.info_hours'.tr()
                          )
                      ),
                    ),
                    Container(
                        width: rightWidth,
                        child: _buildTravelToMinutes()
                    )
                  ],
                )
              ],
            )
          ],
        ),
        SizedBox(
          height: spaceBetween,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('assigned_orders.activity.label_travel_back'.tr()),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                          controller: _travelBackController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return null;
                          },
                          decoration: new InputDecoration(
                              labelText: 'assigned_orders.activity.info_hours'.tr()
                          )
                      ),
                    ),
                    Container(
                        width: rightWidth,
                        child: _buildTravelBackMinutes()
                    )
                  ],
                )
              ],
            )
          ],
        ),
        SizedBox(
          height: spaceBetween,
        ),
        Text('assigned_orders.activity.label_distance_to'.tr()),
        Container(
          width: 150,
          child: TextFormField(
              controller: _distanceToController,
              keyboardType: TextInputType.number,
              validator: (value) {
                return null;
              }),
        ),

        SizedBox(
          height: spaceBetween,
        ),
        Text('assigned_orders.activity.label_distance_back'.tr()),
        Container(
          width: 150,
          child: TextFormField(
              controller: _distanceBackController,
              keyboardType: TextInputType.number,
              validator: (value) {
                return null;
              }),
        ),
        // extra work
        SizedBox(
          height: spaceBetween,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            createDefaultElevatedButton(
                widget.hours == null ? 'company.workhours.button_add'.tr() :
                'company.workhours.button_edit'.tr(),
                _handleSubmit
            ),
            SizedBox(width: 10),
            createCancelButton(_cancelEdit),
          ],
        )
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();
      final bloc = BlocProvider.of<UserWorkHoursBloc>(context);

      // only continue if these are set
      if (_startWorkHourController.text == '0' && _workStartMin == '00' &&
          _endWorkHourController.text == '0' && _workEndMin == '00') {
        FocusScope.of(context).unfocus();
        return;
      }

      int _distanceTo = _distanceToController.text == null || _distanceToController.text == "" ? 0 : int.parse(_distanceToController.text);
      int _distanceBack = _distanceBackController.text == null || _distanceBackController.text == "" ? 0 : int.parse(_distanceBackController.text);
      String _travelTo = _travelToController.text == "" && _travelToMin == "00" ? null : '${_travelToController.text}:$_travelToMin:00';
      String _travelBack = _travelBackController.text == "" && _travelBackMin == "00" ? null : '${_travelBackController.text}:$_travelBackMin:00';

      UserWorkHours hours = UserWorkHours(
        project: _selectedProjectId,
        startDate: utils.formatDate(_startDate),
        workStart: '${_startWorkHourController.text}:$_workStartMin:00',
        workEnd: '${_endWorkHourController.text}:$_workEndMin:00',
        travelTo: _travelTo,
        travelBack: _travelBack,
        distanceTo: _distanceTo,
        distanceBack: _distanceBack,
        description: _descriptionController.text,
      );

      if (widget.hours == null) {
        bloc.add(UserWorkHoursEvent(
            status: UserWorkHoursEventStatus.INSERT,
            hours: hours
        ));
      } else {
        bloc.add(UserWorkHoursEvent(
            status: UserWorkHoursEventStatus.EDIT,
            hours: hours,
            pk: widget.hours.id
        ));
      }
    }
  }

  _buildWorkStartMinutes() {
    return DropdownButton<String>(
      value: _workStartMin,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _workStartMin = newValue;
        });
      },
    );
  }

  _buildWorkEndMinutes() {
    return DropdownButton<String>(
      value: _workEndMin,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _workEndMin = newValue;
        });
      },
    );
  }

  _buildTravelToMinutes() {
    return DropdownButton<String>(
      value: _travelToMin,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _travelToMin = newValue;
        });
      },
    );
  }

  _buildTravelBackMinutes() {
    return DropdownButton<String>(
      value: _travelBackMin,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _travelBackMin = newValue;
        });
      },
    );
  }

}
