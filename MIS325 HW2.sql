-- DROP Section - Victoria Vu vtv244
-- in this section, I created several DROP statements so that I could re-run the code if I encounter errors
DROP TABLE reservation_details;
DROP TABLE location_features_linking;
DROP TABLE reservation;
DROP TABLE customer_payment;
DROP TABLE room;
DROP TABLE location;
DROP TABLE features;
DROP TABLE customer;

DROP SEQUENCE customer_id_seq;
DROP SEQUENCE payment_id_seq;
DROP SEQUENCE reservation_id_seq;
DROP SEQUENCE room_id_seq;
DROP SEQUENCE location_id_seq;
DROP SEQUENCE feature_id_seq;

 -- CREATE SEQUENCE Section - Victoria Vu vtv244
 -- I created sequences to generate and auto-increment integer values for primary keys.
 -- This is before the CREATE TABLE since I was receiving errors if sequences weren't stated before tables.
CREATE SEQUENCE customer_id_seq
    START WITH 100001
    INCREMENT BY 1;
    
 CREATE SEQUENCE payment_id_seq
    START WITH 1
    INCREMENT BY 1;
    
CREATE SEQUENCE reservation_id_seq
    START WITH 1
    INCREMENT BY 1;
    
CREATE SEQUENCE room_id_seq
    START WITH 1
    INCREMENT BY 1;
    
CREATE SEQUENCE location_id_seq
    START WITH 1
    INCREMENT BY 1;
    
CREATE SEQUENCE feature_id_seq
    START WITH 1
    INCREMENT BY 1;
    
-- CREATE TABLE section - Victoria Vu vtv244
 -- I created tables and their respective columns with data types according to the given ERD. I also added Primary Key & Foreign Key constraints at the end of each table's code to identify the PK & FK values.
CREATE TABLE customer
(
customer_ID         NUMBER      DEFAULT customer_id_seq.NEXTVAL,
first_name          VARCHAR(40) NOT NULL,
last_name           VARCHAR(40) NOT NULL,
email               VARCHAR(40) NOT NULL,
phone               VARCHAR(12) NOT NULL,
address_line_1      VARCHAR(50) NOT NULL,
address_line_2      VARCHAR(30),
city                VARCHAR(40) NOT NULL,
state               CHAR(2)     NOT NULL,
zip                 CHAR(5)     NOT NULL,
birthdate           DATE,
stay_credits_earned NUMBER(5)   DEFAULT 0,
stay_credits_used   NUMBER(5)   DEFAULT 0,
CONSTRAINT customer_id_pk
    PRIMARY KEY (customer_id),
CONSTRAINT stay_credits_chk  CHECK (stay_credits_earned > stay_credits_used),
CONSTRAINT email_length_chk  CHECK (LENGTH(email) >= 7)
);

CREATE TABLE customer_payment
(
payment_ID              NUMBER      DEFAULT payment_id_seq.NEXTVAL,
customer_ID             NUMBER      DEFAULT customer_id_seq.NEXTVAL,
cardholder_first_name   VARCHAR(40) NOT NULL,
cardholder_mid_name     VARCHAR(40),
cardholder_last_name    VARCHAR(40) NOT NULL,
cardtype                CHAR(4)     NOT NULL,
cardnumber              NUMBER(16)  NOT NULL,
expiration_date         DATE        NOT NULL,
cc_ID                   CHAR(3)     NOT NULL,
billing_address         VARCHAR(50) NOT NULL,
billing_city            VARCHAR(40) NOT NULL,
billing_state           CHAR(2)     NOT NULL,
billing_zip             CHAR(5)     NOT NULL,
CONSTRAINT payment_id_pk
    PRIMARY KEY (payment_id),
CONSTRAINT customer_id_pay_fk
    FOREIGN KEY (customer_id)
    REFERENCES customer (customer_id)
);

