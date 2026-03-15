#!/bin/bash

insert_into_table() {
    echo ""
    echo " Insert Into Table "
    
    if ! list_tables silent; then     # if no tables => exit
        press_enter
        return
    fi
    
    read -p "Enter Table Name: " table_name
    
    if ! check_existance "Table" "$table_name"; then
        press_enter
        return
    fi
    
    # read meta file and split columns by |
    mapfile -t columns < <(tr '|' '\n' < "databases/$CURRENT_DB/$table_name.meta") # metadata => replace | with  \n => process subs.(cmd o/p as file I/P) => mapfile reads I/P line by line and remove (\n) => store each line as element in columns array

    row_string=""
    
    for col in "${columns[@]}"; 
    do
        col_name=$(echo "$col" | cut -d':' -f1)
        col_type=$(echo "$col" | cut -d':' -f2)
        col_pk=$(echo "$col" | cut -d':' -f3)
        [ "$col_pk" == "pk" ] && is_pk=1 || is_pk=0

        valid=0
        while [ $valid -eq 0 ]; 
        do
            read -p "Enter value for $col_name ($col_type): " value

            if [[ "$value" == *"|"* ]]; then
                echo "Error: Value cannot contain '|'"

            elif [ $is_pk -eq 1 ] && [ -z "$value" ]; then
                echo "Error: Primary Key cannot be empty"

            elif [ "$col_type" == "int" ] && [[ ! "$value" =~ ^[0-9]+$ ]]; then
                echo "Error: Value must be an integer"

            elif [ $is_pk -eq 1 ]; then
                awk -F'|' -v val="$value" '$1 == val' "databases/$CURRENT_DB/$table_name.tbl" | grep -q . && echo "Error: Primary key '$value' already exists" || valid=1
            else
                valid=1
            fi
        done

        if [ -z "$row_string" ]; then      # append value to row (first value has no | prefix)
            row_string="$value"
        else
            row_string="$row_string|$value"
        fi

    done
    
    echo "$row_string" >> "databases/$CURRENT_DB/$table_name.tbl" # save row to .tbl file
    echo "Row inserted successfully"
    
    press_enter
}

select_from_table() {
    echo ""
    echo " Select From Table "

    # check and show available tables
    if ! list_tables silent; then     # if no tables => exit
        press_enter
        return
    fi

    read -p "Enter Table Name: " table_name

    if ! check_existance "Table" "$table_name"; then
        press_enter
        return
    fi

    # read columns from meta file
    mapfile -t columns < <(tr '|' '\n' < "databases/$CURRENT_DB/$table_name.meta")

    header=""
    separator=""

    # build header and separator from column names
    for col in "${columns[@]}"; do
        col_name=$(echo "$col" | cut -d':' -f1)
        dash=$(echo "$col_name" | tr 'a-zA-Z0-9_' '-')  # replace each char with -

        if [ -z "$header" ]; then
            header="$col_name"
            separator="$dash"
        else
            header="$header|$col_name"
            separator="$separator|$dash"
        fi
    done

    # display table
    if [ ! -s "databases/$CURRENT_DB/$table_name.tbl" ]; then
        echo "Table is empty."
    else
        echo ""
        echo "────────────────────────────────────────────────────────"
        { echo "$header"; echo "$separator"; cat "databases/$CURRENT_DB/$table_name.tbl"; } | column -t -s '|' -o ' | '
        echo "────────────────────────────────────────────────────────"
    fi

    press_enter
}

