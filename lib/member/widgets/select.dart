import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24app/member/blocs/fetch_bloc.dart';
import 'package:my24app/member/blocs/fetch_states.dart';
import 'package:my24app/member/models/public/models.dart';
import 'package:my24app/member/pages/detail.dart';
import 'package:my24app/home/pages/home.dart';
import 'package:my24app/common/utils.dart';

class SelectWidget extends StatelessWidget {
  final CoreWidgets widgets = CoreWidgets();

  SelectWidget({
    Key? key,
  }): super(key: key);

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<FetchMemberBloc>(context);
    bloc.add(FetchMemberEvent(status: MemberEventStatus.FETCH_MEMBERS));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchMemberBloc, MemberFetchState>(
        builder: (context, state) {
          if (state is MemberFetchInitialState) {
            return widgets.loadingNotice();
          }

          if (state is MemberFetchLoadingState) {
            return widgets.loadingNotice();
          }

          if (state is MemberFetchErrorState) {
            return _createErrorSection(context, state.message);
          }

          if (state is MembersFetchLoadedState) {
            return _buildList(state.members!.results!, context);
          }

          return _createErrorSection(context, "Unknown error");
        }
    );
  }

  Widget _buildList(List<Member> members, BuildContext context) {
    return RefreshIndicator(
        child: CustomScrollView(
          slivers: [
            SliverList(
                delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                      Member member = members[index];

                      return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                member.companylogoUrl!),
                          ),
                          title: Text(member.name!),
                          subtitle: Text(member.companycode!),
                          onTap: () async {
                            await utils.storeMemberInfo(
                                member.companycode!,
                                member.pk!,
                                member.name!,
                                member.companylogoUrl!,
                                member.hasBranches!
                            );

                            showDialog<void>(
                                context: context,
                                barrierDismissible: false, // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(My24i18n.tr('main.alert_title_member_stored')),
                                    content: Text(My24i18n.tr('main.alert_content_member_stored',
                                        namedArgs: {'companyName': member.name!})),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Ok'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) => MemberPage())
                                          );
                                        },
                                      ),
                                      TextButton(
                                          child: Text(My24i18n.tr('utils.button_cancel')),
                                          onPressed: () => Navigator.of(context).pop(false)
                                      ),
                                    ],
                                  );
                                }
                            );
                          } // onTab
                      );

                    },
                    childCount: members.length
                )

            )
          ],
        ),
        onRefresh: () async {
          await doRefresh(context);
        }
    );
  }

  Widget _createErrorSection(BuildContext context, String? error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        Center(child: Text("An error occurred ($error)")),
        SizedBox(height: 40),
        widgets.createElevatedButtonColored(
              My24i18n.tr('member_detail.button_member_list'),
              () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                prefs.remove('skip_member_list');
                prefs.remove('prefered_member_pk');
                prefs.remove('prefered_companycode');

                Navigator.pushReplacement(context,
                    new MaterialPageRoute(builder: (context) => My24App())
                );
            },
            foregroundColor: Colors.white,
            backgroundColor: Colors.red
        )
      ],
    );
  }
}
