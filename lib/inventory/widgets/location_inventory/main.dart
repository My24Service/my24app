import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/inventory/models/form_data.dart';
import 'package:my24app/inventory/blocs/location_inventory_bloc.dart';
import 'package:my24app/inventory/models/models.dart';
import 'mixins.dart';

class LocationInventoryWidget extends BaseSliverPlainStatelessWidget with LocationInventoryMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LocationsDataFormData? formData;
  final String? memberPicture;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  LocationInventoryWidget({
    Key? key,
    this.formData,
    this.memberPicture,
    required this.widgetsIn,
    required this.i18nIn,
  }) : super(
      key: key,
      mainMemberPicture: memberPicture,
      widgets: widgetsIn,
      i18n: i18nIn
  );

  @override
  Widget getContentWidget(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Container(
            child: SingleChildScrollView(
                child: _showMainView(context)
            ),
          ),
        )
    );
  }

  // private methods
  Widget _showMainView(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          widgetsIn.createHeader(i18nIn.$trans('header_choose_location')),
          _buildForm(context),
          _buildProductsTable(context)
        ]
    );
  }

  Widget _buildProductsTable(BuildContext context) {
    return widgetsIn.buildItemsSection(
        context,
        i18nIn.$trans('header_products'),
        formData!.locationProducts,
        (item) {
          String key = i18nIn.$trans('info_material');
          String? value = item.materialName;
          if (item.materialIdentifier != null && item.materialIdentifier != "") {
            value = "$value (${item.materialIdentifier})";
          }
          return <Widget>[
            ...widgetsIn.buildItemListKeyValueList(key, value),
            ...widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_amount'), item.totalAmount)
          ];
        },
            (item) {
          return <Widget>[];
        }
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(i18nIn.$trans('info_location')),
        DropdownButtonFormField<String>(
          value: formData!.location,
          items: formData!.locations == null || formData!.locations!.results == null ? [] : formData!.locations!.results!.map((
              StockLocation location) {
            return new DropdownMenuItem<String>(
              child: new Text(location.name!),
              value: location.name,
            );
          }).toList(),
          onChanged: (newValue) async {
            StockLocation location = formData!.locations!.results!.firstWhere(
              (loc) => loc.name == newValue,
              orElse: () => formData!.locations!.results!.first
            );

            formData!.location = newValue;
            formData!.locationId = location.id;

            _updateFormData(context);
          },
        ),
      ],
    );
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<LocationInventoryBloc>(context);
    bloc.add(LocationInventoryEvent(status: LocationInventoryEventStatus.DO_ASYNC));
    bloc.add(LocationInventoryEvent(
        status: LocationInventoryEventStatus.UPDATE_FORM_DATA,
        formData: formData
    ));
  }
}
