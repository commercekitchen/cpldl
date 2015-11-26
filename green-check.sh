#!/bin/bash

LIGHTCYAN='\033[0;36m'
NC='\033[0m'

clear

echo ""
echo ""
echo -e "${LIGHTCYAN}**********************************************"
echo "| Running Brakeman and ignoring model output |"
echo -e "**********************************************${NC}"
echo ""
brakeman --ignore-model-output

echo ""
echo ""
echo -e "${LIGHTCYAN}*******************"
echo "| Running Rubocop |"
echo -e "*******************${NC}"
echo ""
rubocop

echo ""
echo ""
echo -e "${LIGHTCYAN}****************************"
echo "| Running Rspec with Color |"
echo -e "****************************${NC}"
echo ""
rspec --color
