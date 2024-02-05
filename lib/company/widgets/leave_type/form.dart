import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/slivers/app_bars.dart';

import 'package:my24app/company/models/leave_type/form_data.dart';
import 'package:my24app/company/blocs/leave_type_bloc.dart';
import 'package:my24app/company/models/leave_type/models.dart';

class LeaveTypeFormWidget extends StatefulWidget {
  final LeaveTypeFormData? formData;
  final String? memberPicture;
  final bool? newFromEmpty;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  
  LeaveTypeFormWidget({
    Key? key,
    required this.memberPicture,
    required this.formData,
    required this.newFromEmpty,
    required this.widgetsIn,
    required this.i18nIn,
  });

  @override
  State<StatefulWidget> createState() => new _LeaveTypeFormWidgetState();
}

class _LeaveTypeFormWidgetState extends State<LeaveTypeFormWidget> with TextEditingControllerMixin{
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    addTextEditingController(nameController, widget.formData!, 'name');
    super.initState();
  }

  void dispose() {
    disposeTextEditingControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
            slivers: <Widget>[
              getAppBar(context),
              SliverToBoxAdapter(child: getContent(context))
            ]
        )
    );
  }

  SliverAppBar getAppBar(BuildContext context) {
    SmallAppBarFactory factory = SmallAppBarFactory(context: context, title: getAppBarTitle(context));
    return factory.createAppBar();
  }

  String getAppBarTitle(BuildContext context) {
    return widget.formData!.id == null ? widget.i18nIn.$trans('app_bar_title_new') : widget.i18nIn.$trans('app_bar_title_edit');
  }

  Widget getContent(BuildContext context) {
    return Container(
        child: Form(
          key: _formKey,
          child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(    // new line
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: _buildForm(context),
                  ),
                  widget.widgetsIn.createSubmitSection(_getButtons(context) as Row)
                ]
              )
            )
          )
        )
    );
  }

  // private methods
  Widget _getButtons(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.widgetsIn.createCancelButton(() => _navList(context)),
          SizedBox(width: 10),
          widget.widgetsIn.createSubmitButton(context, () => _submitForm(context)),
        ]
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        widget.widgetsIn.wrapGestureDetector(context, Text(widget.i18nIn.$trans('info_name'))),
        TextFormField(
            controller: nameController,
            validator: (value) {
              return null;
            }
        ),

        CheckboxListTile(
            title: widget.widgetsIn.wrapGestureDetector(context, Text(widget.i18nIn.$trans('info_counts_as_leave'))),
            value: widget.formData!.countsAsLeave,
            onChanged: (newValue) {
              widget.formData!.countsAsLeave = newValue;
              _updateFormData(context);
            }
        ),
      ],
    );
  }

  void _navList(BuildContext context) {
    final bloc = BlocProvider.of<LeaveTypeBloc>(context);
    bloc.add(LeaveTypeEvent(status: LeaveTypeEventStatus.DO_ASYNC));
    bloc.add(LeaveTypeEvent(
        status: LeaveTypeEventStatus.FETCH_ALL
    ));
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState!.validate()) {
      this._formKey.currentState!.save();
      // print('name: ${formData!.name}');
      // return;

      if (!widget.formData!.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<LeaveTypeBloc>(context);
      if (widget.formData!.id != null) {
        LeaveType updatedLeaveType = widget.formData!.toModel();
        bloc.add(LeaveTypeEvent(status: LeaveTypeEventStatus.DO_ASYNC));
        bloc.add(LeaveTypeEvent(
            pk: updatedLeaveType.id,
            status: LeaveTypeEventStatus.UPDATE,
            leaveType: updatedLeaveType,
        ));
      } else {
        LeaveType newLeaveType = widget.formData!.toModel();
        bloc.add(LeaveTypeEvent(status: LeaveTypeEventStatus.DO_ASYNC));
        bloc.add(LeaveTypeEvent(
            status: LeaveTypeEventStatus.INSERT,
            leaveType: newLeaveType,
        ));
      }
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<LeaveTypeBloc>(context);
    bloc.add(LeaveTypeEvent(status: LeaveTypeEventStatus.DO_ASYNC));
    bloc.add(LeaveTypeEvent(
        status: LeaveTypeEventStatus.UPDATE_FORM_DATA,
        formData: widget.formData
    ));
  }
}
