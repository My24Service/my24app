import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/mobile/blocs/assign_bloc.dart';
import 'package:my24app/mobile/blocs/assign_states.dart';
import 'package:my24app/mobile/widgets/assign.dart';
import 'package:my24app/order/pages/unassigned.dart';
import 'package:my24app/company/api/company_api.dart';
import 'package:my24app/company/models/models.dart';
import 'package:my24app/inventory/models/models.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import '../models/models.dart';

class MaterialPageData {
  final int? preferredLocation;
  final StockLocations? locations;
  final String? memberPicture;

  MaterialPageData({
    this.preferredLocation,
    this.locations,
    this.memberPicture
  });
}

class OrderAssignPage extends StatelessWidget{
  final i18n = My24i18n(basePath: "orders.assign");
  final int? orderId;
  final AssignBloc bloc;
  final CompanyApi companyApi = CompanyApi();
  final CoreWidgets widgets = CoreWidgets();

  OrderAssignPage({
    Key? key,
    required this.orderId,
    required this.bloc,
  }): super(key: key);

  Future<OrderAssignPageData> _getOrderAssignPageData() async {
    EngineerUsers engineerUsers = await this.companyApi.fetchEngineers();
    String? memberPicture = await coreUtils.getMemberPicture();

    OrderAssignPageData result = OrderAssignPageData(
      memberPicture: memberPicture,
      engineers: engineerUsers.results,
    );

    return result;
  }

  AssignBloc _initialCall() {
    bloc.add(AssignEvent(status: AssignEventStatus.DO_ASYNC));
    bloc.add(AssignEvent(
        status: AssignEventStatus.FETCH_ORDER,
        orderPk: orderId
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderAssignPageData>(
        future: _getOrderAssignPageData(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            final OrderAssignPageData? pageMetaData = snapshot.data;

            return BlocProvider<AssignBloc>(
                create: (context) => _initialCall(),
                child: BlocConsumer<AssignBloc, AssignState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          body: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                              child: _getBody(context, state, pageMetaData)
                          )
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    i18n.$trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": "${snapshot.error}"}
                    )
                )
            );
          } else {
            return Scaffold(
                body: widgets.loadingNotice()
            );
          }
        }
    );
  }

  void _handleListeners(BuildContext context, state) async {
    if (state is AssignedState) {
      widgets.createSnackBar( context, i18n.$trans('snackbar_assigned'));

      await Future.delayed(Duration(seconds: 1));

      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (context) => OrdersUnAssignedPage(
                bloc: OrderBloc(),
              ))
      );
    }
  }

  Widget _getBody(context, state, OrderAssignPageData? pageMetaData) {
    final AssignBloc bloc = BlocProvider.of<AssignBloc>(context);

    if (state is AssignErrorState) {
      return widgets.errorNoticeWithReload(
          state.message!,
          bloc,
          AssignEvent(
              status: AssignEventStatus.FETCH_ORDER,
              orderPk: orderId
          )
      );
    }

    if (state is OrderLoadedState) {
      return AssignWidget(
        order: state.order,
        formData: state.formData,
        engineers: pageMetaData!.engineers,
        memberPicture: pageMetaData.memberPicture,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    return widgets.loadingNotice();
  }
}
