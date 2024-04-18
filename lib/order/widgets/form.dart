import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:my24_flutter_orders/widgets/form/order.dart';
import 'package:my24app/customer/models/api.dart';

class OrderFormWidget<OrderBloc, OrderFormData> extends BaseOrderFormWidget {
  final CustomerApi customerApi = CustomerApi();

  OrderFormWidget({
    super.key,
    required super.orderPageMetaData,
    required super.formData,
    required super.fetchEvent,
    required super.widgetsIn
  });

  TableRow _getCustomerTypeAhead(BuildContext context) {
    return TableRow(
        children: [
          Padding(padding: const EdgeInsets.only(top: 16),
              child: Text(
                  i18nIn.$trans('form.label_search_customer'),
                  style: const TextStyle(fontWeight: FontWeight.bold)
              )
          ),
          TypeAheadFormField<dynamic>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: formData!.typeAheadControllerBranch,
              decoration: InputDecoration(
                  labelText: i18nIn.$trans('form.typeahead_label_search_customer')
              ),
            ),
            suggestionsCallback: (pattern) async {
              return await customerApi.typeAhead(pattern);
            },
            itemBuilder: (context, dynamic suggestion) {
              return ListTile(
                title: Text(suggestion.value),
              );
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            onSuggestionSelected: (customer) {
              formData!.typeAheadControllerBranch!.text = '';

              // fill fields
              formData!.customerPk = customer.id;
              formData!.orderNameController!.text = customer.name!;
              formData!.orderAddressController!.text = customer.address!;
              formData!.orderPostalController!.text = customer.postal!;
              formData!.orderCityController!.text = customer.city!;
              formData!.orderCountryCode = customer.countryCode;
              formData!.orderTelController!.text = customer.tel!;
              formData!.orderMobileController!.text = customer.mobile!;
              formData!.orderEmailController!.text = customer.email!;
              formData!.orderContactController!.text = customer.contact!;

              updateFormData(context);
            },
            validator: (value) {
              return null;
            },
            onSaved: (value) => {

            },
          )
        ]
    );
  }

  TableRow _getBranchNameTextField() {
    return const TableRow(
        children: [
          SizedBox(height: 1),
          SizedBox(height: 1),
        ]
    );
  }

  @override
  TableRow getFirstElement(BuildContext context) {
    if (isPlanning() && formData!.id == null) {
        return _getCustomerTypeAhead(context);
    }

    return _getBranchNameTextField();
  }
}
