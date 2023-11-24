# My24Service App

Dart/Flutter App for My24Service.com available for Android and iOS.

[![Flutter tests](https://github.com/My24Service/my24app/actions/workflows/flutter.yml/badge.svg)](https://github.com/My24Service/my24app/actions/workflows/flutter.yml)

[![Codemagic build status](https://api.codemagic.io/apps/5f81e5289ccdab5e0ec6e73b/605c7a793c76b368c0f2abc1/status_badge.svg)](https://codemagic.io/apps/5f81e5289ccdab5e0ec6e73b/605c7a793c76b368c0f2abc1/latest_build)


## Project layout

I chose to keep the project layout feature-based, like it's currently done in the Django backend.

### Components

All components (should) have the following folders (for a complete/working example of this check "leave types" the `company` folder, the rest is still mostly WIP to the new setup):

- api - old API code that should be gone in time
- blocs - the app uses the BLoC pattern (https://pub.dev/packages/bloc), blocs and states 
are defined here; most API actions are handled via blocs.
- models - folders with the models we have, devided into:
  - `api.dart` - a class that extends `BaseCrud` with model types, for basic CRUD handling.
  - `form_data.dart` - a class that extends `BaseFormData` with model type, to handle form-to-model and model-to-form functionality. Should have:
    - `getProp` / `setProp` - manage a map of String to class attributes (in dart we can't set properties dynamicly like in javascript);
    this is used to track changes in `TextEditingController`s to map to attributes in the class
    - factory `createFromModel`
    - factory `createEmpty`
    - method `toModel`
    - method `isValid`
  - `models.dart` - our models with:
    - model for one item, extends `BaseModel`, should implement:
      - factory `fromJson`
      - method `toJson`
    - model for collection, extends `BaseModelPagination`, should implement:
      - factory `fromJson`
- pages - folder with "pages" for functionality; in flutter everything is a widget, but these are most top level widgets of some piece of functionality and they map BLoC events to certain widgets (for example list, create, edit).
- widgets - folder with widgets to handle a certain piece of functionality that actually been rendered. Cotains:
  - `error.dart` - a widget to show an error, triggered in the page when something goes wrong (non-BLoC, but should also catch BLoC exceptions in the future)
  - `form.dart` - a widget for form handling (new/edit); this is a Stateful widget because we need to cleanup/dispose `TextEditingController`s and other things that cause memory leaks (listeners, etc.). It should have:
    - `initState()` where `TextEditingController`s are 1) attached to attributes in the form data class and 2) registered for disposal via `addTextEditingController`
    - `dispose()` which calls super and `disposeAll()` for disposal of any controllers, listeners, etc.
    - `build()` mandatory for flutter to render the widget
  - `list.dart` - a widget to show items from the API
  - `mixins.dart` - common functionality for the widgets

### Translations

Translations are located in the `res` directory.

### Tests

Tests are located in the `test` directory. I tried to create tests for all components' BLoCs and widgets as much as possible.


## Run tests

Pass TESTING as environment variable to skip FireBase setup and position determination.

```
$ ./run_tests.sh
```

## Install

### Install flutter

https://docs.flutter.dev/get-started/install

### Set development environment

Change settings to use the development environment API (*.my24service-dev.com):

`./set_dev.sh`

Ask for `android/app/google-services.json` when developing with a android setup, or `ios/Runner/Info.plist` when developing on iOS.

### IDE

IntelliJ and VScode both have decent development environments for Dart/Flutter with emulators.

#### VSCode

https://docs.flutter.dev/development/tools/vs-code

#### IntelliJ/JetBrains
https://docs.flutter.dev/development/tools/android-studio

Install java

`$ apt install openjdk-19-jre-headless`

### macOS install

https://docs.flutter.dev/get-started/install/macos

### KVM

KVM on Linux might not be available by default, check:

https://ubuntu.com/blog/kvm-hyphervisor

