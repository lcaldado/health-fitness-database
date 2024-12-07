CREATE DATABASE health_and_fitness;
USE health_and_fitness;
-- User table
CREATE TABLE user (
user_id INT AUTO_INCREMENT PRIMARY KEY,
mail VARCHAR(64) NOT NULL,
first_name VARCHAR(32),
last_name VARCHAR(32),
age INT ,
gender ENUM('female','male','other'),
height DECIMAL(5,2),
weight DECIMAL(5,2));

-- Health Test table
CREATE TABLE health_test (
test_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
body_fat DECIMAL(5,2) NOT NULL,
heart_rate INT NOT NULL,
blood_pressure INT NOT NULL,
date DATE NOT NULL,
FOREIGN KEY (user_id) REFERENCES user(user_id) ON UPDATE CASCADE ON DELETE CASCADE);

-- Workout table
CREATE TABLE workout (
workout_id INT AUTO_INCREMENT PRIMARY KEY,
duration INT, -- duration is measured in minutes
calories_burned INT);

-- Relationship table between workout and user
CREATE TABLE user_practices_workout(
user_id INT,
workout_id INT,
PRIMARY KEY (user_id,workout_id),
FOREIGN KEY (user_id) REFERENCES user(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (workout_id) REFERENCES workout(workout_id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Exercise {MANDATORY,OR} table
CREATE TABLE exercise(
exercise_name VARCHAR(32) PRIMARY KEY,
type_exercise ENUM('cardio','strength') NOT NULL,
distance DECIMAL(4,2) ,
velocity DECIMAL(3,1) ,
resistance INT,
machine BOOL,
material VARCHAR(32),
reps INT,
sets INT,
weight DECIMAL(5,2),
CONSTRAINT type_contraint CHECK (
	(type_exercise='cardio' AND distance != NULL AND velocity != NULL AND resistance != NULL)
    OR
    (type_exercise='strength' AND machine != NULL AND reps != NULL AND sets!= NULL AND weight!= NULL)
)
);

-- Relationship table between workout and exercises
CREATE TABLE workout_exercise(
workout_id INT,
exercise_name VARCHAR(32),
PRIMARY KEY (workout_id,exercise_name),
FOREIGN KEY (workout_id) REFERENCES workout(workout_id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (exercise_name) REFERENCES exercise(exercise_name) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Goal table
CREATE TABLE goal(
goal_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
type VARCHAR(32) NOT NULL,
target_value INT,
start_date DATE NOT NULL,
target_date DATE,
status ENUM('in progress','finished','not started'),
FOREIGN KEY (user_id) REFERENCES user(user_id) ON UPDATE CASCADE ON DELETE CASCADE);

-- Meal table
CREATE TABLE meal(
meal_id INT AUTO_INCREMENT PRIMARY KEY,
goal_id INT NOT NULL,
user_id INT NOT NULL,
meal_date DATE NOT NULL,
meal_type VARCHAR(32) ,
calories INT NOT NULL,
protein DECIMAL(4,2),
carbs DECIMAL(4,2),
fat DECIMAL(4,2),
FOREIGN KEY (goal_id) REFERENCES goal(goal_id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (user_id) REFERENCES user(user_id) ON UPDATE CASCADE ON DELETE CASCADE);

-- PROCEDURE to create a new user
DELIMITER //
CREATE PROCEDURE create_user (IN mail_p VARCHAR(64) ,
IN first_name_p VARCHAR(32),
IN last_name_p VARCHAR(32),
IN age_p INT ,
IN gender_p ENUM('female','male','other'),
IN height_p DECIMAL(5,2),
IN weight_p DECIMAL(5,2))
BEGIN
	DECLARE exist_mail INT ;
    SELECT COUNT(*) INTO exist_mail FROM user WHERE mail=mail_p ;
    IF exist_mail !=0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'mail already associated to an user';
	ELSEIF mail_p IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'introduce a mail';
	ELSE 
        INSERT INTO user( mail, first_name , last_name , age, gender, height , weight)
			VALUES ( mail_p , first_name_p , last_name_p , age_p , gender_p , height_p , weight_p) ;
	END IF ;
END //
DELIMITER ;

-- FUNCTION to see if an user id exists
DELIMITER //
CREATE FUNCTION check_valid_id (user_id_p INT) RETURNS BOOL DETERMINISTIC
BEGIN
	DECLARE exist_id INT ;
    SELECT COUNT(*) INTO exist_id FROM user WHERE user_id=user_id_p;
    IF exist_id=0 THEN
		RETURN False;
	ELSE
		RETURN True;
	END IF ;
END//
DELIMITER ;


-- PROCEDURE to add goal
DELIMITER //
CREATE PROCEDURE add_goal( IN user_id_p INT,
IN type_p VARCHAR(32) ,
IN target_value_p INT,
IN start_date_p DATE,
IN target_date_p DATE,
IN status_p ENUM('in progress','finished','not started'))
BEGIN
    INSERT INTO goal (user_id,type, target_value, start_date , target_date, status) 
    VALUES (user_id_p , type_p , target_value_p , start_date_p , target_date_p , status_p);
END //
DELIMITER ;


-- PROCEDURE to track health test
DELIMITER //
CREATE PROCEDURE track_health_test ( IN user_id_p INT ,
IN body_fat_p DECIMAL(5,2) ,
IN heart_rate_p INT ,
IN blood_pressure_p INT ,
IN date DATE )
BEGIN
    INSERT INTO health_test (user_id , body_fat ,heart_rate ,blood_pressure , date )
		VALUES (user_id_p, body_fat_p , heart_rate_p , blood_pressure_p , date_p) ; 
END //
DELIMITER ;

-- PROCEDURE to track meal
DELIMITER //
CREATE PROCEDURE track_meal ( IN goal_id_p INT ,
IN user_id_p INT,
IN meal_date_p DATE,
IN meal_type_p VARCHAR(32) ,
IN calories_p INT ,
IN protein_p DECIMAL(4,2),
IN carbs_p DECIMAL(4,2),
IN fat_p DECIMAL(4,2))
BEGIN
	DECLARE exist_goal INT;
    SELECT COUNT(*) INTO exist_goal FROM goal WHERE goal_id=goal_id_p;
    IF exist_goal = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT= 'unvalid goal';
	ELSE 
        INSERT INTO meal (goal_id,user_id, meal_date, meal_type, calories, protein, carbs, fat)
			VALUES (goal_id_p ,user_id_p , meal_date_p , meal_type_p , calories_p, protein_p, carbs_p, fat_p);
	END IF;
    
END //
DELIMITER ;

-- PROCEDURE to add workout
DELIMITER //
CREATE PROCEDURE add_workout (IN user_id_p INT ,
IN duration_p INT, 
IN calories_burned_p INT)
BEGIN
	DECLARE last_workout INT;
	-- we have to add new workout to workout table
    INSERT INTO workout(duration, calories_burned)
		VALUES (duration_p , calories_burned_p) ; 
    -- we have to add new workout-user relationship into user_practices_workout table
    SELECT workout_id INTO last_workout FROM workout ORDER BY workout_id DESC LIMIT 1;
    INSERT INTO user_practices_workout ( user_id , workout_id ) 
		VALUES (user_id_p ,last_workout);
END//
DELIMITER ;

-- PROCEDURE to edit workout
DELIMITER //
CREATE PROCEDURE edit_workout ( IN workout_id_p INT,
IN new_duration INT,
IN new_calories_burned INT )
BEGIN
	DECLARE exist_workout INT ;
    SELECT COUNT(*) INTO exist_workout FROM workout WHERE workout_id = workout_id_p;
    IF exist_workout != 0 THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'workout does not exist';
	ELSE 
		UPDATE workout SET duration = new_duration , calories_burned = new_calories_burned WHERE workout_id=workout_id_p ; 
	END IF ;
END //
DELIMITER ;

-- trigger to no update workout if new values for duration and calories burned are the same as the old ones
DELIMITER //
CREATE TRIGGER before_updte_workout BEFORE UPDATE ON workout FOR EACH ROW
BEGIN
	IF NEW.duration = OLD.duration AND NEW.calories_burned = OLD.calories_burned THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No changes in workout. Update not performed' ;
	END IF ;
END //
DELIMITER ;

-- PROCEDURE to add exercise 
DELIMITER //
CREATE PROCEDURE add_exercise ( IN exercise_name_p VARCHAR(32) ,
IN workout_p INT ,
IN type_exercise_p ENUM('cardio','strength') ,
IN distance_p DECIMAL(4,2) ,
IN velocity_p DECIMAL(3,1) ,
IN resistance_p INT,
IN machine_p BOOL,
IN material_p VARCHAR(32),
IN reps_p INT,
IN sets_p INT,
IN weight_p DECIMAL(5,2) )
BEGIN
	DECLARE exist_exercise INT;
	-- let's see first if exercise it is already created
    SELECT COUNT(*) INTO exist_exercise FROM exercise WHERE exercise_name=exercise_name_p ;
    IF exist_exercise = 0 THEN
		INSERT INTO exercise(exercise_name,type_exercise,distance,velocity, resistance, machine , material,reps ,sets , weight)
			VALUES (exercise_name_p,type_exercise_p,distance_p,velocity_p, resistance_p, machine_p , material_p,reps_p ,sets_p , weight_p) ;
	END IF ;
END// 
DELIMITER ;

-- PROCEDURE to add exercise to a workout
DELIMITER //
CREATE PROCEDURE new_exercise_in_workout(IN exercise_name_p VARCHAR(32),IN workout_id_p INT)
BEGIN
	DECLARE exist_exercise INT;
    SELECT COUNT(*) INTO exist_exercise FROM exercise WHERE exercise_name=exercise_name_p ;
    IF exist_exercise = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Exercise does not exist';
	ELSE 
		INSERT INTO workout_exercise (workout_id,exercise_name) 
			VALUES(workout_id_p,exercise_name_p);
	END IF;
END//
DELIMITER ;

-- create trigger to see if exercise is on workout already
DELIMITER //
CREATE TRIGGER before_insert_exercise BEFORE INSERT ON workout_exercise FOR EACH ROW
BEGIN
	DECLARE exist_exercise_in_wk INT;
    SELECT COUNT(*) INTO exist_exercise_in_wk FROM workout_exercise WHERE workout_id= NEW.workout_id AND exercise_name=NEW.exercise_name ;
    IF exist_exercise_in_wk != 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'exercise already in workout. Insertion not performed';
	END IF ;
END //
DELIMITER ;
