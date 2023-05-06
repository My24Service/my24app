import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/member/models/public/models.dart';
import '../blocs/preferences/blocs.dart';
import '../models.dart';

class PreferencesWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "interact.preferences";
  final Members members;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String memberPicture;
  final PreferencesFormData formData;

  PreferencesWidget({
    Key key,
    @required this.memberPicture,
    @required this.members,
    @required this.formData,
  }) : super(
      key: key,
      memberPicture: memberPicture
  );

  @override
  String getAppBarTitle(BuildContext context) {
    return $trans('app_bar_title');
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
                ]
              )
            )
          )
        )
    );
  }

  // private methods
  Widget _buildForm(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text($trans('info_language_code')),
          DropdownButton<String>(
            value: formData.preferedLanguageCode,
            items: <String>['nl', 'en'].map((String value) {
              return new DropdownMenuItem<String>(
                child: new Text(value),
                value: value,
              );
            }).toList(),
            onChanged: (newValue) {
              formData.preferedLanguageCode = newValue;
              print('set language to: $newValue');
              // refresh?
              _updateFormData(context);
            },
          ),
          // Text('settings.info_skip_member_list'.tr()),
          CheckboxListTile(
              title: Text($trans('info_skip_member_list')),
              value: formData.skipMemberList,
              onChanged: (newValue) {
                formData.skipMemberList = newValue;
                // refresh?
                _updateFormData(context);
              }
          ),
          if(formData.skipMemberList)
            DropdownButtonFormField<String>(
              value: formData.preferedMemberCompanyCode,
              items: members == null ? [] : members.results.map((Member member) {
                return new DropdownMenuItem<String>(
                  child: new Text(member.name),
                  value: member.companycode,
                );
              }).toList(),
              onChanged: (newValue) async {
                Member member = members.results.firstWhere(
                        (member) => member.companycode == newValue,
                    orElse: () => members.results.first
                );

                formData.preferedMemberPk = member.pk;
                formData.preferedMemberCompanyCode = newValue;

                // refresh?
                _updateFormData(context);
              },
            ),
          SizedBox(
            height: 20.0,
          ),
          createDefaultElevatedButton(
              $trans('button_save'),
              () { _submitForm(context); }
          )
        ]
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      final bloc = BlocProvider.of<PreferencesBloc>(context);
      bloc.add(PreferencesEvent(status: PreferencesEventStatus.DO_ASYNC));
      bloc.add(PreferencesEvent(
          status: PreferencesEventStatus.UPDATE,
          formData: formData,
      ));
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<PreferencesBloc>(context);
    bloc.add(PreferencesEvent(status: PreferencesEventStatus.DO_ASYNC));
    bloc.add(PreferencesEvent(
        status: PreferencesEventStatus.UPDATE_FORM_DATA,
        formData: formData,
    ));
  }
}
