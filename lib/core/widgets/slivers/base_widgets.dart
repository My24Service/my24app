import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/models/models.dart';

import 'app_bars.dart';


abstract class BaseSliverPlainStatelessWidget extends StatelessWidget {
  // base class for forms, errors, non-lists
  BaseSliverPlainStatelessWidget({
    Key key,
  }) : super(key: key);

  Widget getContentWidget(BuildContext context);
  Widget getBottomSection(BuildContext context);

  String getAppBarTitle(BuildContext context);
  String getAppBarSubtitle(BuildContext context);
  void doRefresh(BuildContext context);

  SliverAppBar getAppBar(BuildContext context) {
    GenericAppBarFactory factory = GenericAppBarFactory(
        context: context,
        title: getAppBarTitle(context),
        subtitle: getAppBarSubtitle(context),
        onStretch: doRefresh
    );
    return factory.createAppBar();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Expanded(
              child: CustomScrollView(
                  slivers: <Widget>[
                    getAppBar(context),
                    SliverList(
                        delegate: SliverChildListDelegate([
                          Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                      children: [
                                        getContentWidget(context)
                                      ]
                                  )
                              )
                          )
                        ])
                    )
                  ]
              )
          ),
          getBottomSection(context)
        ]
    );
  }
}

abstract class BaseSliverListStatelessWidget extends StatelessWidget {
  final PaginationInfo paginationInfo;
  final String modelName;

  // base class for lists
  BaseSliverListStatelessWidget({
    Key key,
    @required this.paginationInfo,
    @required this.modelName
  }) : super(key: key);

  void doRefresh(BuildContext context);
  String getAppBarTitle(BuildContext context);
  String getAppBarSubtitle(BuildContext context);
  Widget getBottomSection(BuildContext context);
  SliverList getSliverList(BuildContext context);

  SliverAppBar getAppBar(BuildContext context) {
    GenericAppBarFactory factory = GenericAppBarFactory(
        context: context,
        title: getAppBarTitle(context),
        subtitle: getAppBarSubtitle(context),
        onStretch: doRefresh
    );
    return factory.createAppBar();
  }

  SliverPersistentHeader makePaginationHeader(BuildContext context) {
    return makeDefaultPaginationHeader(
        context,
        paginationInfo,
        modelName
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Expanded(
              child: CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: <Widget>[
                    getAppBar(context),
                    makePaginationHeader(context),
                    getSliverList(context)
                  ]
              )
          ),
          getBottomSection(context)
        ]
    );
  }
}

abstract class BaseEmptyWidget extends BaseSliverPlainStatelessWidget {
  final String emptyMessage;

  BaseEmptyWidget({
    Key key,
    @required this.emptyMessage,
  }) : super(key: key);

  @override
  Widget getContentWidget(BuildContext context) {
    return Center(
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(emptyMessage)
          ],
        )
    );
  }
}

abstract class BaseErrorWidget extends BaseSliverPlainStatelessWidget {
  final String error;

  BaseErrorWidget({
    Key key,
    @required this.error,
  }) : super(key: key);

  @override
  Widget getContentWidget(BuildContext context) {
    return errorNotice(error);
  }
}
