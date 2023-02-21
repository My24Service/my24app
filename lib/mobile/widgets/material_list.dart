import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/core/widgets/sliver_classes.dart';
import 'package:my24app/mobile/models/material/models.dart';

class MaterialListWidget extends BaseSliverStatelessWidget {
  final AssignedOrderMaterials materials;
  final int assignedOrderId;
  final String error;

  MaterialListWidget({
    Key key,
    this.materials,
    this.assignedOrderId,
    this.error
  }) : super(key: key);

  @override
  SliverAppBar getAppBar(BuildContext context) {
    String subtitle = materials != null ? "${materials.count} materials" : "";
    GenericAppBarFactory factory = GenericAppBarFactory(
      context: context,
      title: 'assigned_orders.materials.app_bar_title'.tr(),
      subtitle: subtitle,
    );
    return factory.createAppBar();
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        createButton(
          () { _handleNew(context); },
          title: 'assigned_orders.materials.button_add'.tr(),
        )
      ],
    );
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<MaterialBloc>(context);

    bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
    bloc.add(MaterialEvent(
        status: MaterialEventStatus.FETCH_ALL,
        assignedOrderId: assignedOrderId
    ));
  }

  Widget _createColumnItem(String key, String val, {double width: 100}) {
    return Container(
      alignment: AlignmentDirectional.topStart,
      width: width,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: buildItemListKeyValueList(key, val)
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (error != null) {
      return RefreshIndicator(
          child: Align(
            alignment: AlignmentDirectional.center,
              child: errorNotice(error)
          ),
          onRefresh: () => doRefresh(context)
      );
    }

    return buildItemsSection(
        context,
        null,
        materials.results,
        (AssignedOrderMaterial item) {
          return <Widget>[
            ...buildItemListKeyValueList(
                'assigned_orders.materials.info_material'.tr(),
                item.materialName
            ),
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _createColumnItem(
                      'assigned_orders.materials.info_identifier'.tr(),
                      item.materialIdentifier,
                      width: 140,
                  ),
                  _createColumnItem(
                      'assigned_orders.materials.info_location'.tr(),
                      item.locationName,
                      width: 140,
                  ),
                  _createColumnItem(
                      'assigned_orders.materials.info_amount'.tr(),
                      item.amount.round().toString(),
                      width: 80,
                  ),
                ]
            ),
          ];
        },
        (item) {
          return <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                createDeleteButton(
                  "assigned_orders.materials.button_delete".tr(),
                  () { _showDeleteDialog(context, item); }
                ),
                SizedBox(width: 8),
                createEditButton(
                  () => { _doEdit(context, item) },
                )
              ],
            )
          ];
        }
    );
  }

  _handleNew(BuildContext context) {
    final bloc = BlocProvider.of<MaterialBloc>(context);

    bloc.add(MaterialEvent(
        status: MaterialEventStatus.NEW,
        assignedOrderId: assignedOrderId
    ));
  }

  _doDelete(BuildContext context, AssignedOrderMaterial material) {
    final bloc = BlocProvider.of<MaterialBloc>(context);

    bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
    bloc.add(MaterialEvent(
        status: MaterialEventStatus.DELETE,
        pk: material.id,
        assignedOrderId: assignedOrderId
    ));
  }

  _doEdit(BuildContext context, AssignedOrderMaterial material) {
    final bloc = BlocProvider.of<MaterialBloc>(context);

    bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
    bloc.add(MaterialEvent(
        status: MaterialEventStatus.FETCH_DETAIL,
        pk: material.id
    ));
  }

  _showDeleteDialog(BuildContext context, AssignedOrderMaterial material) {
    showDeleteDialogWrapper(
      'assigned_orders.materials.delete_dialog_title'.tr(),
      'assigned_orders.materials.delete_dialog_content'.tr(),
      () => _doDelete(context, material),
      context
    );
  }
}
