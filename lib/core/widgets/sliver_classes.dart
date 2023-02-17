import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/core/models/models.dart';

abstract class BaseOrdersAppBarFactory {
  BuildContext context;
  List<dynamic> orders;
  OrderListData orderListData;
  int count;

  BaseOrdersAppBarFactory({
    @required this.orderListData,
    @required this.context,
    @required this.orders,
    @required this.count,
  });

  String getBaseTranslateStringForUser() {
    if (orderListData.submodel == 'customer_user') {
      return 'orders.list.app_title_customer_user';
    }
    if (orderListData.submodel == 'planning_user') {
      return 'orders.list.app_title_planning_user';
    }
    if (orderListData.submodel == 'sales_user') {
      return 'orders.list.app_title_sales_user';
    }

    return null;
  }

  List<dynamic> getCustomerNames(List<dynamic> orders) {
    return orders.map((order) => {
      order.orderName
    }).map((e) => e.first).toList().toSet().toList().take(3).toList();
  }

  Widget createTitle() {
    String baseTranslateString = getBaseTranslateStringForUser();
    String title;
    if (orders.length == 0) {
      title = '${baseTranslateString}_no_orders'.tr(
          namedArgs: {
            'numOrders': "$count",
            'firstName': orderListData.firstName
          }
      );
    } else if (orders.length == 1) {
      title = "${baseTranslateString}_one_order".tr(
          namedArgs: {
            'numOrders': "$count",
            'firstName': orderListData.firstName
          }
      );
    } else {
      title = "$baseTranslateString".tr(
          namedArgs: {
            'numOrders': "$count",
            'firstName': orderListData.firstName
          }
      );
    }

    String subtitle = "";
    if (orders.length > 1) {
      List<dynamic> copy = new List<dynamic>.from(orders);
      copy.shuffle();
      List<dynamic> customerNames = getCustomerNames(copy);
      subtitle = "generic.orders_app_bar_subtitle".tr(
          namedArgs: {'customers': "${customerNames.join(', ')}"});
    }

    return ListTile(
        textColor: Colors.white,
        title: Text(title),
        subtitle: Text(subtitle)
    );
  }

  SliverAppBar createAppBar() {
    String memberPicture;
    if (orderListData.memberPicture == null) {
      memberPicture = "https://demo.my24service-dev.com/media/company_pictures/demo/92c01936-0c5f-4bdc-b5ee-4c75f42941cb.png";
    } else {
      memberPicture = orderListData.memberPicture;
    }

    return SliverAppBar(
      pinned: true,
      stretch: true,
      onStretchTrigger: () async {
        print('Load new data!');
        // await Server.requestNewData();
      },
      backgroundColor: Theme.of(context).primaryColor,
      expandedHeight: 200.0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
          StretchMode.blurBackground,
        ],
        title: createTitle(),
        background: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.center,
              colors: <Color>[Theme.of(context).primaryColor, Colors.transparent],
            ),
          ),
          child: Image.network(
            memberPicture,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class AssignedOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  var orderListData;
  var context;
  var orders;
  int count;

  AssignedOrdersAppBarFactory({
    @required this.orderListData,
    @required this.context,
    @required this.orders,
    @required this.count,
  }): super(
      orderListData: orderListData,
      context: context,
      orders: orders,
      count: count
  );

  String getBaseTranslateStringForUser() {
    return 'assigned_orders.list.app_bar_title';
  }

  List<dynamic> getCustomerNames(List<dynamic> orders) {
    return orders.map((assignedOrder) => {
      assignedOrder.order.orderName
    }).map((e) => e.first).toList().toSet().toList().take(3).toList();
  }

}

class OrdersAppBarFactory extends BaseOrdersAppBarFactory {
  var orderListData;
  var context;
  var orders;
  int count;

  OrdersAppBarFactory({
    @required this.orderListData,
    @required this.context,
    @required this.orders,
    @required this.count,
  }): super(
      orderListData: orderListData,
      context: context,
      orders: orders,
      count: count
  );
}

class UnassignedOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  var orderListData;
  var context;
  var orders;
  int count;

  UnassignedOrdersAppBarFactory({
    @required this.orderListData,
    @required this.context,
    @required this.orders,
    @required this.count,
  }): super(
      orderListData: orderListData,
      context: context,
      orders: orders,
      count: count
  );

  String getBaseTranslateStringForUser() {
    return 'orders.unassigned.app_bar_title';
  }
}

class SalesListOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  var orderListData;
  var context;
  var orders;
  int count;

  SalesListOrdersAppBarFactory({
    @required this.orderListData,
    @required this.context,
    @required this.orders,
    @required this.count,
  }): super(
      orderListData: orderListData,
      context: context,
      orders: orders,
      count: count
  );

  String getBaseTranslateStringForUser() {
    return 'orders.sales_list.app_bar_title';
  }
}

class UnacceptedOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  var orderListData;
  var context;
  var orders;
  int count;

  UnacceptedOrdersAppBarFactory({
    @required this.orderListData,
    @required this.context,
    @required this.orders,
    @required this.count,
  }): super(
      orderListData: orderListData,
      context: context,
      orders: orders,
      count: count
  );

  String getBaseTranslateStringForUser() {
    return 'orders.unaccepted.app_bar_title';
  }
}

class PastOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  var orderListData;
  var context;
  var orders;
  int count;

  PastOrdersAppBarFactory({
    @required this.orderListData,
    @required this.context,
    @required this.orders,
    @required this.count,
  }): super(
      orderListData: orderListData,
      context: context,
      orders: orders,
      count: count
  );

  String getBaseTranslateStringForUser() {
    return 'orders.past.app_bar_title';
  }
}

// generic header factory base class
abstract class BaseGenericAppBarFactory {
  BuildContext context;
  String title;
  String subtitle;
  String memberPicture;

  BaseGenericAppBarFactory({
    @required this.context,
    @required this.title,
    @required this.subtitle,
  });

  Widget createTitle() {
    return ListTile(
        textColor: Colors.white,
        title: Text(title),
        subtitle: Text(subtitle)
    );
  }

  SliverAppBar createAppBar() {
    String _memberPicture;
    if (memberPicture == null) {
      _memberPicture = "https://demo.my24service-dev.com/media/company_pictures/demo/92c01936-0c5f-4bdc-b5ee-4c75f42941cb.png";
    } else {
      _memberPicture = memberPicture;
    }

    return SliverAppBar(
      pinned: true,
      stretch: true,
      onStretchTrigger: () async {
        print('Load new data!');
        // await Server.requestNewData();
      },
      backgroundColor: Theme.of(context).primaryColor,
      expandedHeight: 200.0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
          StretchMode.blurBackground,
        ],
        title: createTitle(),
        background: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.center,
              colors: <Color>[Theme.of(context).primaryColor, Colors.transparent],
            ),
          ),
          child: Image.network(
            _memberPicture,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class GenericAppBarFactory extends BaseGenericAppBarFactory {
  BuildContext context;
  String title;
  String subtitle;
  String memberPicture;

  GenericAppBarFactory({
    @required this.context,
    @required this.title,
    @required this.subtitle,
  }) : super(
      context: context,
      title: title,
      subtitle: subtitle
  );
}

abstract class BaseSliverStatelessWidget extends StatelessWidget {
  BaseSliverStatelessWidget({
    Key key,
  }) : super(key: key);

  Widget getContentWidget(BuildContext context);

  SliverAppBar getAppBar(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
        slivers: <Widget>[
          getAppBar(context),
          SliverList(
              delegate: SliverChildListDelegate(
                  [
                    Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: getContentWidget(context)
                        )
                    )
                  ]
              )
          )
        ]
    );
  }
}

abstract class BaseSliverStatefulWidget extends StatefulWidget {
  BaseSliverStatefulWidget({Key key}) : super(key: key);
}

abstract class BaseSliverWidgetState<T extends BaseSliverStatefulWidget> extends State<T> {
  Widget getContentWidget(BuildContext context);

  SliverAppBar getAppBar(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
        slivers: <Widget>[
          getAppBar(context),
          SliverList(
              delegate: SliverChildListDelegate(
                  [
                    Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: getContentWidget(context)
                        )
                    )
                  ]
              )
          )
        ]
    );
  }
}
