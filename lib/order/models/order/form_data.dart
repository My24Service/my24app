import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/inventory/models/models.dart';
import 'models.dart';

class OrderFormData extends BaseFormData<Order> {
  TextEditingController typeAheadController = TextEditingController();
  InventoryMaterialTypeAheadModel selectedProduct;
  String selectedProductName;

  TextEditingController typeAheadControllerCustomer = TextEditingController();
  CustomerTypeAheadModel selectedCustomer;
  String selectedCustomerName;

  int id;
  int customerPk;
  String customerId;

  TextEditingController orderCustomerIdController = TextEditingController();
  TextEditingController orderNameController = TextEditingController();
  TextEditingController orderAddressController = TextEditingController();
  TextEditingController orderPostalController = TextEditingController();
  TextEditingController orderCityController = TextEditingController();
  TextEditingController orderContactController = TextEditingController();
  TextEditingController orderReferenceController = TextEditingController();
  TextEditingController customerRemarksController = TextEditingController();
  TextEditingController orderEmailController = TextEditingController();
  TextEditingController orderMobileController = TextEditingController();
  TextEditingController orderTelController = TextEditingController();

  TextEditingController orderlineLocationController = TextEditingController();
  TextEditingController orderlineProductController = TextEditingController();
  TextEditingController orderlineRemarksController = TextEditingController();

  TextEditingController infolineInfoController = TextEditingController();

  List<Orderline> orderLines = [];
  List<Infoline> infoLines = [];

  DateTime startDate = DateTime.now();
  DateTime startTime; // = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime endTime; // = DateTime.now();

  OrderTypes orderTypes;
  String orderType;
  String orderCountryCode = 'NL';
  bool customerOrderAccepted = false;

  String _formatTime(DateTime time) {
    String timePart = '$time'.split(' ')[1];
    List<String> hoursMinutes = timePart.split(':');

    return '${hoursMinutes[0]}:${hoursMinutes[1]}';
  }

  bool isValid() {
    if (orderType == null) {
      return false;
    }

    return true;
  }

  @override
  Order toModel() {
    Order order = Order(
        id: id,
        customerId: orderCustomerIdController.text,
        customerRelation: customerPk,
        orderReference: orderReferenceController.text,
        orderType: orderType,
        customerRemarks: customerRemarksController.text,
        startDate: utils.formatDate(startDate),
        startTime: startTime != null ? _formatTime(startTime.toLocal()) : null,
        endDate: utils.formatDate(endDate),
        endTime: endTime != null ? _formatTime(endTime.toLocal()) : null,
        orderName: orderNameController.text,
        orderAddress: orderAddressController.text,
        orderPostal: orderPostalController.text,
        orderCity: orderCityController.text,
        orderCountryCode: orderCountryCode,
        orderTel: orderTelController.text,
        orderMobile: orderMobileController.text,
        orderEmail: orderEmailController.text,
        orderContact: orderContactController.text,
        orderLines: orderLines,
        infoLines: infoLines,
        customerOrderAccepted: customerOrderAccepted
    );

    return order;
  }

  factory OrderFormData.createEmpty() {
    final TextEditingController orderCustomerIdController = TextEditingController();
    final TextEditingController orderNameController = TextEditingController();
    final TextEditingController orderAddressController = TextEditingController();
    final TextEditingController orderPostalController = TextEditingController();
    final TextEditingController orderCityController = TextEditingController();
    final TextEditingController orderContactController = TextEditingController();
    final TextEditingController orderEmailController = TextEditingController();
    final TextEditingController orderTelController = TextEditingController();
    final TextEditingController orderMobileController = TextEditingController();
    final TextEditingController orderReferenceController = TextEditingController();
    final TextEditingController customerRemarksController = TextEditingController();

    return OrderFormData(
      id: null,
      customerPk: null,
      customerId: null,
      orderCustomerIdController: orderCustomerIdController,
      orderNameController: orderNameController,
      orderAddressController: orderAddressController,
      orderPostalController: orderPostalController,
      orderCityController: orderCityController,
      orderCountryCode: 'NL',
      orderContactController: orderContactController,
      orderEmailController: orderEmailController,
      orderTelController: orderTelController,
      orderMobileController: orderMobileController,
      orderReferenceController: orderReferenceController,
      customerRemarksController: customerRemarksController,
      orderType: null,
      startDate: DateTime.now(),
      startTime: null,
      // // "end_date": "26/10/2020",
      endDate: DateTime.now(),
      endTime: null,
      customerOrderAccepted: false,
      orderLines: [],
      infoLines: [],
    );
  }

