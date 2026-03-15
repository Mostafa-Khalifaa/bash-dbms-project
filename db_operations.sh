#!/bin/bash

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