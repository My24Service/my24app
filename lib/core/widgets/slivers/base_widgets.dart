import 'package:flutter/material.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/models/models.dart';


abstract class BaseSliverPlainStatelessWidget extends StatelessWidget {
  // base class for forms, errors, non-lists
  BaseSliverPlainStatelessWidget({
    Key key,
  }) : super(key: key);

  SliverAppBar getAppBar(BuildContext context);
  Widget getContentWidget(BuildContext context);
  Widget getBottomSection(BuildContext context);

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

  SliverAppBar getAppBar(BuildContext context);
  Widget getBottomSection(BuildContext context);
  SliverList getSliverList(BuildContext context);

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
