CREATE DATABASE LibraryDB;
USE LibraryDB;

CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100),
    publisher VARCHAR(100),
    total_copies INT NOT NULL,
    available_copies INT NOT NULL
);

CREATE TABLE Members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100),
    join_date DATE
);

CREATE TABLE Issue (
    issue_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    member_id INT,
    issue_date DATE,
    due_date DATE,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);

CREATE TABLE Fine (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    issue_id INT,
    fine_amount DECIMAL(6,2),
    fine_status VARCHAR(20),
    FOREIGN KEY (issue_id) REFERENCES Issue(issue_id)
);

INSERT INTO Books(title, author, publisher, total_copies, available_copies)
VALUES
('Java Programming', 'James Gosling', 'Oracle Press', 10, 10),
('Database Systems', 'Elmasri', 'Pearson', 5, 5),
('Data Structures', 'Seymour Lipschutz', 'McGraw Hill', 8, 8),
('Computer Networks', 'Andrew Tanenbaum', 'Pearson', 6, 6),
('Python Programming', 'Guido van Rossum', 'OReilly', 12, 12),
('Software Engineering', 'Pressman', 'McGraw Hill', 9, 9);

INSERT INTO Members(name, phone, email, join_date)
VALUES
('Abhishek', '9876543210', 'abhi@email.com', CURDATE()),
('Rahul', '9123456780', 'rahul@email.com', CURDATE()),
('Sneha', '9988776655', 'sneha@email.com', CURDATE()),
('Amit', '9012345678', 'amit@email.com', CURDATE()),
('Priya', '9090909090', 'priya@email.com', CURDATE()),
('Rohan', '8888888888', 'rohan@email.com', CURDATE());

START TRANSACTION;

INSERT INTO Issue(book_id, member_id, issue_date, due_date, return_date)
VALUES
(1, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), DATE_ADD(CURDATE(), INTERVAL 10 DAY)),
(2, 2, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY)),
(3, 3, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), NULL),
(4, 4, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY)),
(5, 5, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), NULL);

UPDATE Books 
SET available_copies = available_copies - 1 
WHERE book_id IN (1,2,3,4,5);

COMMIT;

START TRANSACTION;

INSERT INTO Fine(issue_id, fine_amount, fine_status)
SELECT issue_id,
DATEDIFF(return_date, due_date) * 5,
'Unpaid'
FROM Issue
WHERE return_date IS NOT NULL
AND return_date > due_date;

COMMIT;

SELECT Members.name, Books.title, Issue.issue_date, Issue.due_date, Issue.return_date
FROM Issue
JOIN Members ON Issue.member_id = Members.member_id
JOIN Books ON Issue.book_id = Books.book_id;

SELECT * FROM Fine
WHERE fine_status = 'Unpaid';

SELECT member_id, COUNT(book_id) AS total_books
FROM Issue
GROUP BY member_id;

SELECT member_id, COUNT(book_id) AS total_books
FROM Issue
GROUP BY member_id
HAVING COUNT(book_id) > 0;

SELECT name
FROM Members
WHERE member_id IN (
    SELECT Issue.member_id
    FROM Issue
    JOIN Fine ON Issue.issue_id = Fine.issue_id
    WHERE Fine.fine_status = 'Unpaid'
);

SELECT title, total_copies, available_copies,
(total_copies - available_copies) AS issued_books
FROM Books;

CREATE VIEW Issued_Books_View AS
SELECT Members.name, Books.title, Issue.issue_date, Issue.due_date
FROM Issue
JOIN Members ON Issue.member_id = Members.member_id
JOIN Books ON Issue.book_id = Books.book_id;

SELECT * FROM Issued_Books_View;
