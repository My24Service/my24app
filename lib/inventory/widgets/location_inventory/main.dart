import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24app/inventory/models/form_data.dart';
import 'package:my24app/inventory/blocs/location_inventory_bloc.dart';
import 'package:my24app/inventory/models/models.dart';
import 'mixins.dart';


class LocationInventoryWidget extends BaseSliverPlainStatelessWidget with LocationInventoryMixin, i18nMixin {
  final String basePath = "location_inventory";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LocationsDataFormData? formData;
  final String? memberPicture;

  LocationInventoryWidget({
    Key? key,
    this.formData,
    this.memberPicture,
  }) : super(
      key: key,
      memberPicture: memberPicture
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
          createHeader($trans('header_choose_location')),
          _buildForm(context),
          _buildProductsTable(context)
        ]
    );
  }

  Widget _buildProductsTable(BuildContext context) {
    return buildItemsSection(
        context,
        $trans('header_products'),
        formData!.locationProducts,
        (item) {
          String key = $trans('info_material');
          String? value = item.materialName;
          if (item.materialIdentifier != null && item.materialIdentifier != "") {
            value = "$value (${item.materialIdentifier})";
          }
          return <Widget>[
            ...buildItemListKeyValueList(key, value),
            ...buildItemListKeyValueList($trans('info_amount'), item.totalAmount)
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
        Text($trans('info_location')),
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
