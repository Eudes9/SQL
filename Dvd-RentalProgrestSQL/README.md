# 📀 DVD Rental PostgreSQL Project 📀
<p align="center">
  <img src="https://github.com/gordonkwokkwok/DVD-Rental-PostgreSQL-Project/assets/112631794/0ceaa2a3-47a5-4041-8b69-08163b10ea98" alt="Image" width="600">
</p>

## 📚 Introduction
Welcome to the DVD Rental Database Project, a hands-on application of PostgreSQL, the powerful open-source object-relational database system. 🎓

This project encapsulates 15 meticulously designed tables: 'actor', 'film', 'film_actor', 'category', 'film_category', 'store', 'inventory', 'rental', 'payment', 'staff', 'customer', 'address', 'city', and 'country'. Each table represents various facets of a real-world DVD rental business. 📊

As you navigate through this project, you'll gain practical insights into the capabilities of PostgreSQL, refine your database management skills, and understand complex data structures and relationships. Welcome to a learning journey that unravels the intricate operations of a DVD rental store. 🚀

## 🎯 Objective
- Implement SQL querying techniques to explore and manipulate the data.
- Utilize PostgreSQL database system for managing and interacting with the data.
- Leverage Git commands for version control and effective collaboration.
- Maintain comprehensive project documentation and a well-structured code repository here on GitHub.


## 🔧 Tool
- PostgreSQL (Version: 15.3)
- Git (Version: 2.23.0)

## 📊 DVD Rental ER Model
<p align="center">
  <img src="https://github.com/gordonkwokkwok/DVD-Rental-PostgreSQL-Project/assets/112631794/5c55cbde-9e67-4363-99bc-177bf7903882" alt="Image" width="700">
</p>

## 📃 DVD Rental Database Tables
There are 15 tables in the DVD Rental database:

- actor – stores actors data including first name and last name.
- film – stores film data such as title, release year, length, rating, etc.
- film_actor – stores the relationships between films and actors.
- category – stores film’s categories data.
- film_category- stores the relationships between films and categories.
- store – contains the store data including manager staff and address.
- inventory – stores inventory data.
- rental – stores rental data.
- payment – stores customer’s payments.
- staff – stores staff data.
- customer – stores customer data.
- address – stores address data for staff and customers
- city – stores city names.
- country – stores country names.

## 🌐 Dataset
- [Link](https://www.postgresqltutorial.com/postgresql-getting-started/postgresql-sample-database/) ; or
- [Download Here](https://github.com/gordonkwokkwok/DVD-Rental-PostgreSQL-Project/tree/main/dataset)

📝 To restore a .tar file in pgAdmin, follow these steps:
```
1. First, you need to convert the dvdrental.zip file into a dvdrental.tar file. You can use a compression tool like 7-Zip or WinRAR to extract the contents of the dvdrental.zip file. Once extracted, you can create a new archive and save it as dvdrental.tar.

2. Open pgAdmin and connect to your PostgreSQL database server.

3. In the left column of pgAdmin, locate the "Servers" group and expand it. Then expand the server you want to restore the dvdrental.tar file to.

4. Right-click on the "Databases" option under the server and select "Restore..." from the context menu.

5. In the "Restore" dialog box, navigate to the location where you have the dvdrental.tar file saved. Select the file and click on the "OK" or "Open" button to start the restore process.

6. Configure the restore options as needed. You can specify the target database, choose whether to drop existing objects, set the format to "Custom or Tar," and adjust other options according to your requirements.

7. Click the "Restore" button to initiate the restore process. pgAdmin will read the dvdrental.tar file and restore the database schema and data accordingly.

8. Once the restore process completes, you should see a success message indicating that the restore was successful.
```
By following these steps, you will be able to restore the dvdrental.tar file in pgAdmin and have the database available for use.

