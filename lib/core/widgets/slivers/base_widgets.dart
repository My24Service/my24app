import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/models/models.dart';
import '../../i18n_mixin.dart';
import 'app_bars.dart';


abstract class BaseSliverPlainStatelessWidget extends StatelessWidget with i18nMixin {
  final String? memberPicture;

  // base class for forms, errors, empty
  BaseSliverPlainStatelessWidget({
    Key? key,
    required this.memberPicture,
  }) : super(key: key);

  Widget getContentWidget(BuildContext context);
  Widget getBottomSection(BuildContext context);

  String getAppBarTitle(BuildContext context) {
    return $trans('app_bar_title');
  }

  String getAppBarSubtitle(BuildContext context) {
    return "";
  }

  SliverAppBar getAppBar(BuildContext context) {
    GenericAppBarFactory factory = GenericAppBarFactory(
        context: context,
        title: getAppBarTitle(context),
        subtitle: getAppBarSubtitle(context),
        memberPicture: memberPicture
    );
    return factory.createAppBar();
  }

  Widget getBuildContent(BuildContext context) {
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
                                        getContentWidget(context),
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

  @override
  Widget build(BuildContext context) {
    return getBuildContent(context);
  }
}

abstract class BaseSliverListStatelessWidget extends StatelessWidget with i18nMixin {
  final PaginationInfo? paginationInfo;
  final String? memberPicture;

  // base class for lists
  BaseSliverListStatelessWidget({
    Key? key,
    required this.paginationInfo,
    required this.memberPicture,
  }) : super(key: key);

  void doRefresh(BuildContext context);
  Widget getBottomSection(BuildContext context);
  SliverList getSliverList(BuildContext context);

  String getAppBarTitle(BuildContext context) {
    return $trans('app_bar_title');
  }

  String getAppBarSubtitle(BuildContext context) {
    return "";
  }

  String getModelName() {
    return $trans('model_name');
  }

  SliverList getPreSliverListContent(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return SizedBox(height: 1);
        },
        childCount: 1,
      )
    );
  }

  SliverAppBar getAppBar(BuildContext context) {
    GenericAppBarFactory factory = GenericAppBarFactory(
        context: context,
        title: getAppBarTitle(context),
        subtitle: getAppBarSubtitle(context),
        memberPicture: memberPicture
    );
    return factory.createAppBar();
  }

  bool _showPagination() {
    return paginationInfo!.previous != null && paginationInfo!.next != null;
  }

  SliverPersistentHeader makePaginationHeader(BuildContext context) {
    return makeDefaultPaginationHeader(
        context,
        paginationInfo!,
        getModelName()
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        // edgeOffset: 120,
        onRefresh: () async {
          doRefresh(context);
        },
        child: Column(
            children: [
              Expanded(
                  child: CustomScrollView(
                      // physics: BouncingScrollPhysics(),
                      slivers: <Widget>[
                        TestNavBar(),
                        getAppBar(context),
                        if (_showPagination())
                          makePaginationHeader(context),
                        getPreSliverListContent(context),
                        getSliverList(context)
                      ]
                  )
              ),
              getBottomSection(context)
            ]
        )
    );
  }
}

abstract class BaseEmptyWidget extends BaseSliverPlainStatelessWidget {
  final String? memberPicture;

  BaseEmptyWidget({
    Key? key,
    required this.memberPicture,
  }) : super(
      key: key,
      memberPicture: memberPicture
  );

  String getEmptyMessage();
  void doRefresh(BuildContext context);

  String getAppBarTitle(BuildContext context) {
    return $trans('app_bar_title_empty');
  }

  Widget getBuildContent(BuildContext context) {
    return RefreshIndicator(
        // edgeOffset: 120,
        onRefresh: () async {
          doRefresh(context);
        },
        child: Column(
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
                                            getContentWidget(context),
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
        )
    );
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Center(
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(getEmptyMessage())
          ],
        )
    );
  }
}

abstract class BaseErrorWidget extends BaseSliverPlainStatelessWidget {
  final String? memberPicture;
  final String? error;

  BaseErrorWidget({
    Key? key,
    required this.error,
    required this.memberPicture,
  }) : super(
      key: key,
      memberPicture: memberPicture
  );

  String getAppBarTitle(BuildContext context) {
    return $trans('app_bar_title_error');
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return errorNotice(error!);
  }
}
