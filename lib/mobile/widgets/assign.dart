import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

import 'package:my24app/company/models/models.dart';
import 'package:my24app/mobile/blocs/assign_bloc.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/pages/unassigned.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import '../models/assign/form_data.dart';

class AssignWidget extends BaseSliverPlainStatelessWidget{
  final String basePath = "orders.assign";
  final Order? order;
  final List<EngineerUser>? engineers;
  final AssignOrderFormData? formData;
  final String? memberPicture;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  AssignWidget({
    Key? key,
    required this.order,
    required this.engineers,
    required this.formData,
    required this.memberPicture,
    required this.widgetsIn,
    required this.i18nIn,
  }) : super(
      key: key,
      mainMemberPicture: memberPicture,
      widgets: widgetsIn,
      i18n: i18nIn
  );

  @override
  Widget getBottomSection(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widgetsIn.createElevatedButtonColored(
              i18nIn.$trans('action_cancel', pathOverride: 'generic'),
              () => { _navList(context) }
          ),
          SizedBox(width: 10),
          widgetsIn.createDefaultElevatedButton(
              context,
              i18nIn.$trans('button_assign'),
              () => { _doAssign(context) }
          ),
        ]
    );
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Column(
      children: [
        widgetsIn.createHeader(i18nIn.$trans('header_order')),
        widgetsIn.buildOrderInfoCard(context, order!),
        Divider(),
        _createEngineersTable(context),
      ]
    );
  }

  bool _isEngineerSelected(EngineerUser engineer) {
    return formData!.selectedEngineerPks.contains(engineer.id);
  }

  Widget _createEngineersTable(BuildContext context) {
    return widgetsIn.buildItemsSection(
      context,
      i18nIn.$trans('header_engineers'),
      engineers,
      (engineer) {
        return <Widget>[
          CheckboxListTile(
              value: _isEngineerSelected(engineer),
              activeColor: Colors.green,
              onChanged:(bool? newValue) {
                if (newValue!) {
                  formData!.selectedEngineerPks.add(engineer.id);
                } else {
                  formData!.selectedEngineerPks.remove(engineer.id);
                }

                _updateFormData(context);
              },
              title: Text('${engineer.fullName}')
          )
        ];
      },
      (item) {
        return <Widget>[
        ];
      },
    );
  }

  void _navList(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrdersUnAssignedPage(
      bloc: OrderBloc(),
    )));
  }

  void _doAssign(BuildContext context) {
    if (formData!.selectedEngineerPks.length == 0) {
      widgetsIn.displayDialog(context,
          i18nIn.$trans('dialog_no_engineers_selected_title'),
          i18nIn.$trans('dialog_no_engineers_selected_content')
      );
      return;
    }

    final bloc = BlocProvider.of<AssignBloc>(context);
    bloc.add(AssignEvent(status: AssignEventStatus.DO_ASYNC));
    bloc.add(AssignEvent(
        status: AssignEventStatus.ASSIGN,
        formData: formData,
        orderId: order!.orderId
    ));
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<AssignBloc>(context);
    bloc.add(AssignEvent(status: AssignEventStatus.DO_ASYNC));
    bloc.add(AssignEvent(
      status: AssignEventStatus.UPDATE_FORM_DATA,
      formData: formData,
      order: order
    ));
  }
}
