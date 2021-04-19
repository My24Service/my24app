import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/order/blocs/document_states.dart';
import 'package:my24app/order/widgets/documents.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/quotation/blocs/image_bloc.dart';
import 'package:my24app/quotation/blocs/image_states.dart';
import 'package:my24app/quotation/widgets/images.dart';

class ImagesPage extends StatefulWidget {
  final dynamic quotationPk;

  ImagesPage({
    Key key,
    @required this.quotationPk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  ImageBloc _initialBlocCall() {
    final bloc = ImageBloc(ImageInitialState());

    bloc.add(ImageEvent(
        status: ImageEventStatus.DO_ASYNC));
    bloc.add(ImageEvent(
        status: ImageEventStatus.FETCH_ALL,
        quotationPk: widget.quotationPk));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => _initialBlocCall(),
        child: Builder(
            builder: (BuildContext context) {
              final ImageBloc bloc = BlocProvider.of<ImageBloc>(context);

              return Scaffold(
                  appBar: AppBar(
                      title: Text('quotations.images.app_bar_title'.tr())),
                  body: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: BlocListener<ImageBloc, ImageState>(
                        listener: (context, state) {
                          if (state is ImageInsertedState) {
                            if(state.image != null) {
                              createSnackBar(context, 'quotations.images.snackbar_added'.tr());

                              bloc.add(ImageEvent(
                                  status: ImageEventStatus.DO_ASYNC));
                              bloc.add(ImageEvent(
                                  status: ImageEventStatus.FETCH_ALL,
                                  quotationPk: widget.quotationPk));

                              setState(() {});
                            } else {
                              displayDialog(context,
                                  'generic.error_dialog_title'.tr(),
                                  'quotations.images.error_adding'.tr());
                            }
                          }

                          if (state is ImageDeletedState) {
                            if (state.result == true) {
                              createSnackBar(context, 'quotations.images.snackbar_deleted'.tr());

                              bloc.add(ImageEvent(
                                  status: ImageEventStatus.DO_ASYNC));
                              bloc.add(ImageEvent(
                                  status: ImageEventStatus.FETCH_ALL,
                                  quotationPk: widget.quotationPk));

                              setState(() {});
                            } else {
                              displayDialog(context,
                                  'generic.error_dialog_title'.tr(),
                                  'quotations.images.error_deleting_dialog_content'.tr());
                            }
                          }
                        },
                        child: BlocBuilder<ImageBloc, ImageState>(
                            builder: (context, state) {
                              if (state is ImageInitialState) {
                                return loadingNotice();
                              }

                              if (state is ImageLoadingState) {
                                return loadingNotice();
                              }

                              if (state is ImageErrorState) {
                                return errorNoticeWithReload(
                                    state.message,
                                    bloc,
                                    ImageEvent(
                                        status: ImageEventStatus.FETCH_ALL,
                                        quotationPk: widget.quotationPk
                                    )
                                );
                              }

                              if (state is ImagesLoadedState) {
                                return ImageWidget(
                                    images: state.images,
                                    quotationPk: widget.quotationPk
                                );
                              }

                              return loadingNotice();
                            }
                        )
                    ),
                  )
              );
            }
        )
    );
  }
}
