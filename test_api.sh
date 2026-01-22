#!/bin/bash

# API Testing Script for Flutter Task APIs
# Base URL
BASE_URL="https://mamunuiux.com/flutter_task/api"

echo "======================================"
echo "Testing Flutter Task APIs"
echo "======================================"
echo ""

# Create output directory
mkdir -p api_responses

# Test 1: Home Page Data
echo "1. Testing Home Page Data..."
echo "   URL: GET $BASE_URL"
curl -s -X GET "$BASE_URL" \
  -H "Accept: application/json" \
  -o api_responses/1_home_page_data.json
echo "   ✓ Response saved to: api_responses/1_home_page_data.json"
echo ""

# Test 2: Product List
echo "2. Testing Product List..."
echo "   URL: GET $BASE_URL/product"
curl -s -X GET "$BASE_URL/product" \
  -H "Accept: application/json" \
  -o api_responses/2_product_list.json
echo "   ✓ Response saved to: api_responses/2_product_list.json"
echo ""

# Test 3: Product Details (using slug from postman)
PRODUCT_SLUG="rolex-watch-drop-amid-rising"
echo "3. Testing Product Details..."
echo "   URL: GET $BASE_URL/product/$PRODUCT_SLUG"
curl -s -X GET "$BASE_URL/product/$PRODUCT_SLUG" \
  -H "Accept: application/json" \
  -o api_responses/3_product_details.json
echo "   ✓ Response saved to: api_responses/3_product_details.json"
echo ""

# Test 4: Product By Category
CATEGORY_ID="1"
echo "4. Testing Product By Category (Category ID: $CATEGORY_ID)..."
echo "   URL: GET $BASE_URL/product-by-category/$CATEGORY_ID"
curl -s -X GET "$BASE_URL/product-by-category/$CATEGORY_ID" \
  -H "Accept: application/json" \
  -o api_responses/4_product_by_category.json
echo "   ✓ Response saved to: api_responses/4_product_by_category.json"
echo ""

echo "======================================"
echo "All API tests completed!"
echo "======================================"
echo ""
echo "Generating summary..."
echo ""

# Generate summary
echo "API Response Summary:" > api_responses/summary.txt
echo "====================" >> api_responses/summary.txt
echo "" >> api_responses/summary.txt

# Check each response
for file in api_responses/*.json; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        size=$(wc -c < "$file" | tr -d ' ')
        echo "File: $filename" >> api_responses/summary.txt
        echo "Size: $size bytes" >> api_responses/summary.txt
        
        # Check if it's valid JSON
        if jq empty "$file" 2>/dev/null; then
            echo "Status: Valid JSON ✓" >> api_responses/summary.txt
            
            # Try to extract success field if exists
            success=$(jq -r '.success // empty' "$file" 2>/dev/null)
            if [ ! -z "$success" ]; then
                echo "Success: $success" >> api_responses/summary.txt
            fi
            
            # Try to extract message if exists
            message=$(jq -r '.message // empty' "$file" 2>/dev/null)
            if [ ! -z "$message" ]; then
                echo "Message: $message" >> api_responses/summary.txt
            fi
        else
            echo "Status: Invalid JSON ✗" >> api_responses/summary.txt
        fi
        echo "" >> api_responses/summary.txt
    fi
done

cat api_responses/summary.txt
echo ""
echo "All responses saved in: api_responses/"