CREATE TABLE location
(
location_ID         NUMBER      DEFAULT location_id_seq.NEXTVAL,
location_name       VARCHAR(40) NOT NULL,
address             VARCHAR(50) NOT NULL,
city                VARCHAR(40) NOT NULL,
state               CHAR(2)     NOT NULL,
zip                 CHAR(5)     NOT NULL,
phone               CHAR(12)    NOT NULL,
url                 VARCHAR(50) NOT NULL,
CONSTRAINT location_ID_pk
    PRIMARY KEY (location_ID)
);

CREATE TABLE reservation
(
reservation_ID      NUMBER      DEFAULT reservation_id_seq.NEXTVAL,
customer_ID         NUMBER      DEFAULT customer_id_seq.NEXTVAL,
location_ID         NUMBER      DEFAULT location_id_seq.NEXTVAL,
confirmation_nbr    CHAR(8)     NOT NULL,
date_created        DATE        DEFAULT SYSDATE NOT NULL,
check_in_date       DATE        NOT NULL,
check_out_date      DATE,
status              CHAR(1)     NOT NULL,
number_of_guests    NUMBER(3)   NOT NULL,
reservation_total   NUMBER      DEFAULT 0,
discount_code       VARCHAR(20),
customer_rating     NUMBER(1),
notes               VARCHAR(100),
CONSTRAINT reservation_id_pk
    PRIMARY KEY (reservation_ID),
CONSTRAINT customer_id_res_fk
    FOREIGN KEY (customer_id)
    REFERENCES customer (customer_id),
CONSTRAINT location_id_res_fk
    FOREIGN KEY (location_ID)
    REFERENCES location (location_ID),
CONSTRAINT status_chk  CHECK (status in ('U','I','C','N','R'))
);

CREATE TABLE room
(
room_ID         NUMBER      DEFAULT room_id_seq.NEXTVAL,
location_ID     NUMBER      DEFAULT location_id_seq.NEXTVAL,
room_number     NUMBER(4)   NOT NULL,
floor           NUMBER(2)   NOT NULL,
room_type       CHAR(1)     NOT NULL,
square_footage  NUMBER(5)   NOT NULL,
max_people      NUMBER(3)   NOT NULL,
weekday_rate    NUMBER(4)   NOT NULL,
weekend_rate    NUMBER(4)   NOT NULL,
CONSTRAINT room_ID_pk
    PRIMARY KEY (room_ID),
CONSTRAINT location_ID_room_fk
    FOREIGN KEY (location_ID)
    REFERENCES location (location_ID),
CONSTRAINT room_type_chk CHECK (room_type in ('D','Q','K','S','C'))
);

CREATE TABLE reservation_details
(
reservation_ID NUMBER           DEFAULT reservation_id_seq.NEXTVAL,
room_ID        NUMBER           DEFAULT room_id_seq.NEXTVAL,
CONSTRAINT room_reservation_pk  PRIMARY KEY (reservation_ID, room_ID),
CONSTRAINT reservation_ID_fkk    FOREIGN KEY (reservation_ID) REFERENCES reservation (reservation_ID),
CONSTRAINT room_ID_fkk           FOREIGN KEY (room_ID) REFERENCES room (room_ID)
);

CREATE TABLE features
(
feature_ID      NUMBER      DEFAULT feature_id_seq.NEXTVAL,
feature_name    VARCHAR(40) NOT NULL,
CONSTRAINT feature_ID_pk
    PRIMARY KEY (feature_ID)
);

CREATE TABLE location_features_linking
(
location_ID NUMBER              DEFAULT location_id_seq.NEXTVAL,
feature_ID  NUMBER              DEFAULT feature_id_seq.NEXTVAL,
CONSTRAINT location_features_pk PRIMARY KEY (location_ID, feature_ID),
CONSTRAINT location_ID_link_fk    FOREIGN KEY (location_ID) REFERENCES location (location_ID),
CONSTRAINT feature_ID_fk           FOREIGN KEY (feature_ID) REFERENCES features (feature_ID)
);


-- ALTER TABLE Section - Victoria Vu vtv244
-- This section alters tables and modifies specified column(s). I used this section to indicate unique values which forces 1-to-1 relationships.
-- Unique values could've been indicated in the CREATE TABLE section, but I found it to be neater to see all the unique values togther.
-- The last ALTER TABLE statement is a composite unique constraint to prevent duplicate rooms at a location.
ALTER TABLE customer
MODIFY email UNIQUE;

