import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:my24app/core/utils.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/inventory/api/inventory_api.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/inventory/models/models.dart';
import 'package:my24app/order/models/order/api.dart';
import 'package:my24app/customer/api/customer_api.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/order/pages/sales_list.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class SalesOrderFormWidget extends StatefulWidget {
  final Order order;
  final bool isPlanning;

  SalesOrderFormWidget({
    Key key,
    @required this.order,
    @required this.isPlanning,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _SalesOrderFormWidgetState();
}

class _SalesOrderFormWidgetState extends State<SalesOrderFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  StockLocations _locations;
  StockLocation _fromLocation;
  String _currentLocationName;

  final TextEditingController _typeAheadControllerCustomer =
      TextEditingController();
  CustomerTypeAheadModel _selectedCustomer;
  String _selectedCustomerName;
  BuildContext _context;

  final TextEditingController _typeAheadControllerMaterial =
      TextEditingController();

  LocationMaterialInventory _selectedMaterial;

  var _salesOrderAmountController = TextEditingController();

  List<LocationMaterialMutation> _orderMaterialMutations = [];

  bool _inAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    _context = context;

    return ModalProgressHUD(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: _buildMainContainer()
          ),
        ), inAsyncCall: _inAsyncCall
    );
  }

  @override
  void initState() {
    super.initState();
    _salesOrderAmountController.text = '1';
    _doAsync();
  }

  _doAsync() async {
    setState(() {
      _inAsyncCall = true;
    });

    _onceGetLocations();

    setState(() {
      _inAsyncCall = false;
    });
  }

  _onceGetLocations() async {
    _locations = await inventoryApi.fetchLocations();
    _fromLocation = _locations.results[0];
    _currentLocationName = _fromLocation.name;
    setState(() {});
  }

  Widget _buildMainContainer() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              _createSalesOrderForm(context),
              Divider(),
              SizedBox(
                height: 20,
              ),
              _createSubmitButton(),
              Divider(),
              SizedBox(height: 20),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  child: Text('orders.sales_form.button_to_sales_list'.tr()),
                  onPressed: () => _navSalesOrderList(context)
              ),
            ],
          )
      ));
  }

  _navSalesOrderList(BuildContext context) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => SalesPage()));
  }

  Widget _createSalesOrderForm(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            createHeader('orders.sales_form.header_select_customer_location'.tr()),
            _getCustomerTypeAhead(),
            _getFromLocationSelect(),
            Divider(),
            createHeader('orders.sales_form.header_select_material_amount'.tr()),
            _getMaterialTypeAhead(),
            Divider(),
            _showEntryPart(),
            _showOrderMutationsPart()
          ],
        )
    );
  }

  Widget _showOrderMutationsPart() {
    print(_orderMaterialMutations.length);
    if (_orderMaterialMutations.length == 0) {
      return SizedBox();
    }
    print('returning content');
    return Column(
      children: [
        createHeader('orders.sales_form.header_entered_materials'.tr()),
        _buildOrderMutationsTable(),
        Divider(),
        _buildTotalsRow()
      ],
    );
  }

  Widget _showEntryPart() {
    // show material, supplier, sold today, and an input for amount
    if (_selectedMaterial == null) {
      return SizedBox();
    }

    List<TableRow> rows = [];
    Map<int, TableColumnWidth> columnWidths = {
      0: FlexColumnWidth(1.5),
      1: FlexColumnWidth(4),
    };

    double priceSellingAlt = _selectedMaterial.priceSellingAlt != null ? _selectedMaterial.priceSellingAlt : 0.00;
    int soldToday = _selectedMaterial.numSoldToday != null ? _selectedMaterial.numSoldToday : 0;

    rows.add(TableRow(children: [
      _createHeaderCell('orders.sales_form.label_entry_material'.tr()),
      _createCell('${_selectedMaterial.materialName}')
    ]));

    rows.add(TableRow(children: [
      _createHeaderCell('orders.sales_form.label_entry_supplier'.tr()),
      _createCell('${_selectedMaterial.supplierName}')
    ]));

    rows.add(TableRow(children: [
      _createHeaderCell('orders.sales_form.label_entry_sold_today'.tr()),
      _createCell('$soldToday')
    ]));

    rows.add(TableRow(children: [
      _createHeaderCell('orders.sales_form.label_entry_alt_selling_text'.tr()),
      _createCell('$priceSellingAlt')
    ]));

    rows.add(TableRow(children: [
      _createHeaderCell('orders.sales_form.label_entry_amount'.tr()),
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.top,
            child: Container(
              height: 24,
              // width: 320,
              color: Colors.white,
              child: TextFormField(
                controller: _salesOrderAmountController,
                keyboardType: TextInputType.numberWithOptions(),
              ),
            )
        )
      ]));

    return Container(
        color: Colors.grey,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            createTableWidths(rows, columnWidths),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue, // background
                        onPrimary: Colors.white, // foreground
                    ),
                    child: Text(' + '),
                    onPressed: () => _increaseAmount()
                ),
                SizedBox(width: 16),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // background
                      onPrimary: Colors.white, // foreground
                    ),
                    child: Text(' - '),
                    onPressed: () => _decreaseAmount()
                )
              ],
            ),
            Divider(),
            createElevatedButtonColored(
                'orders.sales_form.button_entry_add_material'.tr(),
                () => _addSalesOrderProduct(),
                foregroundColor: Colors.white,
                backgroundColor: Colors.black)
          ],
        )
    );
  }

  _increaseAmount() {
    FocusScope.of(context).unfocus();
    int amount = int.parse(_salesOrderAmountController.text);
    amount += 1;
    _salesOrderAmountController.text = '$amount';
  }

  _decreaseAmount() {
    FocusScope.of(context).unfocus();
    if (_salesOrderAmountController.text == '0') {
      return;
    }

    int amount = int.parse(_salesOrderAmountController.text);
    amount -= 1;
    _salesOrderAmountController.text = '$amount';
  }

  _addSalesOrderProduct() {
    LocationMaterialMutation mutation = LocationMaterialMutation(
        amount: int.parse(_salesOrderAmountController.text),
        materialId: _selectedMaterial.materialId,
        materialName: _selectedMaterial.materialName,
        locationName: _fromLocation.name,
        customerName: _selectedCustomer.name,
        locationId: _fromLocation.id,
        pricePurchase: _selectedMaterial.pricePurchase,
        priceSellingAlt: _selectedMaterial.priceSellingAlt,
        priceSelling: _selectedMaterial.priceSelling,
    );

    _orderMaterialMutations.add(
      mutation
    );

    _showOrderMutationsPart();

    _salesOrderAmountController.text = '1';

    FocusScope.of(context).unfocus();
    setState(() {});
  }

  TableCell _createHeaderCell(String content) {
    return TableCell(
        verticalAlignment: TableCellVerticalAlignment.top,
        child: createTableHeaderCell(content, 4.0)
    );
  }

  TableCell _createCell(String content) {
    return TableCell(
        verticalAlignment: TableCellVerticalAlignment.top,
        child: createTableColumnCell(content)
    );
  }

  Widget _getCustomerTypeAhead() {
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('orders.sales_form.label_search_customer'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold))),
      TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: this._typeAheadControllerCustomer,
        ),
        suggestionsCallback: (pattern) async {
          if (pattern.length < 3) return null;
          return await customerApi.customerTypeAhead(pattern);
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion.value),
          );
        },
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        onSuggestionSelected: (suggestion) {
          _selectedCustomer = suggestion;
          this._typeAheadControllerCustomer.text = _selectedCustomer.name;

          // rebuild widgets
          setState(() {});
        },
        validator: (value) {
          return null;
        },
        onSaved: (value) => this._selectedCustomerName = value,
      )
    ]);
  }

  Column _getFromLocationSelect() {
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('orders.sales_form.label_location'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold))),
      DropdownButtonFormField<String>(
        value: _currentLocationName,
        items: _locations == null || _locations.results == null
            ? []
            : _locations.results.map((StockLocation location) {
                return new DropdownMenuItem<String>(
                  child: new Text(location.name),
                  value: location.name,
                );
              }).toList(),
        onChanged: (newValue) {
          setState(() {
            _currentLocationName = newValue;

            StockLocation location = _locations.results.firstWhere(
                (loc) => loc.name == newValue,
                orElse: () => _locations.results.first);

            _fromLocation = location;
          });
        },
      ),
    ]);
  }

  Column _getMaterialTypeAhead() {
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('orders.sales_form.label_search_material'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold))),
      TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
            controller: this._typeAheadControllerMaterial,
            decoration: InputDecoration(
                labelText:
                'orders.sales_form.typeahead_label_search_material'.tr())),
        suggestionsCallback: (pattern) async {
          if (pattern.length < 1) return null;
          return await inventoryApi.searchLocationProducts(_fromLocation.id, pattern);
        },
        itemBuilder: (context, suggestion) {
          final String inStockText = 'orders.sales_form.in_stock'.tr();
          return ListTile(
            title: Text('${suggestion.materialName} ($inStockText: ${suggestion.totalAmount})'),
          );
        },
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        onSuggestionSelected: (suggestion) {
          _selectedMaterial = suggestion;
          this._typeAheadControllerMaterial.text = '';

          // rebuild widgets
          setState(() {});
        },
        validator: (value) {
          return null;
        },
      )
    ]);
  }

  Widget _buildOrderMutationsTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [createTableHeaderCell('orders.sales_form.label_summary'.tr())]),
        Column(children: [createTableHeaderCell('generic.action_delete'.tr())])
      ],
    ));

    // material mutations
    for (int i = 0; i < _orderMaterialMutations.length; ++i) {
      LocationMaterialMutation materialMutation = _orderMaterialMutations[i];

      rows.add(TableRow(children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              createTableColumnCell('${materialMutation.materialName}'),
              createTableColumnCell('${materialMutation.amount} x ${materialMutation.priceSellingAlt}'),
            ]
        ),
        Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showDeleteDialogMaterialMutation(i);
                },
              )
            ]
        ),
      ]));
    }

    Map<int, TableColumnWidth> columnWidths = {
      0: FlexColumnWidth(4),
      1: FlexColumnWidth(1.5),
    };

    return createTableWidths(rows, columnWidths);
  }

  Widget _buildTotalsRow() {
    double total = 0;

    // material mutations
    for (int i = 0; i < _orderMaterialMutations.length; ++i) {
      total += _orderMaterialMutations[i].priceSellingAlt != null ? _orderMaterialMutations[i].priceSellingAlt * _orderMaterialMutations[i].amount : 0;
    }

    return Row(
      children: [
        createTableHeaderCell('orders.sales_form.label_entry_total'.tr()),
        Spacer(),
        createTableHeaderCell('$total')
      ],
    );
  }

  _deleteMaterialMutation(int index) {
    _orderMaterialMutations.removeAt(index);

    setState(() {});
  }

  _showDeleteDialogMaterialMutation(int index) {
    showDeleteDialogWrapper(
        'orders.sales_form.delete_dialog_title_material_mutation'.tr(),
        'orders.sales_form.delete_dialog_content_material_mutation'.tr(),
        () => _deleteMaterialMutation(index),
        _context
    );
  }

  Widget _createSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.blue, // background
        onPrimary: Colors.white, // foreground
      ),
      child: Text('orders.sales_form.button_order_insert'.tr()),
      onPressed: () async {
        if (_orderMaterialMutations.length == 0) {
          return;
        }

        if (this._formKey.currentState.validate()) {
          // check inventory before submit
          for (int i = 0; i < _orderMaterialMutations.length; ++i) {
            LocationMaterialMutation materialMutation = _orderMaterialMutations[i];
            print('mutation materialId: ${materialMutation.materialId}');
            try {
              int inventory = await inventoryApi
                  .getInventoryForMaterialLocation(
                  materialMutation.materialId, materialMutation.locationId);

              if (inventory < materialMutation.amount) {
                displayDialog(context,
                  'orders.sales_form.dialog_title_not_in_stock'.tr(),
                  "${'orders.sales_form.dialog_content_not_enough_in_stock_for'.tr()}: ${materialMutation.materialName}, ${materialMutation.locationName} ($inventory)",
                );

                return;
              }
            } catch(e) {
              displayDialog(context,
                  'generic.error_dialog_title'.tr(),
                  'orders.sales_form.dialog_content_error_fetching_inventory'.tr());
              return;
            }
          }

          this._formKey.currentState.save();

          List<Orderline> _orderlines = [];
          for (int i = 0; i < _orderMaterialMutations.length; ++i) {
            LocationMaterialMutation materialMutation = _orderMaterialMutations[i];

            Orderline orderline = Orderline(
                product: '${materialMutation.amount} x ${materialMutation.materialName}',
                location: materialMutation.locationName,
                pricePurchase: utils.round(materialMutation.pricePurchase * materialMutation.amount),
                priceSelling: utils.round(materialMutation.priceSelling * materialMutation.amount),
                locationRelationInventory: materialMutation.locationId,
                materialRelation: materialMutation.materialId,
                amount: materialMutation.amount
            );

            _orderlines.add(orderline);
          }

          Order order = Order(
            customerId: _selectedCustomer.customerId,
            customerRelation: _selectedCustomer.id,
            startDate: utils.formatDate(DateTime.now()),
            startTime: utils.formatTime(DateTime.now()),
            endDate: utils.formatDate(DateTime.now()),
            endTime: utils.formatTime(DateTime.now()),
            orderName: _selectedCustomer.name,
            orderAddress: _selectedCustomer.address,
            orderPostal: _selectedCustomer.postal,
            orderCity: _selectedCustomer.city,
            orderCountryCode: _selectedCustomer.countryCode,
            orderTel: _selectedCustomer.tel,
            orderMobile: _selectedCustomer.mobile,
            orderEmail: _selectedCustomer.email,
            orderContact: _selectedCustomer.contact,
            orderLines: _orderlines,
          );

          setState(() {
            _inAsyncCall = true;
          });

          final orderApi = OrderApi();
          Order newOrder = await orderApi.insert(order);

          setState(() {
            _inAsyncCall = false;
          });

          // insert/edit ok?
          if (newOrder == null) {
            displayDialog(context, 'generic.error_dialog_title'.tr(),
                'orders.error_storing_order'.tr());

            return;
          }

          createSnackBar(context, 'orders.sales_form.snackbar_created'.tr());

          // refresh widget
          _orderMaterialMutations = [];
          _salesOrderAmountController.text = '1';

          setState(() {});
        }
      },
    );
  }

}
