import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24_flutter_orders/models/infoline/form_data.dart';
import 'package:my24_flutter_orders/models/order/form_data.dart';
import 'package:my24_flutter_orders/models/order/models.dart';

import '../../customer/models/models.dart';

class OrderFormData extends BaseOrderFormData {
  OrderFormData({
    super.id,
    super.typeAheadControllerCustomer,
    super.typeAheadControllerBranch,
    super.customerPk,
    super.customerId,
    super.branch,
    super.orderCustomerIdController,
    super.orderNameController,
    super.orderAddressController,
    super.orderPostalController,
    super.orderCityController,
    super.orderContactController,
    super.orderReferenceController,
    super.customerRemarksController,
    super.orderEmailController,
    super.orderMobileController,
    super.orderTelController,

    super.orderLines,
    super.deletedOrderLines,
    super.infoLines,
    super.deletedInfoLines,
    super.documents,
    super.deletedDocuments,

    super.startDate,
    super.startTime,
    super.endDate,
    super.endTime,
    super.changedEndDate,
    super.orderTypes,
    super.orderType,
    super.orderCountryCode,
    super.customerOrderAccepted,
    super.error,
    super.quickCreateSettings,
    super.customerBranchId,
    super.equipmentLocationUpdates,

    super.infolineFormData
  });

  factory OrderFormData.newFromOrderTypes(OrderTypes orderTypes) {
    TextEditingController typeAheadControllerCustomer = TextEditingController();
    TextEditingController typeAheadControllerBranch = TextEditingController();

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
      customerBranchId: null,
      typeAheadControllerCustomer: typeAheadControllerCustomer,
      typeAheadControllerBranch: typeAheadControllerBranch,
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
      orderTypes: orderTypes,
      startDate: DateTime.now(),
      startTime: null,
      // // "end_date": "26/10/2020",
      endDate: DateTime.now(),
      endTime: null,
      changedEndDate: false,
      customerOrderAccepted: false,

      orderLines: [],
      infoLines: [],
      deletedOrderLines: [],
      deletedInfoLines: [],
      documents: [],
      deletedDocuments: [],

      quickCreateSettings: null,
      equipmentLocationUpdates: [],

      infolineFormData: InfolineFormData.createEmpty(null)
    );
  }

  void fillFromCustomer(Customer customer) {
    this.customerId = customer.customerId;
    this.customerPk = customer.id;
    this.customerBranchId = customer.branchId;

    this.orderCustomerIdController!.text = customer.customerId!;
    this.orderNameController!.text = customer.name!;
    this.orderAddressController!.text = customer.address!;
    this.orderPostalController!.text = customer.postal!;
    this.orderCityController!.text = customer.city!;
    this.orderCountryCode = customer.countryCode;
    this.orderContactController!.text = customer.contact!;
    this.orderEmailController!.text = customer.email!;
    this.orderTelController!.text = customer.tel!;
    this.orderMobileController!.text = customer.mobile!;
  }

  factory OrderFormData.createFromModel(Order order, OrderTypes orderTypes) {
    final TextEditingController typeAheadControllerCustomer = TextEditingController();
    final TextEditingController typeAheadControllerBranch = TextEditingController();

    final TextEditingController orderCustomerIdController = TextEditingController();
    orderCustomerIdController.text = checkNull(order.customerId);

    final TextEditingController orderNameController = TextEditingController();
    orderNameController.text = checkNull(order.orderName);

    final TextEditingController orderAddressController = TextEditingController();
    orderAddressController.text = checkNull(order.orderAddress);

    final TextEditingController orderPostalController = TextEditingController();
    orderPostalController.text = checkNull(order.orderPostal);

    final TextEditingController orderCityController = TextEditingController();
    orderCityController.text = checkNull(order.orderCity);

    final TextEditingController orderContactController = TextEditingController();
    orderContactController.text = checkNull(order.orderContact);

    final TextEditingController orderEmailController = TextEditingController();
    orderEmailController.text = checkNull(order.orderEmail);

    final TextEditingController orderTelController = TextEditingController();
    orderTelController.text = checkNull(order.orderTel);

    final TextEditingController orderMobileController = TextEditingController();
    orderMobileController.text = checkNull(order.orderMobile);

    final TextEditingController orderReferenceController = TextEditingController();
    orderReferenceController.text = checkNull(order.orderReference);

    final TextEditingController customerRemarksController = TextEditingController();
    customerRemarksController.text = checkNull(order.customerRemarks);

    DateTime? startTime;
    if (order.startTime != null && order.startTime != '') {
      startTime = DateFormat('d/M/yyyy H:m').parse(
          '${order.startDate} ${order.startTime}');

    }

    DateTime? endTime;
    if (order.endTime != null && order.endTime != '') {
      endTime = DateFormat('d/M/yyyy H:m').parse(
          '${order.endDate} ${order.endTime}');
    }

    return OrderFormData(
      id: order.id,
      customerId: order.customerId,
      branch: order.branch,
      typeAheadControllerCustomer: typeAheadControllerCustomer,
      typeAheadControllerBranch: typeAheadControllerBranch,
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
      orderTypes: orderTypes,
      // // "start_date": "26/10/2020"
      startDate: DateFormat('d/M/yyyy').parse(order.startDate!),
      startTime: startTime,
      // // "end_date": "26/10/2020",
      endDate: DateFormat('d/M/yyyy').parse(order.endDate!),
      endTime: endTime,
      customerOrderAccepted: order.customerOrderAccepted,

      orderLines: order.orderLines,
      infoLines: order.infoLines,
      documents: order.documents,
      deletedOrderLines: [],
      deletedInfoLines: [],
      deletedDocuments: [],

      quickCreateSettings: null,
      equipmentLocationUpdates: [],
      infolineFormData: InfolineFormData.createEmpty(null)
    );
  }
}