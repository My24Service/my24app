import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24_flutter_core/models/base_models.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/quotation/blocs/chapter_bloc.dart';
import 'package:my24app/quotation/blocs/chapter_states.dart';
import 'package:my24app/quotation/models/chapter/models.dart';
import 'package:my24app/quotation/models/chapter/form_data.dart';
import 'package:my24app/quotation/widgets/quotation_line/form.dart';

class ChapterWidget extends StatelessWidget {
  final int? quotationId;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  ChapterWidget({
    Key? key,
    required this.quotationId,
    required this.widgetsIn,
    required this.i18nIn,
  });

  ChapterBloc _initialCall() {
    final ChapterBloc bloc = ChapterBloc();

    bloc.add(ChapterEvent(status: ChapterEventStatus.DO_ASYNC));
    bloc.add(ChapterEvent(
        status: ChapterEventStatus.FETCH_ALL, quotationId: quotationId));

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
          if (state.status == ChapterStatus.loading) {
            return Center(child: CircularProgressIndicator());
          }

          return Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                )),
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              ChapterList(
                  widgetsIn: widgetsIn,
                  i18nIn: i18nIn,
                  chapterForms: state.chapterForms!),
              ChapterFormWidget(
                chapterForms: state.chapterForms!,
                i18nIn: i18nIn,
                widgetsIn: widgetsIn,
                quotationId: quotationId,
              )
            ]),
          );
        },
      ),
    );
  }

  void _handleListeners(context, state) {
    final bloc = BlocProvider.of<ChapterBloc>(context);

    if (state is ChapterDeletedState) {
      widgetsIn.createSnackBar(
          context, i18nIn.$trans('snackbar_chapter_deleted'));
      bloc.add(ChapterEvent(status: ChapterEventStatus.DO_ASYNC));
      bloc.add(ChapterEvent(
          status: ChapterEventStatus.FETCH_ALL, quotationId: quotationId));
    }
  }
}

class ChapterList extends StatelessWidget {
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  final ChapterForms chapterForms;

  ChapterList(
      {Key? key,
      required this.widgetsIn,
      required this.i18nIn,
      required this.chapterForms});

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ChapterBloc>(context);

    if (bloc.state.status == ChapterStatus.loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (chapterForms.chapters!.isEmpty) {
      return SizedBox();
    }

    return widgetsIn.buildItemsSection(context, "", chapterForms.chapters,
        (Chapter chapter) {
      return <Widget>[
        ExpansionTile(
          tilePadding: EdgeInsets.all(0),
          title: Text(checkNull(chapter.name)),
          subtitle: Text(checkNull(chapter.description)),
          children: [
            Text("crap"),
          ],
        )
      ];
    }, (Chapter chapter) {
      return <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widgetsIn.createDeleteButton(() {
              _showDeleteDialog(context, chapter);
            })
          ],
        )
      ];
    });
  }

  _showDeleteDialog(BuildContext context, Chapter chapter) {
    widgetsIn.showDeleteDialogWrapper(i18nIn.$trans('delete_dialog_title_line'),
        i18nIn.$trans('delete_dialog_content_line'), () {
      final bloc = BlocProvider.of<ChapterBloc>(context);
      bloc.add(ChapterEvent(status: ChapterEventStatus.DO_ASYNC));
      bloc.add(ChapterEvent(status: ChapterEventStatus.DELETE, pk: chapter.id));
    }, context);
  }
}

class ChapterFormWidget extends StatefulWidget {
  final int? quotationId;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  final ChapterForms chapterForms;

  ChapterFormWidget({
    Key? key,
    required this.quotationId,
    required this.widgetsIn,
    required this.i18nIn,
    required this.chapterForms,
  });

  @override
  State<ChapterFormWidget> createState() => _ChapterFormState();
}

