#!/bin/bash

cd lib

rm -f app_config.dart
ln -s app_config-live.dart app_config.dart

cd ..
