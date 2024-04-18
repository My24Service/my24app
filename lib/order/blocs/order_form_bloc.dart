import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_equipment/models/equipment/models.dart';
import 'package:my24_flutter_orders/blocs/order_form_bloc.dart';
import 'package:my24_flutter_orders/blocs/order_form_states.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/models/orderline/models.dart';

import '../../customer/models/api.dart';
import '../../customer/models/models.dart';
import '../models/form_data.dart';

class OrderFormBloc extends OrderFormBlocBase {
  final CoreUtils coreUtils = CoreUtils();
  CustomerApi customerApi = CustomerApi();

  OrderFormBloc() : super(OrderFormInitialState()) {
    on<OrderFormEvent>((event, emit) async {
      if (event.status == OrderFormEventStatus.newOrder) {
        await _handleNewFormDataState(event, emit);
      }
      else if (event.status == OrderFormEventStatus.newOrderFromEquipmentBranch) {
        await _handleNewFormDataFromEquipmentState(event, emit);
      }
      else {
        await handleEvent(event, emit);
      }
    },
    transformer: sequential());
  }

  @override
  OrderFormData createFromModel(Order order, OrderTypes orderTypes) {
    return OrderFormData.createFromModel(order, orderTypes);
  }

  Future<void> _handleNewFormDataState(OrderFormEvent event, Emitter<OrderFormState> emit) async {
    final OrderTypes orderTypes = await api.fetchOrderTypes();
    String? submodel = await coreUtils.getUserSubmodel();
    OrderFormData orderFormData = OrderFormData.newFromOrderTypes(orderTypes);
    orderFormData = await addQuickCreateSettings(orderFormData) as OrderFormData;

    if (submodel == 'customer_user') {
      final Customer customer = await customerApi.fetchCustomerFromPrefs();
      orderFormData.fillFromCustomer(customer);
    }

    emit(OrderNewState(
        formData: orderFormData
    ));
  }

  Future<void> _handleNewFormDataFromEquipmentState(OrderFormEvent event, Emitter<OrderFormState> emit) async {
    try {
      final OrderTypes orderTypes = await api.fetchOrderTypes();
      final Equipment equipment = await equipmentApi.getByUuid(event.equipmentUuid!);
      final Customer customer = await customerApi.detail(equipment.customer!);

      OrderFormData orderFormData = OrderFormData.newFromOrderTypes(orderTypes);
      orderFormData = await addQuickCreateSettings(orderFormData) as OrderFormData;
      orderFormData.orderType = event.equipmentOrderType!;
      orderFormData.fillFromCustomer(customer);

      Orderline orderline = Orderline(
        product: equipment.name,
        location: equipment.locationName,
        equipment: equipment.id,
        equipmentLocation: equipment.location,
      );

      orderFormData.orderLines!.add(orderline);

      emit(OrderNewState(
          formData: orderFormData
      ));
    } catch (e) {
      emit(OrderFormErrorState(message: e.toString()));
    }
  }
}
