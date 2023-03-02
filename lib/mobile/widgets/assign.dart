import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/company/models/models.dart';
import 'package:my24app/mobile/blocs/assign_bloc.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/company/api/company_api.dart';

class AssignWidget extends StatefulWidget {
  final Order order;

  AssignWidget({
    Key key,
    @required this.order,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _AssignWidgetState();
}

class _AssignWidgetState extends State<AssignWidget> {
  List<EngineerUser> _engineers = [];
  List<int> _selectedEngineerPks = [];
  bool _inAsyncCall = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    _doFetchEngineers();
  }

  _doFetchEngineers() async {
    _inAsyncCall = true;
    try {
      EngineerUsers result = await companyApi.fetchEngineers();

      setState(() {
        _engineers = result.results;
        _inAsyncCall = false;
      });
    } catch(e) {
      _inAsyncCall = false;
      displayDialog(
          context,
          'generic.error_dialog_title'.tr(),
          'generic.error'.tr()
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        child: Center(
            child: _showMainView()
        ), inAsyncCall: _inAsyncCall
    );
  }

  Widget _showMainView() {
    return Align(
        alignment: Alignment.topRight,
        child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              createHeader('orders.assign.header_order'.tr()),
              Table(
                children: [
                  TableRow(
                      children: [
                        Text('orders.info_order_id'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.order.orderId != null ? widget.order.orderId : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_order_type'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.order.orderType != null ? widget.order.orderType : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_order_date'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.order.orderDate != null ? widget.order.orderDate : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Divider(),
                        SizedBox(height: 10),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_customer'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.order.orderName != null ? widget.order.orderName : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_customer_id'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.order.orderName != null ? widget.order.customerId : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_address'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.order.orderAddress != null ? widget.order.orderAddress : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_postal'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.order.orderPostal != null ? widget.order.orderPostal : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_country_city'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.order.orderCountryCode + '/' + widget.order.orderCity),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_contact'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.order.orderContact != null ? widget.order.orderContact : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_tel'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.order.orderTel != null ? widget.order.orderTel : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_mobile'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.order.orderMobile != null ? widget.order.orderMobile : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_order_customer_remarks'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.order.customerRemarks != null ? widget.order.customerRemarks : '')
                      ]
                  )
                ],
              ),
              Divider(),
              createHeader('orders.assign.header_engineers'.tr()),
              _createEngineersTable(),
            ]
        )
    );
  }

  bool _isEngineerSelected(EngineerUser engineer) {
    return _selectedEngineerPks.contains(engineer.id);
  }

  _createEngineersTable() {
    if(_engineers.length == 0) {
      return buildEmptyListFeedback();
    }

    List<TableRow> rows = [];

    // engineers
    for (int i = 0; i < _engineers.length; ++i) {
      EngineerUser engineer = _engineers[i];

      rows.add(
          TableRow(
              children: [
                Column(
                    children:[
                      CheckboxListTile(value: _isEngineerSelected(engineer),
                          activeColor: Colors.green,
                          onChanged:(bool newValue) {
                            if (newValue) {
                              _selectedEngineerPks.add(engineer.id);
                            } else {
                              _selectedEngineerPks.remove(engineer.id);
                            }

                            setState(() {});
                          },
                          title: Text('${engineer.fullName}')
                      )
                    ]
                ),
              ]
          )
      );
    }

    rows.add(
        TableRow(
            children: [
              SizedBox(height: 20)
            ]
        )
    );

    rows.add(
        TableRow(
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  child: Text('orders.assign.button_assign'.tr()),
                  onPressed: () async {
                    if (_selectedEngineerPks.length == 0) {
                      displayDialog(context,
                          'orders.assign.dialog_no_engineers_selected_title'.tr(),
                          'orders.assign.dialog_no_engineers_selected_content'.tr()
                      );
                      return;
                    }
                    
                    final bloc = BlocProvider.of<AssignBloc>(context);
                    bloc.add(AssignEvent(status: AssignEventStatus.DO_ASYNC));
                    bloc.add(AssignEvent(
                        status: AssignEventStatus.ASSIGN,
                        engineerPks: _selectedEngineerPks,
                        orderId: widget.order.orderId
                    ));
                  }
              )
            ]
        )
    );

    return createTable(rows);
  }
}
