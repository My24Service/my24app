# My24Service App

Dart/Flutter App for My24Service.com available for Android and iOS.

[![CircleCI](https://circleci.com/gh/My24Service/my24app/tree/master.svg?style=svg)](https://circleci.com/gh/My24Service/my24app/tree/master)

[![Codemagic build status](https://api.codemagic.io/apps/5f81e5289ccdab5e0ec6e73b/605c7a793c76b368c0f2abc1/status_badge.svg)](https://codemagic.io/apps/5f81e5289ccdab5e0ec6e73b/605c7a793c76b368c0f2abc1/latest_build)


## Project layout

I chose to keep the project layout feature-based, like it's currently done in the Django backend.


## Run tests

Pass TESTING as environment variable to skip FireBase setup and position determination.

```
$ TESTING=1 flutter test test
```
