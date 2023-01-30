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
  var _durationHourController = TextEditingController();

  var minutes = ['00', '05', '10', '15', '20', '25' ,'30', '35', '40', '45', '50', '55'];
  var _durationMin = '00';

  DateTime _startDate = DateTime.now();

  ProjectsPaginated _projects;
  int _selectedProjectId;
  String _projectName;

  bool _inAsyncCall = false;

  @override
  void initState() {
    _onceGetProjects();
    
    if (widget.hours != null) {
      var durationParts = widget.hours.duration.split(":");
      _durationHourController.text = durationParts[0];
      _durationMin = "${durationParts[1]}";
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

  _buildDurationMinutes() {
    return DropdownButton<String>(
      value: _durationMin,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _durationMin = newValue;
        });
      },
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
        }, onConfirm: (date) {
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
          height: 10.0,
        ),
        Text('generic.info_description'.tr()),
        TextFormField(
            controller: _descriptionController,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
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
                Text('company.workhours.info_duration'.tr()),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                        controller: _durationHourController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'company.workhours.validator_duration_hour'.tr();
                          }
                          return null;
                        },
                        decoration: new InputDecoration(
                            labelText: 'company.workhours.info_hours'.tr()
                        ),
                      ),
                    ),
                    Container(
                        width: rightWidth,
                        child: _buildDurationMinutes()
                    )
                  ],
                )
              ],
            )
          ],
        ),
        SizedBox(
          height: 10.0,
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

      // only continue if times are entered
      if (_durationHourController.text == '0' && _durationMin == '00') {
        FocusScope.of(context).unfocus();
        return;
      }

      UserWorkHours hours = UserWorkHours(
        project: _selectedProjectId,
        startDate: utils.formatDate(_startDate),
        duration: '${_durationHourController.text}:$_durationMin:00',
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

}
