#!/bin/bash

flutter packages upgrade

TESTING=1 flutter test test
dart analyze
