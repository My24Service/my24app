import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/company/models/leave_type/form_data.dart';
import 'package:my24app/company/blocs/leave_type_bloc.dart';
import 'package:my24app/company/models/leave_type/models.dart';
import 'package:my24app/core/i18n_mixin.dart';

class LeaveTypeFormWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "company.leave_types";
  final LeaveTypeFormData formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String memberPicture;
  final bool newFromEmpty;

  LeaveTypeFormWidget({
    Key key,
    @required this.memberPicture,
    @required this.formData,
    @required this.newFromEmpty,
  }) : super(
      key: key,
      memberPicture: memberPicture
  );

  @override
  void doRefresh(BuildContext context) {
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return formData.id == null ? $trans('app_bar_title_new') : $trans('app_bar_title_edit');
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  Widget getContentWidget(BuildContext context) {
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
                  createSubmitSection(_getButtons(context))
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
          createCancelButton(() => _navList(context)),
          SizedBox(width: 10),
          createSubmitButton(() => _submitForm(context)),
        ]
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        wrapGestureDetector(context, Text($trans('info_name'))),
        TextFormField(
            controller: formData.nameController,
            validator: (value) {
              return null;
            }
        ),

        CheckboxListTile(
            title: wrapGestureDetector(context, Text($trans('info_counts_as_leave'))),
            value: formData.countsAsLeave,
            onChanged: (newValue) {
              formData.countsAsLeave = newValue;
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
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      if (!formData.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<LeaveTypeBloc>(context);
      if (formData.id != null) {
        LeaveType updatedLeaveType = formData.toModel();
        bloc.add(LeaveTypeEvent(status: LeaveTypeEventStatus.DO_ASYNC));
        bloc.add(LeaveTypeEvent(
            pk: updatedLeaveType.id,
            status: LeaveTypeEventStatus.UPDATE,
            leaveType: updatedLeaveType,
        ));
      } else {
        LeaveType newLeaveType = formData.toModel();
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
        formData: formData
    ));
  }
}
