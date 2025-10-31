#!/bin/bash

echo "Setting up and running Delivery Areas Manager..."
echo "=============================================="

# Install required packages
echo "Installing dependencies..."
pip install -r requirements.txt --break-system-packages

echo ""
echo "Running delivery areas manager..."
echo "================================="

# Run the Python script
python3 delivery_areas_manager.py

echo ""
echo "Script execution completed!"