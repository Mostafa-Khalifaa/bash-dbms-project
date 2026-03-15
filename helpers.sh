#!/bin/bash

press_enter() {
    echo ""
    read -p "Press Enter to continue"
}

validate_name() {
    local name="$1"
    local label="$2"
    
    if [ -z "$name" ]; then
        echo "Error: $label name cannot be empty"
        return 1
    fi
    
    if [[ ! "$name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then # check name (reject empty input + must start with letter, then letter/num/_)
        echo "Error: $label name must start with a letter and contain only letters, numbers, and underscores"
        return 1
    fi
    return 0
}

check_existance() {
    local type="$1"
    local name="$2"
    
    if [ "$type" == "Database" ]; then
        if [ ! -d "databases/$name" ]; then
            echo "Error: Database '$name' does not exist"
            return 1
        fi
    elif [ "$type" == "Table" ]; then
        if [ ! -f "databases/$CURRENT_DB/$name.tbl" ]; then
            echo "Error: Table '$name' does not exist"
            return 1
        fi
    elif [ "$type" == "Tables" ]; then         # check if any tables exist in current database
        count=$(ls -1q "databases/$CURRENT_DB/"*.tbl 2>/dev/null | wc -l)
        if [ "$count" -eq 0 ]; then
            echo "No tables found."
            return 1
        fi
    fi
    return 0
}

check_duplicate() {
    local type="$1"
    local name="$2"
    
    if [ "$type" == "Database" ]; then
        if [ -d "databases/$name" ]; then
            echo "Error: Database '$name' already exists"
            return 1
        fi
    elif [ "$type" == "Table" ]; then
        if [ -f "databases/$CURRENT_DB/$name.tbl" ]; then
            echo "Error: Table '$name' already exists"
            return 1
        fi
    fi
    return 0
}