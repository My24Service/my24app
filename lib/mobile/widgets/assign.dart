import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/models/order/models.dart';

import 'package:my24app/company/models/engineer/models.dart';
import 'package:my24app/mobile/blocs/assign_bloc.dart';
import 'package:my24app/mobile/widgets/engineers_section.dart';
import '../../order/pages/list.dart';
import '../models/assign/form_data.dart';

class AssignWidget extends BaseSliverPlainStatelessWidget{
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

  // bool _isEngineerSelected(EngineerUser engineer) {
  //   return formData!.selectedEngineerPks.contains(engineer.id);
  // }

  Widget _createEngineersTable( BuildContext context ) {
    return EngineersSection(
        i18nIn: i18nIn,
        widgetsIn: widgetsIn,
        onEngineerAdded: (int id) => formData!.selectedEngineerPks.add( id ),
        onEngineerRemoved: (int id) => formData!.selectedEngineerPks.remove( id ),
    );
  }

  void _navList(BuildContext context) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => OrderListPage(
              bloc: OrderBloc(),
              fetchMode: OrderEventStatus.fetchUnassigned,
            )
        )
    );
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

  // _updateFormData(BuildContext context) {
  //   final bloc = BlocProvider.of<AssignBloc>(context);
  //   bloc.add(AssignEvent(status: AssignEventStatus.DO_ASYNC));
  //   bloc.add(AssignEvent(
  //     status: AssignEventStatus.UPDATE_FORM_DATA,
  //     formData: formData,
  //     order: order
  //   ));
  // }

}
