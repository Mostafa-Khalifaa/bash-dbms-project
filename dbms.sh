#!/bin/bash

source ./helpers.sh
source ./db_operations.sh
source ./table_operations.sh
source ./data_operations.sh


CURRENT_DB="" # global var for connected database


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