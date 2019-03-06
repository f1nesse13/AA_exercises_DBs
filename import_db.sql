DROP TABLE if EXISTS question_follows;
DROP TABLE if EXISTS question_likes;
DROP TABLE if EXISTS replies;
DROP TABLE if EXISTS questions;
DROP TABLE if EXISTS users;


PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

INSERT INTO users (fname, lname)
VALUES  ("Joseph", "Pell"), ("Layla", "Pell"), ("Liz", "Pell"), ("Bubby", "Pell");

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (id) REFERENCES users(id)
);

INSERT INTO questions (title, body, author_id)
VALUES ("Joseph Question", "Who?", (SELECT id
FROM users WHERE users.fname = "Joseph" AND users.lname = "Pell"));

INSERT INTO questions (title, body, author_id)
VALUES
("Layla Question", "What?", (SELECT id
FROM users WHERE users.fname = "Layla" AND users.lname = "Pell"));

INSERT INTO questions (title, body, author_id)
VALUES ("Liz Question", "When?", (SELECT id
FROM users WHERE users.fname = "Liz" AND users.lname = "Pell"));

INSERT INTO questions (title, body, author_id)
VALUES ("Bubby Question", "Where?", (SELECT id
FROM users WHERE users.fname = "Bubby" AND users.lname = "Pell"));

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


INSERT INTO question_follows (user_id, question_id)

VALUES

((SELECT id FROM users WHERE fname = "Bubby" AND lname = "Pell"),
  (SELECT id FROM questions WHERE title = "Joseph Question")
),

((SELECT id FROM users WHERE fname = "Layla" AND lname = "Pell"),
  (SELECT id FROM questions WHERE title = "Joseph Question")
),

((SELECT id FROM users WHERE fname = "Liz" AND lname = "Pell"),
(SELECT id FROM questions WHERE title = "Bubby Question")
);


CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  author_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  body TEXT NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (author_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
);

INSERT INTO replies (question_id, author_id, parent_reply_id, body)

VALUES
  ( (SELECT id FROM questions WHERE title = "Liz Question"),
    (SELECT id FROM users WHERE fname = "Layla" AND lname = "Pell"),
    NULL,
    "Right now!"
  );
INSERT INTO replies (question_id, author_id, parent_reply_id, body)

VALUES
  (
    (SELECT id FROM questions WHERE title = "Liz Question"),
    (SELECT id FROM users WHERE fname = "Bubby" AND lname = "Pell"),
    (SELECT id FROM replies WHERE body = "Right now!"),
    "How about later?"
  );

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO question_likes (user_id, question_id)
  VALUES
  (1,2), (2,1), (3,1), (4, 1), (3, 2), (2, 3), (2, 4)
  -- (
  --   (SELECT id FROM users WHERE fname = "Layla" AND lname = "Pell"),
  --   (SELECT id FROM questions WHERE title = "Liz Question")
  -- ),
  -- (
  --   (SELECT id FROM users WHERE fname = "Joseph" AND lname = "Pell"),
  --   (SELECT id FROM questions WHERE title = "Bubby Question")
  -- );