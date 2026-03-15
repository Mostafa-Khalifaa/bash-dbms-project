#!/bin/bash

create_table() {
    echo ""
    echo " Create Table "
    read -p "Enter Table Name: " table_name

    #check on table name
    if ! validate_name "$table_name" "Table"; then
        press_enter
        return
    fi 

    # check on table name existence
    if ! check_duplicate "Table" "$table_name"; then
        press_enter
        return
    fi
    
    # check on num. of cols
    read -p "Enter number of columns: " cols
    if [[ ! "$cols" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Number of columns must be a positive integer"
        press_enter
        return
    fi
    
    columns=""  
    for (( i=1; i<=$cols; i++ )); do  # loop on cols (name,type)

        # column name
        if [ $i -eq 1 ]; then
            col_name="id"
        else
            read -p "Enter column $i name: " col_name
            while ! validate_name "$col_name" "Column"; do
                read -p "Enter column $i name: " col_name
            done
        fi

        # column type
        col_type=""
        while [ "$col_type" != "int" ] && [ "$col_type" != "str" ]; # user still input until type int or str
         do
            read -p "Enter type for '$col_name' (int/str): " col_type

            if [ "$col_type" != "int" ] && [ "$col_type" != "str" ]; then
                echo "Error: Type must be 'int' or 'str'"
            fi

        done

        # build column
        if [ $i -eq 1 ]; then
            col="id:${col_type}:pk"
        else
            col="${col_name}:${col_type}"
        fi

        # build all columns type to save in .meta
        if [ -z "$columns" ]; then
            columns="$col"  # for first (id)
        else
            columns="$columns|$col" # append rest cols after id (PK) with |
        fi
        
    done
        
    echo "$columns" > "databases/$CURRENT_DB/$table_name.meta"  # save cols types in .meta
    touch "databases/$CURRENT_DB/$table_name.tbl" # create empty .tbl file for data

    echo "Table '$table_name' created successfully"
    press_enter
}


list_tables() {

    local silent="$1"  # if "silent" skip press_enter

    if [ "$silent" != "silent" ]; then
        echo ""
        echo " List Tables "
    fi
    
    count=$(ls -1q "databases/$CURRENT_DB/"*.tbl 2>/dev/null | wc -l)
    if [ "$count" -eq 0 ]; then
        if [ "$silent" != "silent" ]; then
            echo "No tables found."
            press_enter
        fi
        return 1
    else
        if [ "$silent" == "silent" ]; then
            echo "Available tables:"
        fi
        for file in "databases/$CURRENT_DB/"*.tbl; do
            table_name="${file##*/}"    # remove path =>> students.tbl
            table_name="${table_name%.tbl}"  # remove extension =>> students
            echo "  - $table_name"
        done
    fi
    
    if [ "$silent" != "silent" ]; then # flag to skip press_enter (used in insert dec. DRY concept)
        press_enter
    fi
    return 0
}

drop_table() {
    echo ""
    echo " Drop Table "
    
    count=$(ls -1q "databases/$CURRENT_DB/"*.tbl 2>/dev/null | wc -l)
    if [ "$count" -eq 0 ]; then
        echo "No tables found."
        press_enter
        return
    fi
    
    echo "Available tables:"
    for file in "databases/$CURRENT_DB/"*.tbl; do
        table_name="${file##*/}"    # remove path =>> students.tbl
        table_name="${table_name%.tbl}"  # remove extension =>> students
        echo "  - $table_name"
    done
    echo ""
    
    read -p "Enter table name to drop: " table_name
    
    if ! validate_name "$table_name" "Table"; then
        press_enter
        return
    fi
    
    if ! check_existance "Table" "$table_name"; then
        press_enter
        return
    fi
    
    rm -i "databases/$CURRENT_DB/$table_name.tbl"
    rm -i "databases/$CURRENT_DB/$table_name.meta"

    if [ ! -f "databases/$CURRENT_DB/$table_name.tbl" ]; then
        echo "Table '$table_name' dropped successfully"
    else
        echo "Drop cancelled"
    fi
    
    press_enter
}