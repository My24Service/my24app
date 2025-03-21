import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24app/company/api/company_api.dart';
import 'package:my24app/company/models/engineer/models.dart';

import '../../company/models/models.dart';

typedef OnEngineerAdded( int engineerId );
typedef OnEngineerRemoved( int engineerId );


/// Renders an input field for searching Engineers that will be visibly added below the
/// input field, where they can be deleted.
class EngineersSection extends StatefulWidget {
  final My24i18n i18nIn;
  final CoreWidgets widgetsIn;

  final OnEngineerAdded? onEngineerAdded;
  final OnEngineerRemoved? onEngineerRemoved;

  final TextStyle? textStyle;
  final TextStyle? tileItemStyle;

  final Color selectedColor;

  const EngineersSection(
    {required this.i18nIn,
    required this.widgetsIn,
    this.textStyle,
    this.tileItemStyle,
    this.onEngineerAdded,
    this.onEngineerRemoved,
    this.selectedColor = Colors.green} ) : super();

  @override
  State<StatefulWidget> createState() => _EngineersSectionState();
}

class _EngineersSectionState extends State<EngineersSection> {
  final GlobalKey fieldKey = GlobalKey<State<StatefulWidget>>();
  final FocusNode focusNode = FocusNode();
  
  late TextEditingController searchTextController;
  final List<CompanyUser> selectedEngineers = [];

  @override
  void initState() {
    super.initState();
    searchTextController = TextEditingController();
    focusNode.addListener( _onCheckScrollInputField );
  }


  /// After an Engineer is selected, this updates the local list of items
  /// and performs the callback to the calling context.
  void _onEngineerAdded( CompanyUser engineer ) {
    
    // If it isn't already there, we can add it.
    final int indexOf = selectedEngineers.indexOf(engineer);
    if (indexOf > -1) {
      return;
    }
    
    //
    selectedEngineers.add( engineer );
    widget.onEngineerAdded?.call( engineer.id );

    // Possibly, we can reset the input field, as the search has already
    // occurred and the user might want to start a new search.
    searchTextController.text = '';
    
    setState(() {});
  }

  void _onEngineerRemoved( CompanyUser engineer ) {
    selectedEngineers.remove( engineer );
    widget.onEngineerRemoved?.call( engineer.id );

    setState(() {});
  }

  bool _isEngineerSelected( CompanyUser engineer ) {
    for(CompanyUser selected in selectedEngineers) {
      if (selected.id == engineer.id) 
        return true;
    }
    return false;
  }

  /// Helper method to determine the absolute position of an item inside
  /// a parent scroll area. We need this to determine the correct scroll offset
  /// to force the input field at the top of the screen.
  double? _scrollOffsetOf(GlobalKey<State> key) {
    if (key.currentContext case final currentContext?) {
      final renderBox = currentContext.findRenderObject();
      final viewport = RenderAbstractViewport.maybeOf(renderBox);
      if ((viewport, renderBox) case (final viewport?, final renderBox?)) {
        return viewport.getOffsetToReveal(renderBox, 0).offset;
      }
    }
    return null;
  }

  /// The edit field must be just below the title bar, so there is plenty 
  /// room for the drop down of user suggestions, so this method checks
  /// if there is focus on the input field and moves it up there.
  void _onCheckScrollInputField() {
    
    if (!focusNode.hasFocus || fieldKey.currentContext == null) {
      return;
    }
   
    final object = fieldKey.currentContext!.findRenderObject();
    if (object != null) {
      final double? scrollOffset = _scrollOffsetOf(fieldKey);
      if (scrollOffset != null) {
        final scrollableState = Scrollable.of(context);
        final ScrollPosition position = scrollableState.position;
        final double difference = scrollOffset - 60.0;

        Future.delayed( const Duration(milliseconds: 500), () {
          if (!mounted) return;          
          position.animateTo(
              difference,
              duration: const Duration(milliseconds: 80),
              curve: Curves.decelerate
          );
        } );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    final List<Widget> columnItems = [
      widget.widgetsIn.createHeader( widget.i18nIn.$trans('header_engineers') ),
      TypeAheadFormField<CompanyUser>(
        key: fieldKey,
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: focusNode,
          controller: searchTextController,
          onTap: () => _onCheckScrollInputField(),
          decoration: InputDecoration(
              labelText: widget.i18nIn.$trans('typeahead_label_search_engineer')
          ),
        ),
        suggestionsCallback: (pattern) async {
          return await companyApi.userListTypeAhead( pattern, userType: 'engineer' );
        },
        itemBuilder: (context, CompanyUser suggestion) {
          // If the user is already selected, we might want to grey it out.
          TextStyle? tileItemStyle = widget.tileItemStyle;
          if (_isEngineerSelected(suggestion)) {
            if (tileItemStyle == null)  tileItemStyle = TextStyle( color: widget.selectedColor );
            else tileItemStyle = tileItemStyle.copyWith( color: widget.selectedColor);
          }

          return ListTile(
            title: Text( suggestion.name, style: tileItemStyle ),
          );
        },
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        onSuggestionSelected: _onEngineerAdded,
        validator: (value) { _onCheckScrollInputField(); return null; },
        onSaved: (value) => {},
      ),
      SizedBox( height: 20.0 )
    ];

    final TextStyle textStyle = widget.textStyle ?? themeData.textTheme.bodyMedium!.copyWith(fontSize: 18.0);
    for (CompanyUser user in selectedEngineers) {
      columnItems.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded( child: Text( user.name, style: textStyle) ),
            IconButton( icon: Icon(Icons.delete_forever ),
                color: themeData.primaryColor,
                // color: Colors.white,
                // style: IconButton.styleFrom(backgroundColor: themeData.primaryColor),
                onPressed: () => _onEngineerRemoved(user) )
          ],
        )
      );
    }

    // Add whitespace so the dropdown has space to show usernames.
    columnItems.add( SizedBox( //key: fieldKey,
        height: 320.0
    ) );

    return Column(
      children: columnItems
    );
  }

}