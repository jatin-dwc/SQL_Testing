USE Excel_Ingestion;


CREATE TABLE Customers (
    CustomerID   INT PRIMARY KEY IDENTITY(1,1),
    FirstName    NVARCHAR(100),
    LastName     NVARCHAR(100),
    Email        NVARCHAR(200),
    CreatedDate  DATE
);

INSERT INTO Customers (FirstName, LastName, Email, CreatedDate)
VALUES ('Jane', 'Smith', 'jane@example.com', '2024-01-15');


INSERT INTO Customers (FirstName, LastName, Email, CreatedDate)
VALUES ('Jatin', 'Lad', 'jatin@datawizardconsulting.com', '2026-02-20');


-- Remove the old table

DROP TABLE if EXISTS Customers ;

-- Create fresh table

CREATE TABLE Customers (
    CustomerID   INT PRIMARY KEY IDENTITY(1,1),
    FirstName    NVARCHAR(100),
    LastName     NVARCHAR(100),
    Email        NVARCHAR(200),
    CreatedDate  DATE
);

-- Insert manual data into table

INSERT INTO Customers (FirstName, LastName, Email, CreatedDate)
VALUES ('Jatin', 'Lad', 'jatin@datawizardconsulting.com', '2026-02-20');
INSERT INTO Customers (FirstName, LastName, Email, CreatedDate)
VALUES ('Jane', 'Swanston', 'jane@example.com', '2030-01-01');


