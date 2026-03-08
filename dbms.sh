#!/bin/bash
create_database(){
    echo ""
    echo " Create Database "
    read -p "Enter Database Name " name

    if [ -z "$name" ]; then
        echo "Error name is empty"
        return
    fi 

    mkdir -p databases # create dir. if doesn't exit

    if [ -d "databases/$name" ]; then
        echo "Error Database name already exists"
        return
    fi 

    mkdir "databases/$name"
    echo "$name Database is created successfully"

    echo ""
    read -p "Press Enter to continue"
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
    
    echo ""
    read -p "Press Enter to continue"
}

drop_database() {
    echo "  Drop Database  "
    echo ""
    
    if [ -z "$(ls -A databases/)" ]; then
        echo "No databases found."
        read -p "Press Enter to continue"
        return
    fi
    echo "Available databases:"
    ls databases/
    echo ""
    
    read -p "Enter database name to drop: " db_name
    
    if [ -z "$db_name" ]; then
        echo "Database name cannot be empty"
        read -p "Press Enter to continue"
        return
    fi
    
    if [ ! -d "databases/$db_name" ]; then
        echo "Database '$db_name' does not exist"
        read -p "Press Enter to continue"
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
    
    echo ""
    read -p "Press Enter to continue"
}




main_menu() {
    while true; do
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
                # connect_database
                ;;
            4)
                drop_database
                ;;
            5)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid choice!"
                sleep 2
                ;;
        esac
    done
}

main_menu