  factory OrderFormData.createFromModel(Order order) {
    final TextEditingController orderCustomerIdController = TextEditingController();
    orderCustomerIdController.text = order.customerId;

    final TextEditingController orderNameController = TextEditingController();
    orderNameController.text = order.orderName;

    final TextEditingController orderAddressController = TextEditingController();
    orderAddressController.text = order.orderAddress;

    final TextEditingController orderPostalController = TextEditingController();
    orderPostalController.text = order.orderPostal;

    final TextEditingController orderCityController = TextEditingController();
    orderCityController.text = order.orderCity;

    final TextEditingController orderContactController = TextEditingController();
    orderContactController.text = order.orderContact;

    final TextEditingController orderEmailController = TextEditingController();
    orderEmailController.text = order.orderEmail;

    final TextEditingController orderTelController = TextEditingController();
    orderTelController.text = order.orderTel;

    final TextEditingController orderMobileController = TextEditingController();
    orderMobileController.text = order.orderMobile;

    final TextEditingController orderReferenceController = TextEditingController();
    orderReferenceController.text = order.orderReference;

    final TextEditingController customerRemarksController = TextEditingController();
    customerRemarksController.text = order.customerRemarks;

    DateTime startTime;
    if (order.startTime != null) {
      startTime = DateFormat('d/M/yyyy H:m:s').parse(
          '${order.startDate} ${order.startTime}');
    }

    DateTime endTime;
    if (order.endTime != null) {
      endTime = DateFormat('d/M/yyyy H:m:s').parse(
          '${order.endDate} ${order.endTime}');
    }

    return OrderFormData(
      id: order.id,
      customerId: order.customerId,
      orderCustomerIdController: orderCustomerIdController,
      orderNameController: orderNameController,
      orderAddressController: orderAddressController,
      orderPostalController: orderPostalController,
      orderCityController: orderCityController,
      orderCountryCode: order.orderCountryCode,
      orderContactController: orderContactController,
      orderEmailController: orderEmailController,
      orderTelController: orderTelController,
      orderMobileController: orderMobileController,
      orderReferenceController: orderReferenceController,
      customerRemarksController: customerRemarksController,
      orderType: order.orderType,
      // // "start_date": "26/10/2020"
      startDate: DateFormat('d/M/yyyy').parse(order.startDate),
      startTime: startTime,
      // // "end_date": "26/10/2020",
      endDate: DateFormat('d/M/yyyy').parse(order.endDate),
      endTime: endTime,
      customerOrderAccepted: order.customerOrderAccepted,
      orderLines: order.orderLines,
      infoLines: order.infoLines,
    );
  }

  OrderFormData({
      this.id,
      this.typeAheadController,
      this.selectedProduct,
      this.selectedProductName,
      this.typeAheadControllerCustomer,
      this.selectedCustomer,
      this.selectedCustomerName,
      this.customerPk,
      this.customerId,
      this.orderlineLocationController,
      this.orderlineProductController,
      this.orderlineRemarksController,
      this.infolineInfoController,
      this.orderCustomerIdController,
      this.orderNameController,
      this.orderAddressController,
      this.orderPostalController,
      this.orderCityController,
      this.orderContactController,
      this.orderReferenceController,
      this.customerRemarksController,
      this.orderEmailController,
      this.orderMobileController,
      this.orderTelController,
      this.orderLines,
      this.infoLines,
      this.startDate,
      this.startTime,
      this.endDate,
      this.endTime,
      this.orderTypes,
      this.orderType,
      this.orderCountryCode,
      this.customerOrderAccepted
  });
}