#!/bin/bash

echo "Standard call (should be 200)"
curl -I localhost:8080/ 2>/dev/null | head -n1

echo "Custom rules (should be 403)"
curl -I localhost:8080/?a=test 2>/dev/null | head -n1

echo "SQL Injection rules (should be 403)"
curl -I localhost:8080/?param=%27%20OR%201 2>/dev/null | head -n1
