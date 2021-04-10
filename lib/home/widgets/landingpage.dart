import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/member/blocs/fetch_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/member/blocs/fetch_states.dart';
import 'package:my24app/member/models/models.dart';
import 'package:my24app/member/pages/detail.dart';


// ignore: must_be_immutable
class LandingPageWidget extends StatelessWidget {
  final bool doSkip;

  LandingPageWidget({
    Key key,
    @required this.doSkip,
  }): super(key: key);

  Widget _buildSkipView(BuildContext context, MemberPublic member) {
    return Builder(
        builder: (context) => Center(
            child: Column(
              children: [
                CachedNetworkImage(
                  height: 120,
                  width: 100,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  imageUrl: member.companylogoUrl,
                ),
                Divider(),
                SizedBox(height: 50),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // background
                      onPrimary: Colors.white, // foreground
                    ),
                    child: new Text('main.button_continue_to_member'.tr()),
                    onPressed: () async {
                      await _storeMemberInfo(member.companycode, member.pk, member.name);
                      Navigator.pushReplacement(context,
                          new MaterialPageRoute(builder: (context) => MemberPage())
                      );
                    }
                )
              ],
            )
        )
    );
  }

  _storeMemberInfo(String companycode, int pk, String memberName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // generic prefs
    await prefs.setString('companycode', companycode);
    await prefs.setInt('member_pk', pk);
    await prefs.setString('member_name', memberName);

    // prefered member prefs
    await prefs.setBool('skip_member_list', true);
    await prefs.setInt('prefered_member_pk', pk);
    await prefs.setString('prefered_companycode', companycode);
  }

  Widget _buildList(List<MemberPublic> members, BuildContext context) {
    RefreshIndicator list = RefreshIndicator(
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: members.length,
          itemBuilder: (BuildContext context, int index) {
            MemberPublic member = members[index];

            return ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      member.companylogoUrl),
                ),
                title: Text(member.name),
                subtitle: Text(member.companycode),
                onTap: () async {
                  await _storeMemberInfo(member.companycode, member.pk, member.name);

                  showDialog<void>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('main.alert_title_member_stored'.tr()),
                          content: Text('main.alert_content_member_stored'.tr(
                              namedArgs: {'companyName': member.name})),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(context,
                                    new MaterialPageRoute(builder: (context) => MemberPage())
                                );
                              },
                            ),
                          ],
                        );
                      }
                  );
                } // onTab
            );
          } // itemBuilder
      ),
      onRefresh: () {
        final bloc = BlocProvider.of<FetchMemberBloc>(context);
        bloc.add(FetchMemberEvent(status: MemberEventStatus.FETCH_MEMBERS));
      },
    );

    return Column(
      children: [
        list
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchMemberBloc, MemberFetchState>(
        builder: (context, state) {
          if (state is MemberFetchInitialState) {
            return Text('loading');
          }

          if (state is MemberFetchLoadingState) {
            return Text('loading');
          }

          if (state is MemberFetchErrorState) {
            return errorNotice();
          }

          if(doSkip) {
            if (state is MemberFetchLoadedState) {
              return _buildSkipView(context, state.member);
            }
          } else {
            if (state is MembersFetchLoadedState) {
              return _buildList(state.members.results, context);
            }
          }

          return errorNotice();
        }
    );
  }
}
