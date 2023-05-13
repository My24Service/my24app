import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/quotation/blocs/image_bloc.dart';
import 'package:my24app/quotation/blocs/image_states.dart';
import 'package:my24app/quotation/pages/part_form.dart';
import 'package:my24app/quotation/widgets/image_form.dart';
import 'package:my24app/core/widgets/widgets.dart';

class PartImageFormPage extends StatefulWidget {
  final int quotationPk;
  final int quotationPartPk;
  final int partImagePk;

  PartImageFormPage({
    Key key,
    this.quotationPk,
    this.quotationPartPk,
    this.partImagePk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _PartImageFormPageState();
}

class _PartImageFormPageState extends State<PartImageFormPage> {
  bool firstTime = true;
  bool isEdit = false;

  PartImageBloc _initialBlocCall(int pk) {
    PartImageBloc bloc = PartImageBloc();

    if (pk != null) {
      bloc.add(PartImageEvent(status: PartImageEventStatus.DO_ASYNC));
      bloc.add(PartImageEvent(
          status: PartImageEventStatus.FETCH_DETAIL, pk: pk));
    } else {
      bloc.add(PartImageEvent(status: PartImageEventStatus.NEW));
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initialBlocCall(widget.partImagePk),
        child: FutureBuilder<String>(
              future: utils.getUserSubmodel(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) {
                  return Scaffold(
                      appBar: AppBar(title: Text('')),
                      body: Container()
                  );
                }

                return BlocConsumer<PartImageBloc, PartImageState>(
                    listener: (context, state) {
                      _listeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                        appBar: AppBar(
                            title: Text(
                            'quotations.part_images.app_bar_title'.tr())
                        ),
                        body: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(
                                  new FocusNode());
                            },
                            child: _getBody(context, state)
                        )
                    );
                  }
                );
          }
        )
    );
  }

  _listeners(BuildContext context, state) {
    if (state is PartImageDeletedState) {
      if (state.result) {
        createSnackBar(context, 'quotations.part_images.snackbar_deleted'.tr());

        final page = PartFormPage(
            quotationPk: widget.quotationPk,
            quotationPartPk: widget.quotationPartPk
        );

        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)
        );
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'quotations.part_images.error_deleting_dialog_content'.tr()
        );
      }
    }

    if (state is PartImageInsertedState) {
      if (state.image != null) {
        createSnackBar(context, 'quotations.part_images.snackbar_created'.tr());

        final page = PartFormPage(
            quotationPk: widget.quotationPk,
            quotationPartPk: widget.quotationPartPk
        );

        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)
        );
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'quotations.part_images.error_inserting_dialog_content'.tr()
        );
      }
    }

    if (state is PartImageEditedState) {
      if (state.result) {
        createSnackBar(context, 'quotations.part_images.snackbar_updated'.tr());

        final page = PartFormPage(
            quotationPk: widget.quotationPk,
            quotationPartPk: widget.quotationPartPk
        );

        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)
        );
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'quotations.part_images.error_updating_dialog_content'.tr()
        );
      }
    }
  }

  Widget _getBody(BuildContext context, state) {
    final PartImageBloc bloc = BlocProvider.of<PartImageBloc>(context);

    if (state is PartImageErrorState) {
      return errorNoticeWithReload(
          state.message,
          bloc,
          PartImageEvent(
              status: PartImageEventStatus.FETCH_DETAIL,
              pk: widget.partImagePk
          )
      );
    }

    if (state is PartImageNewState) {
      return PartImageFormWidget(
        quotationPk: widget.quotationPk,
        quotationPartId: widget.quotationPartPk,
      );
    }

    if (state is PartImageLoadedState) {
      return PartImageFormWidget(
        image: state.image,
        quotationPk: widget.quotationPk,
        quotationPartId: widget.quotationPartPk,
      );
    }

    return loadingNotice();
  }
}
