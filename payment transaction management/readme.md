Payment Management And Analysis

Project Overview

This project focuses on creating and analyzing a Payment Management System using MySQL. The Payment table is connected with the Orders table through a foreign key relationship, allowing payment details to be tracked for each order.

Objectives

Create a structured Payment table. Establish an Order–Payment relationship using a foreign key. Store payment mode, status, date, and transaction amount. Perform payment status analysis. Analyze payment methods and revenue. Display customer payment history using table joins. Payment Table Design The Payment table stores payment details such as Order ID, Payment Date, Payment Mode, Payment Status, and Transaction Amount. It uses Primary Key, Foreign Key, Auto Increment, Default, and CHECK constraints for proper data management.

ER Relationship

The Payment table is connected to the Orders table using:

Orders (1) ─────── (Many) Payment

One order can have payment records associated with it, while each payment belongs to a particular order.


<img width="768" height="757" alt="WhatsApp Image 2026-09-07 at 12 29 16" src="https://github.com/user-attachments/assets/70448928-14fc-4934-9a0e-00e552009067" />

Payment Analysis Reports Report 1 – Payment Mode Analysis


<img width="551" height="70" alt="WhatsApp Image 2026-09-07 at 12 29 33" src="https://github.com/user-attachments/assets/93f9408a-03ab-4537-8e10-5100a5fd2d43" />

Shows the number of UPI transactions, card payments and the most preferred payment method.

Report 2 – Revenue Analysis

<img width="580" height="257" alt="WhatsApp Image 2026-09-07 at 12 30 12" src="https://github.com/user-attachments/assets/df84cb26-384a-4b6d-8566-f65c933b62b1" />


Shows total revenue, revenue by payment method and average transaction amount.

Report 3 – Customer Payment History


<img width="580" height="257" alt="WhatsApp Image 2026-09-07 at 12 30 12" src="https://github.com/user-attachments/assets/21c98f9e-bf88-4572-aad1-a2cba06fe1df" />


Shows customer name, order ID, payment mode, amount and payment status.

Technologies Used

MySQL MySQL Workbench SQL Conclusion

The Payment Management System provides a structured way to store and analyze customer payment information. The SQL queries help identify preferred payment methods, analyze revenue, monitor transaction statuses, and track individual customer payment history


