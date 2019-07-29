#!/bin/bash

pub get
pub global activate webdev
pub global run webdev build --output=web:build

echo 'Start server with:'
echo '	dart bin/main.dart'
