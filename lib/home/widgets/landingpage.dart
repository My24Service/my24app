import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my24app/member/models/models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class LandingPageWidget extends StatelessWidget {
  final bool doSkip;
  MemberPublic _member;
  bool _error = false;
  List<MemberPublic> _members = [];

  LandingPageWidget({
    Key key,
    @required this.doSkip,
  }): super(key: key);

  Widget _buildSkipView(BuildContext context) {
    return Builder(
        builder: (context) => Center(
            child: Column(
              children: [
                CachedNetworkImage(
                  height: 120,
                  width: 100,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  imageUrl: _member.companylogoUrl,
                ),
                Divider(),
                SizedBox(height: 50),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // background
                      onPrimary: Colors.white, // foreground
                    ),
                    child: new Text('main.button_continue_to_member'.tr()),
                    onPressed: () {
                      // Navigator.pushReplacement(context,
                      //     new MaterialPageRoute(builder: (context) => MemberPage())
                      // );
                    }
                )

              ],
            )
        )
    );
  }

  _doFetchMembers() {

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

  Widget _buildList() {
    if (_error) {
      return RefreshIndicator(
        child: Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                Text('main.error_loading'.tr())
              ],
            )
        ), onRefresh: () => _doFetchMembers(),
      );
    }

    if (_members.length == 0) {
      return Center(child: CircularProgressIndicator());
    }

    RefreshIndicator list = RefreshIndicator(
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: _members.length,
          itemBuilder: (BuildContext context, int index) {
            MemberPublic member = _members[index];

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
                                // Navigator.of(context).pop();
                                // Navigator.push(context,
                                //     new MaterialPageRoute(builder: (context) => MemberPage())
                                // );
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
      onRefresh: () => _doFetchMembers(),
    );

    return Column(
      children: [
        list
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if(doSkip) {
      // get member
      return _buildSkipView(context);
    }

    // get members
    return _buildList();
  }
}
