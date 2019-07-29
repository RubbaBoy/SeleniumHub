#!/bin/bash

pub get
pub global activate webdev

echo 'Start server with:'
echo '	dart bin/main.dart 42069 build/ /usr/bin/chromedriver'
