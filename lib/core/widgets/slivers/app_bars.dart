import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/models/order/models.dart';
import 'dart:io' show Platform;

EdgeInsets contentPadding = Platform.isIOS ?
  EdgeInsets.only(left: 60, top: 56) :
  EdgeInsets.only(top: 0);
//  EdgeInsets.only(top: 32);

// generic header factory base class
abstract class BaseGenericAppBarFactory {
  BuildContext context;
  String title;
  String subtitle;
  String memberPicture;
  Function onStretch;

  BaseGenericAppBarFactory({
    @required this.context,
    @required this.title,
    @required this.subtitle,
    @required this.memberPicture,
    this.onStretch
  });

  Widget createTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(title, style: TextStyle(color: Colors.white, )),
        Text(subtitle, style: TextStyle(color: Colors.white, fontSize: 12.0)),
      ],
    );
    return ListTile(
        contentPadding: contentPadding,
        textColor: Colors.white,
        title: Text(title),
        subtitle: Text(subtitle)
    );
  }

  SliverAppBar createAppBar() {
    String _memberPicture;
    if (memberPicture == null) {
      print("memberPicture not set, using default one");
      _memberPicture = "https://demo.my24service-dev.com/media/company_pictures/demo/92c01936-0c5f-4bdc-b5ee-4c75f42941cb.png";
    } else {
      _memberPicture = memberPicture;
    }

    final Map<String, String> envVars = Platform.environment;

    Widget image = envVars['TESTING'] != null ? Image.network(_memberPicture) : CachedNetworkImage(
        placeholder: (context, url) => const CircularProgressIndicator(),
        imageUrl: _memberPicture,
        fit: BoxFit.cover,
      );

    return SliverAppBar(
      pinned: true,
      stretch: true,
      stretchTriggerOffset: 80.0,
      onStretchTrigger: () async {
        if (onStretch != null) {
          await onStretch(context);
        }
      },
      backgroundColor: Theme.of(context).primaryColor,
      expandedHeight: 180.0,
      collapsedHeight: 70,
      flexibleSpace: FlexibleSpaceBar(
        title: createTitle(),
        centerTitle: false,
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
          StretchMode.blurBackground,
        ],
        background: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.center,
              colors: <Color>[Theme.of(context).primaryColor, Colors.transparent],
            ),
          ),
          child: image,
        ),
      ),
    );
  }
}

// order appbars have some more logic in them
abstract class BaseOrdersAppBarFactory extends BaseGenericAppBarFactory {
  BuildContext context;
  List<dynamic> orders;
  OrderPageMetaData orderPageMetaData;
  int count;
  Function onStretch;

  BaseOrdersAppBarFactory({
    @required this.orderPageMetaData,
    @required this.context,
    @required this.orders,
    @required this.count,
    this.onStretch
  }): super(
      memberPicture: orderPageMetaData.memberPicture,
      context: context,
      subtitle: '',
      title: ''
  );

  String getBaseTranslateStringForUser() {
    if (orderPageMetaData.submodel == 'customer_user') {
      return 'orders.list.app_title_customer_user';
    }
    if (orderPageMetaData.submodel == 'planning_user') {
      return 'orders.list.app_title_planning_user';
    }
    if (orderPageMetaData.submodel == 'sales_user') {
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
      title = getTranslationTr('${baseTranslateString}_no_orders', {
            'numOrders': "$count",
            'firstName': orderPageMetaData.firstName
          }
      );
    } else if (orders.length == 1) {
      title = getTranslationTr("${baseTranslateString}_one_order", {
            'numOrders': "$count",
            'firstName': orderPageMetaData.firstName
          }
      );
    } else {
      title = getTranslationTr("$baseTranslateString", {
            'numOrders': "$count",
            'firstName': orderPageMetaData.firstName
          }
      );
    }

    String subtitle = "";
    if (orders.length > 1) {
      List<dynamic> copy = new List<dynamic>.from(orders);
      copy.shuffle();
      List<dynamic> customerNames = getCustomerNames(copy);
      subtitle = getTranslationTr("generic.orders_app_bar_subtitle",
          {'customers': "${customerNames.join(', ')}"});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(title, style: TextStyle(color: Colors.white, )),
        Text(subtitle, style: TextStyle(color: Colors.white, fontSize: 12.0)),
      ],
    );

