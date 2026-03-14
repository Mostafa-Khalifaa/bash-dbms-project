#!/bin/bash
CURRENT_DB="" # global var for connected database

################ helper functions  #########################

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

################ database functions #########################



create_database() {
    echo ""
    echo " Create Database "
    read -p "Enter Database Name: " name

    if ! validate_name "$name" "Database"; then
        press_enter
        return
    fi

    mkdir -p databases # create dir. if doesn't exit

    if ! check_duplicate "Database" "$name"; then
        return
    fi 

    mkdir "databases/$name"
    echo "$name Database is created successfully"

    press_enter
}

connect_database() {
    echo ""
    echo " Connect to Database "
    read -p "Enter Database Name: " name

    if ! validate_name "$name" "Database"; then
        press_enter
        return
    fi

    if ! check_existance "Database" "$name"; then
        press_enter
        return
    fi

    CURRENT_DB="$name" # set glob. var.
    db_menu
}

list_databases() {
    echo ""
    echo " List of Databases "
    
    mkdir -p databases # create dir. if doesn't exit

    if [ -z "$(ls -A databases/)" ]; then
        echo "No databases found."
    else
        ls databases/
    fi
    
    press_enter
}

drop_database() {
    echo "  Drop Database  "
    echo ""
    
    if [ -z "$(ls -A databases/)" ]; then
        echo "No databases found."
        press_enter
        return
    fi
    echo "Available databases:"
    ls databases/
    echo ""
    
    read -p "Enter database name to drop: " db_name
    
    if ! validate_name "$db_name" "Database"; then
        press_enter
        return
    fi
    
    if ! check_existance "Database" "$db_name"; then
        press_enter
        return
    fi
    
    echo "Enter y for yes or n for no"
    rm -ri "databases/$db_name"
    if [ ! -d "databases/$db_name" ]; then
        echo ""
        echo "Database '$db_name' deleted success"
    else
        echo ""
        echo "Deletion cancelled"
    fi
    
    press_enter
}


################ table functions #########################


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
    
    # make sure table has data
    if [ ! -s "databases/$CURRENT_DB/$table_name.tbl" ]; then
        echo "Table is empty."
        press_enter
        return
    fi
    
    # read columns from meta
    mapfile -t columns < <(tr '|' '\n' < "databases/$CURRENT_DB/$table_name.meta")
    
    # show columns
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
        echo "$deleted row(s) deleted"
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
        echo "Error: ID cannot be empty"
        press_enter
        return
    fi
    
    # search for row
    row=$(awk -F'|' -v id="$pk_value" '$1 == id' "databases/$CURRENT_DB/$table_name.tbl")
    
    if [ -z "$row" ]; then
        echo "Error: Row not found"
        press_enter
        return
    fi
    
    # show current row
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
        echo "Error: Cannot update ID"
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
        echo "Error: Column not found"
        press_enter
        return
    fi
    
    # get new value
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

db_menu() {
    choice=0
    while [ "$choice" != "8" ]; do
        clear
        echo "================================"
        echo "  DATABASE: $CURRENT_DB"
        echo "================================"
        echo "1) Create Table"
        echo "2) List Tables"
        echo "3) Drop Table"
        echo "4) Insert into Table"
        echo "5) Select From Table"
        echo "6) Delete From Table"
        echo "7) Update Table"
        echo "8) Back to Main Menu"
        echo "================================"
        echo ""
        read -p "Enter your choice [1-8]: " choice
        
        case $choice in
            1)
                create_table
                ;;
            2)
                list_tables
                ;;
            3)
                drop_table
                ;;
            4)
                insert_into_table
                ;;
            5)
                select_from_table
                ;;
            6)
                delete_from_table
                ;;
            7)
                update_table
                ;;

            8)
                echo "Returning to main menu"
                sleep 1
                ;;
            *)
                echo "Invalid choice"
                sleep 2
                ;;
        esac
    done
}


main_menu() {
    choice=0
    while [ "$choice" != "5" ]; do
        clear
        echo "================================"
        echo "    DATABASE MANAGEMENT SYSTEM  "
        echo "================================"
        echo "1) Create Database"
        echo "2) List Databases"
        echo "3) Connect to Database"
        echo "4) Drop Database"
        echo "5) Exit"
        echo "================================"
        echo ""
        read -p "Enter your choice [1-5]: " choice
        
        case $choice in
            1)
                create_database
                ;;
            2)
                list_databases
                ;;
            3)
                connect_database
                ;;
            4)
                drop_database
                ;;
            5)
                echo "Goodbye!"
                sleep 1
                ;;
            *)
                echo "Invalid choice"
                sleep 1
                ;;
        esac
    done
    exit 0 # script end with status code 0 (clean success)
}

main_menu