#!/bin/bash

# Directory where files will be created
DIRECTORY="lib/spares_management"

# Create directory if it doesn't exist
mkdir -p $DIRECTORY

# Create files for each widget
touch $DIRECTORY/spares_management.dart
touch $DIRECTORY/inventory_requests_tab.dart
touch $DIRECTORY/inventory_available_tab.dart
touch $DIRECTORY/publish_inventory_item_tab.dart

# Output confirmation
echo "Files created:"
echo "$DIRECTORY/spares_management.dart"
echo "$DIRECTORY/inventory_requests_tab.dart"
echo "$DIRECTORY/inventory_available_tab.dart"
echo "$DIRECTORY/publish_inventory_item_tab.dart"
