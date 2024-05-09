import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_member_models/public/api.dart';
import 'package:my24_flutter_member_models/public/models.dart';

import 'package:my24app/common/utils.dart';
import 'package:my24app/common/widgets/widgets.dart';
import 'package:my24app/home/blocs/home_bloc.dart';
import 'package:my24app/home/blocs/home_states.dart';
import 'package:my24app/home/pages/home.dart';
import 'package:my24app/company/models/models.dart';
import 'package:my24app/order/pages/list.dart';

import '../../company/blocs/workhours_bloc.dart';
import '../../company/pages/workhours.dart';
import '../../mobile/blocs/assignedorder_bloc.dart';
import '../../mobile/pages/assigned.dart';

// we have three modes of entry:
// - not logged in, no member
// - not logged in, member
// - logged in
class LoginWidget extends StatelessWidget {
  final Member? member;
  final BaseUser? user;
  final My24i18n i18n;
  final String languageCode;
  final String? equipmentUuid;

  const LoginWidget({
    super.key,
    required this.member,
    required this.user,
    required this.i18n,
    required this.languageCode,
    this.equipmentUuid
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              LanguageChooser(
                currentLanguage: languageCode,
              ),
            ],
          ),
          Center(
              child: Container(
                width: 360.0,
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: BodyColumn(
                    member: member,
                    user: user,
                    i18n: i18n,
                    languageCode: languageCode,
                    equipmentUuid: equipmentUuid,
                  ),
                ),
              )
          )
        ],
      )
    );
  }
}

class My24Logo extends StatelessWidget {
  const My24Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 100,
        height: 210,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/icon/icon.png", cacheWidth: 100),
            ]
        )
    );
  }
}

class CompanyLogo extends StatelessWidget {
  final String memberPicture;
  const CompanyLogo({
    super.key,
    required this.memberPicture
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 100,
        height: 100,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(memberPicture, cacheWidth: 100),
            ]
        )
    );
  }
}

class LoginTextFields extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final My24i18n i18n;

  const LoginTextFields({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.i18n
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
              labelText: i18n.$trans('username')
          ),
        ),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
              labelText: i18n.$trans('password')
          ),
          obscureText: true,
        )
      ],
    );
  }
}

class LoggedInButtons extends StatelessWidget {
  final My24i18n i18n;
  final bool isPlanning;
  final BaseUser? user;
  final Member? member;
  final CoreWidgets coreWidgets = CoreWidgets();

  LoggedInButtons({
    super.key,
    required this.i18n,
    required this.isPlanning,
    required this.member,
    required this.user,
  });

  void _navAssignedOrders(BuildContext context) {
    final page = AssignedOrdersPage(
      bloc: AssignedOrderBloc(),
    );

    Navigator.push(context, MaterialPageRoute(
        builder: (context) => page
    ));
  }

  void _navOrders(BuildContext context) {
    Navigator.push(context, new MaterialPageRoute(
        builder: (context) => OrderListPage(
          bloc: OrderBloc(),
          fetchMode: OrderEventStatus.fetchAll,
        ))
    );
  }

  void _navWorkhours(BuildContext context) {
    Navigator.push(context, new MaterialPageRoute(
        builder: (context) => UserWorkHoursPage(
          bloc: UserWorkHoursBloc(),
        ))
    );
  }

  Widget _getButton(BuildContext context) {
    if (user is EngineerUser) {
      return coreWidgets.createDefaultElevatedButton(
          context,
          i18n.$trans('button_go_to_orders'),
          () => _navAssignedOrders(context)
      );
    }

    if (user is EmployeeUser) {
      return coreWidgets.createDefaultElevatedButton(
          context,
          i18n.$trans('button_go_to_workhours'),
          () => _navWorkhours(context)
      );
    }

    return coreWidgets.createDefaultElevatedButton(
        context,
        i18n.$trans('button_go_to_orders'),
        () => _navOrders(context)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _getButton(context)
      ],
    );
  }
}

class LoginButtons extends StatelessWidget {
  final TextEditingController companycodeController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final My24i18n i18n;
  final Member? member;
  final CoreWidgets coreWidgets = CoreWidgets();

  LoginButtons({
    super.key,
    required this.i18n,
    required this.usernameController,
    required this.passwordController,
    required this.companycodeController,
    required this.member
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        coreWidgets.createDefaultElevatedButton(
          context,
          i18n.$trans('button_login'),
          () async { _loginPressed(context); }
        ),
        const SizedBox(height: 10),
        createElevatedButtonColored(
            i18n.$trans('button_forgot_password'),
            _passwordReset
        ),
        const SizedBox(height: 10),
        createElevatedButtonColored(
            i18n.$trans('button_change_member'),
            () async { _changeMember(context); }
        ),
      ],
    );
  }

  _changeMember(BuildContext context) async {
    final bloc = BlocProvider.of<HomeBloc>(context);
    bloc.add(HomeEvent(
        status: HomeEventStatus.clearMember
    ));
  }

  _passwordReset () async {
    final url = await utils.getUrl('/frontend/#/reset-password');
    coreUtils.launchURL(url.replaceAll('/api', ''));
  }

  _loginPressed (BuildContext context) async {
    final bloc = BlocProvider.of<HomeBloc>(context);
    bloc.add(const HomeEvent(status: HomeEventStatus.doAsync));

    if (member == null) {
      if (companycodeController.text == "") {
        displayDialog(
            context,
            i18n.$trans('error_dialog_title_no_companycode'),
            i18n.$trans('error_dialog_content_no_companycode')
        );

        return;
      }

      // set this here for the API URL
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('companycode', companycodeController.text);

      bloc.add(HomeEvent(
          status: HomeEventStatus.doLogin,
          doLoginState: HomeDoLoginState(
              companycode: companycodeController.text,
              userName: usernameController.text,
              password: passwordController.text
          )
      ));
    } else {
      bloc.add(HomeEvent(
          status: HomeEventStatus.doLogin,
          doLoginState: HomeDoLoginState(
              companycode: member!.companycode!,
              userName: usernameController.text,
              password: passwordController.text
          )
      ));
    }
  }
}

