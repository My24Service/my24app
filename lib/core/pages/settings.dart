import 'package:flutter/material.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/home/pages/home.dart';
import 'package:my24app/member/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/member/api/member_api.dart';
import 'package:my24app/core/utils.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() =>
      _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<MemberPublic> _members = [];
  String _preferedMemberCompanyCode;
  int _preferedMemberPk;
  String _preferedLanguageCode ;
  bool _skipMemberList = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // default to chosen member
    _preferedMemberCompanyCode = prefs.getString('companycode');
    _preferedMemberPk = prefs.getInt('member_pk');

    _preferedLanguageCode = prefs.getString('prefered_language_code');

    // override if set
    if (prefs.containsKey('prefered_companycode')) {
      _preferedMemberCompanyCode = prefs.getString('prefered_companycode');
    }

    if (prefs.containsKey('prefered_member_pk')) {
      _preferedMemberPk = prefs.getInt('prefered_member_pk');
    }

    if (prefs.containsKey('skip_member_list')) {
      _skipMemberList = prefs.getBool('skip_member_list');
    }

    Members result = await memberApi.fetchMembers();
    _members = result.results;

    setState(() {});
  }

  Widget _buildForm() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('settings.info_language_code'.tr()),
          DropdownButton<String>(
            value: _preferedLanguageCode,
            items: <String>['nl', 'en'].map((String value) {
              return new DropdownMenuItem<String>(
                child: new Text(value),
                value: value,
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _preferedLanguageCode = newValue;
              });
            },
          ),
          // Text('settings.info_skip_member_list'.tr()),
          CheckboxListTile(
              title: Text('settings.info_skip_member_list'.tr()),
              value: _skipMemberList,
              onChanged: (newValue) {
                setState(() {
                  _skipMemberList = newValue;
                });
              }
          ),
          if(_skipMemberList)
            DropdownButtonFormField<String>(
              value: _preferedMemberCompanyCode,
              items: _members == null ? [] : _members.map((MemberPublic member) {
                return new DropdownMenuItem<String>(
                  child: new Text(member.name),
                  value: member.companycode,
                );
              }).toList(),
              onChanged: (newValue) async {
                MemberPublic member = _members.firstWhere(
                        (member) => member.companycode == newValue,
                    orElse: () => _members.first
                );

                _preferedMemberPk = member.pk;
                _preferedMemberCompanyCode = newValue;

                setState(() {});
              },
            ),
          SizedBox(
            height: 20.0,
          ),
          createDefaultElevatedButton(
              'settings.button_save'.tr(),
              _handleSubmit
          )
        ]
    );
  }

  Future<void> _handleSubmit() async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('skip_member_list', _skipMemberList);

      if (_skipMemberList) {
        prefs.setInt('prefered_member_pk', _preferedMemberPk);
        prefs.setString('prefered_companycode', _preferedMemberCompanyCode);
      } else {
        prefs.remove('prefered_member_pk');
        prefs.remove('prefered_companycode');
      }

      prefs.setString('prefered_language_code', _preferedLanguageCode);

      createSnackBar(context, 'settings.snackbar_saved'.tr());

      context.locale = utils.lang2locale(_preferedLanguageCode);

      Navigator.pushReplacement(context,
          new MaterialPageRoute(builder: (context) => My24App())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('settings.app_bar_title'.tr()),
        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
                margin: new EdgeInsets.symmetric(horizontal: 20.0),
                child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      createHeader('settings.header_settings'.tr()),
                      Form(
                          key: _formKey,
                          child: _buildForm()
                      ),
                    ]
                )
            )
        )
    );
  }
}
