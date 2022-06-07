import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  bool firstTime = true;

  ImageBloc _initialBlocCall() {
    final ImageBloc bloc = ImageBloc();

    if (firstTime) {
      bloc.add(ImageEvent(
          status: ImageEventStatus.DO_ASYNC));
      bloc.add(ImageEvent(
          status: ImageEventStatus.FETCH_ALL,
          quotationPk: widget.quotationPk));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initialBlocCall(),
        child: BlocConsumer<ImageBloc, ImageState>(
          listener: (context, state) {
            _handleListeners(context, state, widget.quotationPk);
          },
          builder: (context, state) {
            return Scaffold(
                appBar: AppBar(
                    title: Text('quotations.images.app_bar_title'.tr())),
                body: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: _getBody(context, state, widget.quotationPk)
                )
            );
          }
      )
    );
  }

  void _handleListeners(context, state, quotationPk) {
    final bloc = BlocProvider.of<ImageBloc>(context);

    if (state is ImageDeletedState) {
      if (state.result == true) {
        createSnackBar(context, 'quotations.images.snackbar_deleted'.tr());

        bloc.add(ImageEvent(
            status: ImageEventStatus.DO_ASYNC));
        bloc.add(ImageEvent(
            status: ImageEventStatus.FETCH_ALL,
            quotationPk: quotationPk));
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'quotations.images.error_deleting_dialog_content'.tr());
      }
    }
  }

  Widget _getBody(context, state, int quotationPk) {
    final bloc = BlocProvider.of<ImageBloc>(context);

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
              quotationPk: quotationPk
          )
      );
    }

    if (state is ImagesLoadedState) {
      return ImageWidget(
          images: state.images,
          quotationPk: quotationPk
      );
    }

    return loadingNotice();
  }
}