class LanguageChooser extends StatelessWidget {
  final String currentLanguage;
  final List<Map<String, String>> languages = [
    {
      'lang': 'en',
      'text': 'English',
      'img': 'langs/en.png'
    },
    {
      'lang': 'nl',
      'text': 'Nederlands',
      'img': 'langs/nl.png'
    }
  ];

  LanguageChooser({
    super.key,
    required this.currentLanguage
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
        child:ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton(
            hint: const Text("Select language"),
            value: currentLanguage,
            onChanged: (newValue) async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('preferred_language_code', newValue!);
              if (context.mounted) {
                context.setLocale(coreUtils.lang2locale(newValue)!);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => My24App())
                );
              }
            },
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    Image.asset("assets/langs/en.png", width: 25),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: const Text("English"),
                    )
                  ],
                )
              ),
              DropdownMenuItem(
                value: 'nl',
                child: Row(
                  children: [
                    Image.asset("assets/langs/nl.png", width: 25),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: const Text("Nederlands"),
                    )
                  ],
                )
              )
            ]
          ),
        )
    );
  }
}

class MemberSection extends StatelessWidget {
  final Member? member;
  final TextEditingController companycodeController;
  final My24i18n i18n;
  final memberApi = MemberListPublicApi();
  final String languageCode;

  MemberSection({
    super.key,
    required this.member,
    required this.companycodeController,
    required this.i18n,
    required this.languageCode
  });

  @override
  Widget build(BuildContext context) {
    // member logo and info when entering the app with member data
    if (member != null) {
      return Column(
          children: [
            CompanyLogo(memberPicture: checkNull(member!.companylogoUrl)),
            const SizedBox(height: 10),
            Center(child: MemberInfoCard(member: member!)),
          ]
      );
    }

    // return manual entry else
    return Center(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const My24Logo(),
            TypeAheadFormField<Member>(
              debounceDuration: const Duration(seconds: 1),
              minCharsForSuggestions: 2,
              textFieldConfiguration: TextFieldConfiguration(
                controller: companycodeController,
                decoration: InputDecoration(
                    labelText: i18n.$trans('typeahead_label_search_company')
                ),
              ),
              suggestionsCallback: (pattern) async {
                return await memberApi.search(pattern);
              },
              itemBuilder: (context, Member suggestion) {
                return ListTile(
                  title: Text(suggestion.companycode!),
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (member) async {
                companycodeController.text = member.companycode!;
              },
              validator: (value) {
                return null;
              },
              onSaved: (value) => {
              },
            ),
          ],
        )
    );
  }
}

class BodyColumn extends StatefulWidget {
  final Member? member;
  final My24i18n i18n;
  final BaseUser? user;
  final String languageCode;
  final String? equipmentUuid;

  const BodyColumn({
    super.key,
    required this.member,
    required this.i18n,
    required this.user,
    required this.languageCode,
    required this.equipmentUuid
  });

  @override
  State<StatefulWidget> createState() => _BodyColumnState();
}

class _BodyColumnState extends State<BodyColumn> {
  final TextEditingController companycodeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final CoreWidgets coreWidgets = CoreWidgets();

  @override
  void dispose() {
    companycodeController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return Column(
        children: <Widget>[
          MemberSection(
            member: widget.member,
            companycodeController: companycodeController,
            i18n: widget.i18n,
            languageCode: widget.languageCode,
          ),
          if (widget.equipmentUuid != null)
            EquipmentNotice(
              i18n: widget.i18n,
            ),
          LoginTextFields(
              usernameController: usernameController,
              passwordController: passwordController,
              i18n: widget.i18n
          ),
          const SizedBox(height: 10),
          LoginButtons(
              i18n: widget.i18n,
              usernameController: usernameController,
              member: widget.member,
              passwordController: passwordController,
              companycodeController: companycodeController
          ),
        ],
      );
    }

    return Column(
      children: <Widget>[
        MemberSection(
          member: widget.member,
          companycodeController: companycodeController,
          i18n: widget.i18n,
          languageCode: widget.languageCode,
        ),
        const Divider(),
        LoggedInButtons(
          i18n: widget.i18n,
          isPlanning: widget.user is PlanningUser,
          user: widget.user,
          member: widget.member,
        )
      ],
    );
  }
}

class EquipmentNotice extends StatelessWidget {
  final My24i18n i18n;

  const EquipmentNotice({
    super.key,
    required this.i18n
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(i18n.$trans('equipment_login_notice'))
      ],
    );
  }

}