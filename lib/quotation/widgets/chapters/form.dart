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
          final bloc = BlocProvider.of<ChapterBloc>(context);

          if (state.status == ChapterStatus.loading) {
            return Container(
                height: 100, child: Center(child: CircularProgressIndicator()));
          }

          if (state.status == ChapterStatus.error) {
            return Container(
              height: 200,
              child: widgetsIn.errorNoticeWithReload(
                  state.message!,
                  bloc,
                  ChapterEvent(
                      status: ChapterEventStatus.FETCH_ALL,
                      quotationId: quotationId)),
            );
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
        Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              maintainState: true,
              tilePadding: EdgeInsets.all(0),
              title: Text(checkNull(chapter.name)),
              subtitle: Text(checkNull(chapter.description)),
              children: [
                QuotationLineWidget(
                    quotationId: chapter.quotation,
                    chapterId: chapter.id,
                    widgetsIn: widgetsIn,
                    i18nIn: i18nIn),
              ],
            ))
      ];
    }, (Chapter chapter) {
      return <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: widgetsIn.createElevatedButtonColored(
                    i18nIn.$trans('delete_chapter_button'), () {
                  _showDeleteDialog(context, chapter);
                }, foregroundColor: Colors.white, backgroundColor: Colors.red))
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
                            labelText: widget.i18nIn.$trans('info_name')),
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
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 4,
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
                        child: widget.widgetsIn.createSubmitButton(
                            context, () => _saveNewChapter(context)))
                  ])
                ],
              )),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (newChapter)
              widget.widgetsIn
                  .createCancelButton(() => _triggerNewChapter(context, false)),
            if (!newChapter)
              widget.widgetsIn.createDefaultElevatedButton(
                  context,
                  widget.i18nIn.$trans('title_chapter_add'),
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
      widget.chapterForms.newChapterForm();

      bloc.add(ChapterEvent(status: ChapterEventStatus.DO_ASYNC));
      bloc.add(ChapterEvent(
          status: ChapterEventStatus.INSERT,
          chapter: newChapter,
          chapterForms: widget.chapterForms));
    }
  }

  void _triggerNewChapter(BuildContext context, bool isNew) {
    setState(() {
      newChapter = isNew;
    });
  }
}
