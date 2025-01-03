# Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)

-- a
select employeeNumber,firstName,lastName from employees
where jobTitle = "Sales Rep" and reportsTo = 1102;

-- b 
select distinct productLine from products 
where productLine like "%Car%";




# Q2. CASE STATEMENTS for Segmentation

-- a

select customerNumber,customerName,
case
	when country in ("USA","Canada") then "North America" 
    when country in ("UK","France","Germany") then "Europe" 
    else "Other"
end as CustomerSegment
from customers;




# Q3. Group By with Aggregation functions and Having clause, Date and Time functions

-- a

select productCode,sum(quantityOrdered) as total_orders 
from orderdetails
group by productCode
order by total_orders desc
limit 10;

-- b 

select monthname(paymentDate) as payment_month, count(*) as num_payment 
from payments 
group by payment_month having num_payment > 20
order by num_payment desc;




# Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default


create database Customers_Orders;

use Customers_Orders;
-- a
create table Customers 
( 
customer_id int primary key auto_increment,
first_name varchar(50) not null,
last_name varchar(50) not null,
email varchar(255) unique,
phone_number varchar(20) 
);

-- b

create table Orders 
(
order_id int primary key auto_increment,
customer_id int,
order_date date,
total_amount decimal(10,2) check (total_amount >0),

foreign key (customer_id) references Customers(customer_id)
);




# Q5. JOINS

-- a
select country,count(orderNumber) as order_count 
from customers join orders on customers.customerNumber = orders.customerNumber
group by country
order by order_count desc
limit 5;




# Q6. SELF JOIN

-- a

create table project
(
 EmployeeID int primary key auto_increment,
 FullName varchar(50),
 Gender enum("Male", "Female"),
 ManagerID int
 );
 
 
 insert into project(FullName,Gender,ManagerID) values
("Pranaya","Male",3),
("Priyanka","Female",1),
("Preety","Female",null),
("Anurag","Male",1),
("Sambit","Male",1),
("Rajesh","Male",3),
("Hina","Female",3);


select m.FullName as Manager_Name, e.FullName as Emp_Name 
from project e
join project m on e.ManagerID = m.EmployeeID 
order by Manager_Name;




# Q7. DDL Commands: Create, Alter, Rename

-- a. Create table facility

create table facility 
(
Facility_ID int ,
Name varchar(100),
State varchar(100),
Country varchar(100)
);


alter table facility 
modify Facility_ID int auto_increment primary key not null;

alter table facility 
add city varchar(100) not null;




# Q8. Views in SQL

create view product_category_sales as 
SELECT 
    pl.productLine AS category_name,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM
    productlines pl
        JOIN
    products p ON pl.productLine = p.productLine
        JOIN
    orderdetails od ON p.productCode = od.productCode
        JOIN
    orders o ON od.orderNumber = o.orderNumber
GROUP BY pl.productLine;

select* from product_category_sales;




# Q9. Stored Procedures in SQL with parameters

delimiter //
create procedure Get_country_payments(in input_year int, in input_country varchar(100))
begin
	select 
		year(pay.paymentDate) as Year,
        c.country, 
        concat(round(sum(pay.amount)/1000),'K') as TotalAmount
	from payments pay
    join customers c on c.customerNumber = pay.customerNumber
    where 
		year(pay.paymentDate) = input_year
        and c.country = input_country
	group by 
		 year(pay.paymentDate), c.country;
end //
delimiter ;

call Get_country_payments(2003, 'France');





# Q10. Window functions - Rank, dense_rank, lead and lag

-- a
select 
    c.customerName,
    count(o.orderNumber) as order_count,
    dense_rank() over (order by count(o.orderNumber) desc) as order_frequency_rnk
from 
    customers c
join 
    orders o 
on 
    c.customerNumber = o.customerNumber
group by 
    c.customerName
order by 
    order_count desc;

-- b

with monthlyorders as (
    select 
        extract(year from orderdate) as order_year,
        extract(month from orderdate) as order_month_number,
        monthname(orderdate) as order_month,
        count(ordernumber) as total_orders
    from orders
    group by extract(year from orderdate), extract(month from orderdate), monthname(orderdate)
),
monthlychange as (
    select 
        order_year,
        order_month_number,
        order_month,
        total_orders,
        lag(total_orders) over (order by order_year, order_month_number) as prev_month_orders
    from monthlyorders
)
select 
    order_year as year,
    order_month as month,
    total_orders,
    case 
        when prev_month_orders is null then 'null'
        else concat(round(((total_orders - prev_month_orders) * 100.0) / prev_month_orders, 0), '%')
    end as `% mom change`
from monthlychange
order by order_year, order_month_number;





# Q11.Subqueries and their applications

select productLine, count(*) as Total
from products
where buyPrice > (select avg(buyPrice) from products)
group by productLine;




# Q12. ERROR HANDLING in SQL

create table Emp_EH(
Empid int primary key,
EmpName varchar(100),
EmailAddress varchar(100));


delimiter //
create procedure new_procedure(
    in p_EmpID int,
    in p_EmpName varchar(100),
    in p_EmailAddress varchar(100)
)
begin
    declare continue handler for sqlexception select "Error occurred" Message;
    insert into Emp_EH (EmpID, EmpName, EmailAddress)
    values (p_EmpID, p_EmpName, p_EmailAddress);
    
    commit;
end//


call new_procedure(1, 'sanekt', 'sanket@example.com');
call new_procedure(1, 'vishal', 'vishal@example.com');




# Q13. TRIGGERS

create table Emp_BIT (
    Name varchar(100),
    Occupation varchar(100),
    Working_date date,
    Working_hours int);

insert into  Emp_BIT (Name, Occupation, Working_date, Working_hours) values
('Robin', 'Scientist', '2020-10-04', 12),
('Warner', 'Engineer', '2020-10-04', 10),
('Peter', 'Actor', '2020-10-04', 13),
('Marco', 'Doctor', '2020-10-04', 14),
('Brayden', 'Teacher', '2020-10-04', 12),
('Antonio', 'Business', '2020-10-04', 11);


delimiter //
create trigger check_working_hours
before insert on Emp_BIT
for each row
begin
    if new.Working_hours < 0 then
        set new.Working_hours = abs(new.Working_hours);
	end if ;
end//


insert into  Emp_BIT (Name, Occupation, Working_date, Working_hours) values
('Sanket', 'Analyst', '2020-10-04', -3);

select * from Emp_BIT; 

