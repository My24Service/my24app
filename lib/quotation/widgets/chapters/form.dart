import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24_flutter_core/models/base_models.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/quotation/blocs/chapter_bloc.dart';
import 'package:my24app/quotation/blocs/chapter_states.dart';
import 'package:my24app/quotation/models/chapter/models.dart';
import 'package:my24app/quotation/widgets/quotation_line/form.dart';

class ChapterFormWidget extends StatefulWidget {
  final int? quotationId;
  final CoreWidgets widgetsIn;

  ChapterFormWidget({
    Key? key,
    required this.quotationId,
    required this.widgetsIn
  });

  @override
  State<ChapterFormWidget> createState() => _ChapterFormWidgetState();
}

class _ChapterFormWidgetState extends State<ChapterFormWidget>
    with TextEditingControllerMixin, i18nMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void dispose() {
    disposeAll();
    super.dispose();
  }

  ChapterBloc _initialCall() {
    final ChapterBloc bloc = ChapterBloc();

    bloc.add(ChapterEvent(status: ChapterEventStatus.DO_ASYNC));
    bloc.add(ChapterEvent(
        status: ChapterEventStatus.FETCH_ALL, quotationId: widget.quotationId));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _initialCall(),
      child: BlocConsumer<ChapterBloc, ChapterState>(
        listener: (context, state) {
          _handleListeners(context, state);
        },
        builder: (context, state) {
          return _getBody(context, state);
        },
      ),
    );
  }

  void _handleListeners(context, state) {
    final bloc = BlocProvider.of<ChapterBloc>(context);

    if (state is ChapterNewState) {
      _showCreateChapterDialog(context, state, bloc);
    }

    if (state is ChapterDeletedState) {
      widget.widgetsIn.createSnackBar(context, 'Chapter deleted');
      bloc.add(ChapterEvent(status: ChapterEventStatus.DO_ASYNC));
      bloc.add(ChapterEvent(
          status: ChapterEventStatus.FETCH_ALL,
          quotationId: widget.quotationId));
    }
  }

  List<Chapter> _loadedChapters = [];
  Widget _getBody(BuildContext context, state) {
    final bloc = BlocProvider.of<ChapterBloc>(context);

    if (state is ChapterLoadingState) {
      return showLoading();
    }

    if (state is ChapterErrorState) {
      return Container(
        height: 200,
        child: widget.widgetsIn.errorNoticeWithReload(
            state.message!,
            bloc,
            ChapterEvent(
                status: ChapterEventStatus.FETCH_ALL,
                quotationId: widget.quotationId)),
      );
    }

    if (state is ChaptersLoadedState || state is ChapterInsertedState) {
      List<ExpansionTile> chapters = [];
      _loadedChapters = state.chapters?.results ?? _loadedChapters;

      for (final chapter in state.chapters?.results ?? _loadedChapters) {
        chapters.add(ExpansionTile(
          tilePadding: EdgeInsets.all(0),
          title: Text(checkNull(chapter.name)),
          subtitle: Text(checkNull(chapter.description)),
          children: [
            QuotationLineFormWidget(
                quotationId: widget.quotationId, chapterId: chapter.id,
                widgetsIn: widget.widgetsIn,
            ),
          ],
        ));
      }

      if (state is ChapterInsertedState) {
        chapters.add(ExpansionTile(
          tilePadding: EdgeInsets.all(0),
          title: Text(checkNull(state.chapter!.name)),
          subtitle: Text(checkNull(state.chapter!.description)),
          children: [
            QuotationLineFormWidget(
              quotationId: widget.quotationId,
              chapterId: state.chapter!.id,
              isNewChapter: true,
              widgetsIn: widget.widgetsIn,
            ),
          ],
        ));
      }

      return Column(
        children: [
          ...chapters,
          if (state is ChaptersLoadedState) _newChapterButton(context)
        ],
      );
    }

    return showLoading();
  }

  Widget _newChapterButton(BuildContext context) {
    return widget.widgetsIn.createElevatedButtonColored(
        'Add new chapter', () => _triggerNewChapterDialog(context),
        foregroundColor: Colors.white, backgroundColor: Colors.red
    );
  }

  void _triggerNewChapterDialog(context) {
    final bloc = BlocProvider.of<ChapterBloc>(context);

    bloc.add(ChapterEvent(status: ChapterEventStatus.NEW));
  }

  void _showCreateChapterDialog(BuildContext context, state, bloc) {
    final bloc = BlocProvider.of<ChapterBloc>(context);
    final GlobalKey<FormState> _chapterFormKey = GlobalKey<FormState>();

    addTextEditingController(nameController, state.formData!, 'name');
    addTextEditingController(
        descriptionController, state.formData!, 'description');

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('New chapter'),
          content: Form(
              key: _chapterFormKey,
              child: Table(
                children: [
                  TableRow(children: [
                    TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'Name *'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter the chapter name';
                          }
                          return null;
                        }),
                  ]),
                  TableRow(children: [
                    TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: (value) {
                          return null;
                        }),
                  ])
                ],
              )),
          actions: [
            TextButton(
                child: Text(getTranslationTr('utils.button_cancel')),
                onPressed: () {
                  bloc.add(ChapterEvent(status: ChapterEventStatus.DO_ASYNC));
                  bloc.add(ChapterEvent(status: ChapterEventStatus.CANCEL));
                  Navigator.of(context).pop(true);
                }),
            TextButton(
                child: Text($trans('button_submit', pathOverride: 'generic')),
                onPressed: () {
                  if (_chapterFormKey.currentState!.validate()) {
                    _chapterFormKey.currentState!.save();
                    state.formData.quotation = widget.quotationId;
                    Chapter newChapter = state.formData!.toModel();
                    bloc.add(ChapterEvent(status: ChapterEventStatus.DO_ASYNC));
                    bloc.add(ChapterEvent(
                      status: ChapterEventStatus.INSERT,
                      chapter: newChapter,
                    ));
                    Navigator.of(context).pop(true);
                  }
                }),
          ],
        );
      },
    );
  }

  Widget showLoading() {
    return Center(child: CircularProgressIndicator());
  }
}