delete_from_table() {
    echo ""
    echo " Delete From Table "
    
    if ! list_tables silent; then
        echo "No tables found"
        press_enter
        return
    fi
    
    read -p "Enter Table Name: " table_name
    
    if ! check_existance "Table" "$table_name"; then
        press_enter
        return
    fi
    
    if [ ! -s "databases/$CURRENT_DB/$table_name.tbl" ]; then
        echo "Table is empty."
        press_enter
        return
    fi
    
    mapfile -t columns < <(tr '|' '\n' < "databases/$CURRENT_DB/$table_name.meta")
    
    echo ""
    echo "Columns:"
    for col in "${columns[@]}"; do
        name=$(echo "$col" | cut -d':' -f1)
        echo "  - $name"
    done
    echo ""
    
    read -p "Enter column name: " col_name
    
    # find where this column is
    position=0
    col_found=0
    for i in "${!columns[@]}"; do
        current=$(echo "${columns[$i]}" | cut -d':' -f1)
        if [ "$current" == "$col_name" ]; then
            position=$((i + 1))
            col_found=1
            break
        fi
    done
    
    if [ $col_found -eq 0 ]; then
        echo "Error: Column not found"
        press_enter
        return
    fi
    
    read -p "Enter value to delete: " value
    
    # count rows before delete
    before=$(wc -l < "databases/$CURRENT_DB/$table_name.tbl")
    
    # keep rows that dont match
    awk -F'|' -v pos="$position" -v val="$value" \
        '$pos != val' "databases/$CURRENT_DB/$table_name.tbl" > "databases/$CURRENT_DB/$table_name.tbl.tmp"
    
    mv "databases/$CURRENT_DB/$table_name.tbl.tmp" "databases/$CURRENT_DB/$table_name.tbl"
    
    # count rows after
    after=$(wc -l < "databases/$CURRENT_DB/$table_name.tbl")
    deleted=$((before - after))
    
    if [ $deleted -eq 0 ]; then
        echo "No rows deleted"
    else
        echo "$deleted row deleted"
    fi
    
    press_enter
}

update_table() {
    echo ""
    echo " Update Table "
    
    if ! list_tables silent; then
        press_enter
        return
    fi
    
    read -p "Enter Table Name: " table_name
    
    if ! check_existance "Table" "$table_name"; then
        press_enter
        return
    fi
    
    if [ ! -s "databases/$CURRENT_DB/$table_name.tbl" ]; then
        echo "Table is empty."
        press_enter
        return
    fi
    
    mapfile -t columns < <(tr '|' '\n' < "databases/$CURRENT_DB/$table_name.meta")
    
    pk_name=$(echo "${columns[0]}" | cut -d':' -f1)
    
    echo ""
    read -p "Enter $pk_name to update: " pk_value
    
    if [ -z "$pk_value" ]; then
        echo "ID cannot be empty"
        press_enter
        return
    fi
    
    row=$(awk -F'|' -v id="$pk_value" '$1 == id' "databases/$CURRENT_DB/$table_name.tbl")
    
    if [ -z "$row" ]; then
        echo "Error: Row not found"
        press_enter
        return
    fi
    
    echo ""
    echo "Current row:"
    echo "─────────────────────"
    IFS='|' read -ra vals <<< "$row"
    for i in "${!columns[@]}"; do
        name=$(echo "${columns[$i]}" | cut -d':' -f1)
        echo "  $name: ${vals[$i]}"
    done
    echo "─────────────────────"
    echo ""
    
    # show what can be updated
    echo "Columns:"
    for i in "${!columns[@]}"; do
        if [ $i -ne 0 ]; then
            name=$(echo "${columns[$i]}" | cut -d':' -f1)
            echo "  - $name"
        fi
    done
    echo ""
    
    read -p "Enter column to update: " col_name
    
    if [ "$col_name" == "$pk_name" ]; then
        echo "Cannot update ID"
        press_enter
        return
    fi
    
    # find column
    col_pos=0
    col_type=""
    found=0
    
    for i in "${!columns[@]}"; do
        name=$(echo "${columns[$i]}" | cut -d':' -f1)
        if [ "$name" == "$col_name" ]; then
            col_pos=$((i + 1))
            col_type=$(echo "${columns[$i]}" | cut -d':' -f2)
            found=1
            break
        fi
    done
    
    if [ $found -eq 0 ]; then
        echo "Column not found"
        press_enter
        return
    fi
    
    valid=0
    while [ $valid -eq 0 ]; do
        read -p "Enter new value ($col_type): " new_val
        
        if [[ "$new_val" == *"|"* ]]; then
            echo "Error: Cannot use |"
        
        elif [ "$col_type" == "int" ] && [[ ! "$new_val" =~ ^[0-9]+$ ]]; then
            echo "Error: Must be number"
        
        else
            valid=1
        fi
    done
    
    # update the row
    awk -F'|' -v OFS='|' -v id="$pk_value" -v pos="$col_pos" -v val="$new_val" \
        '$1 == id { $pos = val } { print }' \
        "databases/$CURRENT_DB/$table_name.tbl" > "databases/$CURRENT_DB/$table_name.tbl.tmp"
    
    mv "databases/$CURRENT_DB/$table_name.tbl.tmp" "databases/$CURRENT_DB/$table_name.tbl"
    
    echo ""
    echo "Row updated"
    
    press_enter
}
