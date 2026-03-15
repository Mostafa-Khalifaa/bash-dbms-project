# 🗄️ Bash DBMS Project

A simple Database Management System built with Bash shell scripting.

---

## 📚 About

This project is part of the **Open Source Track** at **ITI (Information Technology Institute)**.

**Duration:** 7 Days Sprint Project  
**Date:** March 2025


---

## ✨ Features

- Create and manage databases
- Create tables with columns
- Insert data with validation
- View data in tables
- Update records
- Delete records
- Primary key support
- Data type validation (int/str)

---

## 🚀 How to Run

```bash
# Clone the repository
git clone https://github.com/Mostafa-Khalifaa/bash-dbms.git
cd bash-dbms

# Make executable
chmod +x dbms.sh

# Run
./dbms.sh
```

---

## 📖 Usage

### Main Menu
```
================================
    DATABASE MANAGEMENT SYSTEM  
================================
1) Create Database
2) List Databases
3) Connect to Database
4) Drop Database
5) Exit
================================
```

### Database Menu (after connecting)
```
================================
  DATABASE: school
================================
1) Create Table
2) List Tables
3) Drop Table
4) Insert into Table
5) Select From Table
6) Delete From Table
7) Update Table
8) Back to Main Menu
================================
```

---

## 📂 Project Structure

```
bash-dbms/
├── dbms.sh                  # Main script
├── helpers.sh               # Helper functions
├── db_operations.sh         # Database operations
├── table_operations.sh      # Table operations
├── data_operations.sh       # Data operations
└── databases/               # Data storage (auto-created)
```

---

## 💾 How Data is Stored

### Database = Folder
```
databases/school/
```

### Table = Two Files
```
students.meta    (column definitions)
students.tbl     (actual data)
```

### Example Files

**students.meta:**
```
id:int:pk|name:str|age:int
```

**students.tbl:**
```
1|Ahmed|20
2|Sara|22
3|Ali|21
```
---

## 🛠️ Technologies

- **Language:** Bash Shell Script
- **Tools:** AWK
- **Environment:** Linux/Unix

---

## 🎓 What We Learned
 
- Bash scripting
- File operations
- Data validation
- Modular programming
- Database concepts

---

## 👥 Team

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/mohamedabdelhaq-123">
        <img src="https://github.com/mohamedabdelhaq-123.png" width="100px;" alt=""/>
        <br />
        <sub><b>Mohamed Abdelhaq</b></sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/Mostafa-Khalifaa">
        <img src="https://github.com/Mostafa-Khalifaa.png" width="100px;" alt=""/>
        <br />
        <sub><b>Mostafa Khalifa</b></sub>
      </a>
    </td>
  </tr>
</table>

---

## 📄 License

MIT License - feel free to use and modify.

---

<div align="center">

**Made with ❤️ by ITI Open Source Track Students**

*March 2025*

</div>