class _ChapterFormState extends State<ChapterFormWidget>
    with TextEditingControllerMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _chapterFormKey = GlobalKey<FormState>();
  bool newChapter = false;

  @override
  void initState() {
    addTextEditingController(
        nameController, widget.chapterForms.chapterFormData!, 'name');
    addTextEditingController(descriptionController,
        widget.chapterForms.chapterFormData!, 'description');
    super.initState();
  }

  void dispose() {
    disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (newChapter)
          Form(
              key: _chapterFormKey,
              child: Table(
                children: [
                  TableRow(children: [
                    TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                            labelText: My24i18n.tr('generic.info_name')),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return widget.i18nIn.$trans('invalid_chapter_name');
                            //return 'Please enter the chapter name';
                          }
                          return null;
                        }),
                  ]),
                  TableRow(children: [
                    TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                            labelText: widget.i18nIn
                                .$trans('info_description') // 'Description
                            ),
                        validator: (value) {
                          return null;
                        }),
                  ]),
                  TableRow(children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                        child: widget.widgetsIn.createDefaultElevatedButton(
                            context,
                            widget.i18nIn.$trans('generic.button_submit'),
                            () => _saveNewChapter(context)))
                  ])
                ],
              )),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            widget.widgetsIn.createDefaultElevatedButton(
                context, 'Cancel', () => _triggerNewChapter(context, false)),
            if (!newChapter)
              widget.widgetsIn.createDefaultElevatedButton(
                  context,
                  widget.i18nIn.$trans('button_new_chapter'),
                  () => _triggerNewChapter(context, true))
          ],
        )
      ],
    );
  }

  void _saveNewChapter(BuildContext context) {
    final bloc = BlocProvider.of<ChapterBloc>(context);

    if (_chapterFormKey.currentState!.validate()) {
      _chapterFormKey.currentState!.save();
      widget.chapterForms.chapterFormData!.quotation = widget.quotationId;
      Chapter newChapter = widget.chapterForms.chapterFormData!.toModel();

      bloc.add(ChapterEvent(status: ChapterEventStatus.DO_ASYNC));
      bloc.add(ChapterEvent(
        status: ChapterEventStatus.INSERT,
        chapter: newChapter,
      ));
      Navigator.of(context).pop(true);
    }
  }

  void _triggerNewChapter(BuildContext context, bool isNew) {
    setState(() {
      newChapter = isNew;
    });
  }
}

class _ChapterFormWidgetState extends State<ChapterFormWidget>
    with TextEditingControllerMixin {
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
      widget.widgetsIn.createSnackBar(
          context, widget.i18nIn.$trans('snackbar_chapter_deleted'));
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
              quotationId: widget.quotationId,
              chapterId: chapter.id,
              widgetsIn: widget.widgetsIn,
              i18nIn: widget.i18nIn,
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
              i18nIn: widget.i18nIn,
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
    return widget.widgetsIn.createDefaultElevatedButton(
        context,
        widget.i18nIn.$trans('button_new_chapter'),
        () => _triggerNewChapterDialog(context));
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
          title: Text(widget.i18nIn.$trans('title_chapter_add')),
          content: Form(
              key: _chapterFormKey,
              child: Table(
                children: [
                  TableRow(children: [
                    TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                            labelText: My24i18n.tr('generic.info_name')),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return widget.i18nIn.$trans('invalid_chapter_name');
                            //return 'Please enter the chapter name';
                          }
                          return null;
                        }),
                  ]),
                  TableRow(children: [
                    TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                            labelText: widget.i18nIn
                                .$trans('info_description') // 'Description
                            ),
                        validator: (value) {
                          return null;
                        }),
                  ])
                ],
              )),
          actions: [
            TextButton(
                child: Text(My24i18n.tr('generic.action_cancel')),
                onPressed: () {
                  bloc.add(ChapterEvent(status: ChapterEventStatus.DO_ASYNC));
                  bloc.add(ChapterEvent(status: ChapterEventStatus.CANCEL));
                  Navigator.of(context).pop(true);
                }),
            TextButton(
                child: Text(My24i18n.tr('generic.button_submit')),
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