ALTER TABLE customer_payment
MODIFY customer_ID UNIQUE;

ALTER TABLE reservation
MODIFY confirmation_nbr UNIQUE;

ALTER TABLE location
MODIFY location_name UNIQUE;

ALTER TABLE features
MODIFY feature_name UNIQUE;

ALTER TABLE room
ADD CONSTRAINT room_uq UNIQUE (location_ID, room_number);

-- CREATE INDEX Section - Victoria Vu vtv244
-- This section creates indexes, which improves performance when searching for rows. 
-- Columns that are assigned indexes are usually all foreign keys that are not also part of a primary key, as well as columns that are searched frequently and updated infrequently.
-- Thus, the two indexes I added that are not named in the instructions include room floor and room_type.
CREATE INDEX customer_id_ix
ON reservation (customer_id);

CREATE INDEX location_id_ix
ON reservation (location_id);
 
CREATE INDEX location_id_ixx
ON room (location_id);

CREATE INDEX floor_ix
ON room (floor);

CREATE INDEX room_type_ix
ON room (room_type);


 -- SEED DATA Section - Victoria Vu vtv244
 -- In this section, I inserted applicable values to their respective tables using the INSERT INTO and VALUES statement.
 -- To make sure the values appeared in the table correct, I used the SELECT * FROM statement after inserting values. After ensuring the values are correct, I used COMMIT, which saves the information.
 
 -- TABLE location, where I stored information about the 3 hotels of this hotel chain.
INSERT INTO location (location_id,location_name, address, city, state, zip, phone, url)
VALUES (location_id_seq.NEXTVAL,'South Congress','2839 South Congress Avenue','Austin','TX','78704','512-238-3849','www.southcongresshotel.com');

INSERT INTO location (location_id,location_name, address, city, state, zip, phone, url)
VALUES (location_id_seq.NEXTVAL,'East 7th Lofts','1479 North Blvd.','Eastwood','TX','78194','839-069-3018','www.eastseventhlofts.com');

INSERT INTO location (location_id,location_name, address, city, state, zip, phone, url)
VALUES (location_id_seq.NEXTVAL,'Marble Falls','7483 Summer Creek Street','Marble City','TX','78654','593-396-7728','www.marblefallshotel.com');

SELECT *
FROM location;
COMMIT;

-- TABLE features, where I stored three hotel features/amenities. - Victoria Vu vtv244
INSERT INTO features (feature_name)
VALUES ('Free Wi-Fi');

INSERT INTO features (feature_name)
VALUES ('Free Breakfast');

INSERT INTO features (feature_name)
VALUES ('Accessible Gym');

SELECT *
FROM features;
COMMIT;

-- TABLE location_features_linking, where I matched hotels to features & ensured that a hotel had mutiple features and vice versa. - Victoria Vu vtv244
INSERT INTO location_features_linking (location_id, feature_id)
VALUES (1,1);

INSERT INTO location_features_linking (location_id, feature_id)
VALUES (1,2);

INSERT INTO location_features_linking (location_id, feature_id)
VALUES (2,2);

INSERT INTO location_features_linking (location_id, feature_id)
VALUES (2,3);

INSERT INTO location_features_linking (location_id, feature_id)
VALUES (3,1);

INSERT INTO location_features_linking (location_id, feature_id)
VALUES (3,3);

SELECT *
FROM location_features_linking;
COMMIT;

-- TABLE room, where I stored room information about 2 rooms from each of the 3 locations. - Victoria Vu vtv244
INSERT INTO room (room_id, location_id, room_number, floor, room_type, square_footage, max_people, weekday_rate, weekend_rate)
VALUES (1, 1, '770', '7', 'Q', '400', '3', '2250', '2700');

INSERT INTO room (room_id, location_id, room_number, floor, room_type, square_footage, max_people, weekday_rate, weekend_rate)
VALUES (2, 1, '821', '8', 'S', '550', '5', '4000', '4500');