    return ListTile(
        contentPadding: contentPadding,
        textColor: Colors.white,
        title: Text(title),
        subtitle: Text(subtitle)
    );
  }
}

class AssignedOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  var orderPageMetaData;
  var context;
  var orders;
  int count;
  Function onStretch;

  AssignedOrdersAppBarFactory({
    @required this.orderPageMetaData,
    @required this.context,
    @required this.orders,
    @required this.count,
    this.onStretch
  }): super(
      orderPageMetaData: orderPageMetaData,
      context: context,
      orders: orders,
      count: count,
      onStretch: onStretch
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
  var orderPageMetaData;
  var context;
  var orders;
  int count;
  Function onStretch;

  OrdersAppBarFactory({
    @required this.orderPageMetaData,
    @required this.context,
    @required this.orders,
    @required this.count,
    @required this.onStretch
  }): super(
      orderPageMetaData: orderPageMetaData,
      context: context,
      orders: orders,
      count: count,
      onStretch: onStretch
  );
}

class UnassignedOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  var orderPageMetaData;
  var context;
  var orders;
  int count;
  Function onStretch;

  UnassignedOrdersAppBarFactory({
    @required this.orderPageMetaData,
    @required this.context,
    @required this.orders,
    @required this.count,
    @required this.onStretch
  }): super(
      orderPageMetaData: orderPageMetaData,
      context: context,
      orders: orders,
      count: count,
      onStretch: onStretch
  );

  String getBaseTranslateStringForUser() {
    return 'orders.unassigned.app_bar_title';
  }
}

class SalesListOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  var orderPageMetaData;
  var context;
  var orders;
  int count;
  Function onStretch;

  SalesListOrdersAppBarFactory({
    @required this.orderPageMetaData,
    @required this.context,
    @required this.orders,
    @required this.count,
    @required this.onStretch
  }): super(
      orderPageMetaData: orderPageMetaData,
      context: context,
      orders: orders,
      count: count,
      onStretch: onStretch
  );

  String getBaseTranslateStringForUser() {
    return 'orders.sales_list.app_bar_title';
  }
}

class UnacceptedOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  var orderPageMetaData;
  var context;
  var orders;
  int count;
  Function onStretch;

  UnacceptedOrdersAppBarFactory({
    @required this.orderPageMetaData,
    @required this.context,
    @required this.orders,
    @required this.count,
    @required this.onStretch
  }): super(
      orderPageMetaData: orderPageMetaData,
      context: context,
      orders: orders,
      count: count,
      onStretch: onStretch
  );

  String getBaseTranslateStringForUser() {
    return 'orders.unaccepted.app_bar_title';
  }
}

class PastOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  var orderPageMetaData;
  var context;
  var orders;
  int count;
  Function onStretch;

  PastOrdersAppBarFactory({
    @required this.orderPageMetaData,
    @required this.context,
    @required this.orders,
    @required this.count,
    @required this.onStretch
  }): super(
      orderPageMetaData: orderPageMetaData,
      context: context,
      orders: orders,
      count: count,
      onStretch: onStretch
  );

  String getBaseTranslateStringForUser() {
    return 'orders.past.app_bar_title';
  }
}

class GenericAppBarFactory extends BaseGenericAppBarFactory {
  BuildContext context;
  String title;
  String subtitle;
  String memberPicture;
  Function onStretch;

  GenericAppBarFactory({
    @required this.context,
    @required this.title,
    @required this.subtitle,
    @required this.memberPicture,
    this.onStretch
  }) : super(
      context: context,
      title: title,
      subtitle: subtitle,
      onStretch: onStretch,
      memberPicture: memberPicture
  );
}
