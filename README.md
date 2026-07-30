# Museum Management System 🏛️📊

Welcome to the **Museum Management System** repository! This project showcases a robust, end-to-end relational database solution designed to efficiently manage the operational and financial aspects of multiple museums. 

Designed with real-world business intelligence in mind, this project is divided into two distinct parts that demonstrate both **core SQL fundamentals** and **advanced PL/SQL (DBMS) capabilities**. It is built using Oracle SQL and focuses on tracking economic data like ticket revenues, donations, exhibit maintenance costs, and staff payroll.

📖 **For full documentation, schema details, and setup guides, please check out the [Project Wiki](https://github.com/danielharton/Museum-Management-System/wiki).**

---

## 📂 Project Structure

This repository highlights progressive database development skills across two main implementations:

### 1. Core SQL Implementation (`Database part.sql`)
This section demonstrates a strong foundation in relational database design, Data Definition Language (DDL), Data Manipulation Language (DML), and complex querying. 
* **Relational Design:** Normalized schema design with primary/foreign key constraints ensuring data integrity across tables (`Museum`, `Exhibits`, `Staff`, `Tickets`, `Donations`, `Financial_Reports`, etc.).
* **Data Retrieval & BI:** Complex SQL queries utilizing `JOIN`s, aggregations (`GROUP BY`, `HAVING`), subqueries, and set operations to extract actionable business insights (e.g., cost-to-revenue ratios, high-performing exhibits).
* **Computed Columns:** Utilization of virtual columns for real-time calculation of metrics like `ProfitOrLoss`.

**Schema Diagram (Core SQL):**

![Database Schema](./database%20schema.png)

### 2. Advanced DBMS Implementation (`DBMS part.sql`)
This section elevates the project by incorporating advanced Oracle PL/SQL programming to automate tasks, enforce complex business rules, and improve security/auditing.
* **Dynamic SQL:** Extensive use of `EXECUTE IMMEDIATE` for dynamic schema generation and data population.
* **Procedural Logic:** Implementation of cursors, loops, and conditional logic to process data iteratively and efficiently.
* **Database Triggers & Auditing:** Implementation of a robust logging mechanism. As seen in the schema below, a new `MUSEUM_LOG` table is integrated to automatically track and audit database actions using triggers.
* **Error Handling:** Robust exception handling for reliable database operations.

**Schema Diagram (Advanced DBMS with Auditing):**

![DBMS Schema](./dbms%20schema.png)

---

## 🎯 Key Skills Demonstrated
* **Database Architecture:** Entity-Relationship modeling, normalization, and constraint management.
* **Oracle SQL & PL/SQL:** Writing complex, performant queries and developing procedural database code.
* **Business Intelligence:** Designing schemas that support financial reporting, trend analysis, and data-driven decision-making.
* **Automation & Auditing:** Using triggers and dynamic SQL to create self-maintaining and secure database environments.

## 🚀 Getting Started
To review the code or run the scripts in your own Oracle environment:
1. Review `Database part.sql` for the core schema and analytical queries.
2. Review `DBMS part.sql` to explore the advanced PL/SQL scripts, dynamic table generation, and auditing triggers.