INSERT INTO room (room_id, location_id, room_number, floor, room_type, square_footage, max_people, weekday_rate, weekend_rate)
VALUES (5, 2, '456', '4', 'D', '450', '4', '3200', '3700');

INSERT INTO room (room_id, location_id, room_number, floor, room_type, square_footage, max_people, weekday_rate, weekend_rate)
VALUES (8, 2, '821', '8', 'Q', '410', '3', '2500', '3000');

INSERT INTO room (room_id, location_id, room_number, floor, room_type, square_footage, max_people, weekday_rate, weekend_rate)
VALUES (7, 3, '770', '7', 'C', '600', '6', '5000', '5450');

INSERT INTO room (room_id, location_id, room_number, floor, room_type, square_footage, max_people, weekday_rate, weekend_rate)
VALUES (3, 3, '821', '8', 'S', '540', '5', '4200', '4700');

SELECT *
FROM room;
COMMIT;

-- TABLE customer, where I stored information about 2 customers. - Victoria Vu vtv244
INSERT INTO customer (first_name, last_name, email, phone, address_line_1, address_line_2, city, state, zip, birthdate, stay_credits_earned, stay_credits_used)
VALUES ('Victoria', 'Vu', 'vtv244@utexas.edu', '832-777-821', '7711 Egg Street', '', 'Pearland', 'TX', '78512', date '2001-08-21', 100, 80);

INSERT INTO customer (first_name, last_name, email, phone, address_line_1, address_line_2, city, state, zip, birthdate, stay_credits_earned, stay_credits_used)
VALUES ('Mark', 'Lee', 'mjl182@utexas.edu', '182-395-1940', '1270 Watermelon Lane', '', 'Irvine', 'CA', '25166', date '1999-07-11', 90, 10);

SELECT *
FROM customer;
COMMIT;

-- TABLE customer_payment, where I stored payment information about the 2 customers earlier. - Victoria Vu vtv244
INSERT INTO customer_payment (customer_id, cardholder_first_name, cardholder_mid_name, cardholder_last_name, cardtype, cardnumber, expiration_date, cc_ID, billing_address, billing_city, billing_state, billing_zip)
VALUES (100001, 'Victoria', 'T', 'Vu', 'VISA', '8217813702948561', date '2025-05-01', '529', '7711 Egg Street', 'Pearland', 'TX', '78512');

INSERT INTO customer_payment (customer_id, cardholder_first_name, cardholder_mid_name, cardholder_last_name, cardtype, cardnumber, expiration_date, cc_ID, billing_address, billing_city, billing_state, billing_zip)
VALUES (100002, 'Mark', 'J', 'Lee', 'AMEX', '9027483761472055', date '2022-08-01', '801', '1270 Watermelon Lane', 'Irvine', 'CA', '25166');

SELECT *
FROM customer_payment;
COMMIT;

-- TABLE reservation, where I stored the earlier 2 customers' reservation. - Victoria Vu vtv244
INSERT INTO reservation (customer_ID, location_ID, confirmation_nbr, date_created, check_in_date, check_out_date, status, number_of_guests, reservation_total, discount_code, customer_rating, notes)
VALUES (100001, 3, 'N8JM1307', date '2021-02-18', date '2021-04-15', date '2021-04-17', 'C', 5, '5500', 'spring2021', 4, 'will arrive later than anticipated check-in time');

INSERT INTO reservation (customer_ID, location_ID, confirmation_nbr, date_created, check_in_date, check_out_date, status, number_of_guests, reservation_total, discount_code, customer_rating, notes)
VALUES (100002, 1, '83HRW592', sysdate, date '2021-07-29', date '2021-08-07', 'N', 3, '7000', 'summertime', '', '');

INSERT INTO reservation (customer_ID, location_ID, confirmation_nbr, date_created, check_in_date, check_out_date, status, number_of_guests, reservation_total, discount_code, customer_rating, notes)
VALUES (100002, 2, '1N27CT0D', sysdate, date '2021-10-25', date '2021-10-27', 'U', 7, '10250', 'happyhalloween', '', '');

SELECT *
FROM reservation;
COMMIT;