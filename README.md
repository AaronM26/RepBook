dbms3005 final assignment 
Aaron Mclean
101226419
December 10th 2023

YOUTUBE VIDEO: https://youtu.be/9mxV7FEH1j8 

INSTALL AND SETUP 

    bash
    git clone https://github.com/AaronM26/RepBook.git
    cd RepBook
    Setup Backend
    bash
    Copy code
    cd backend
    npm install
    update env variables
    node repbook.js
    Setup Frontend
    Open RepBook.xcodeproj in Xcode.
    Run the project in a simulator

API ENDPOINTS

    /api/signup                        POST    User Signup
    /api/login                         POST    User Login
    /api/checkUsername/:username       GET     Check Username Availability
    /api/exercises                     POST    Add Exercises to Workout
    /api/updateUserInfo/:memberId      POST    Update User Information
    /api/userDataAndMetrics/:memberId  GET     Fetch User Data and Metrics
    /api/setGymMembership              POST    Set Gym Membership
    /api/workouts/:memberId            GET     Get Workouts
    /api/membersMetrics/:memberId      GET     Get Member's Metrics
    /api/createWorkout/:memberId       POST    Create Workout
    /api/exercises                     GET     Fetch Exercises


PROJECT OUTLINE

    GOAL: Make an app for users to be able to make and store workouts made of up sets of exersizes, and store user preferences that are useful for an LLM API to genereate better workouts for the user. 

        Store personal information of gym members (members table).

        Manage administrative staff details (admin_staff table).

        Implement unique identification for both members and staff using member_id and staff_id.

        Store emails and passwords for both members and staff, ensuring uniqueness of emails.

        Catalog a list of exercises (exercises table) with details like muscle groups, difficulty, and duration.

        Track specific workouts (workouts table) and associate them with various exercises using a junction table to comply with 2nf and 3nf.

        Record members' physical metrics over time (members_metrics table), including height, weight, and workout frequency.
        
        Track personal records in exercises like bench press, squat, and deadlift (pr_tracker table).

        Manage nutrition plans (nutrition_plans table) with details on caloric intake, macronutrient targets, and meal timings.
        Achievements and Goals Tracking

        Keep a record of fitness achievements and milestones for members (fitness_achievements table).

        Manage gym membership details (gym_memberships table), linking members to specific gym locations and addresses.

        Allow personalized workout plans (user_workout_plans table) with preferences on intensity, duration, focus area, and frequency.
        Data Integrity and Normalization

MODELS: 

    /ER_model.png
    /DB_Schema.png
    
NORMAL FORMS

    1NF (First Normal Form)
        Each table has a primary key.
        All attributes contain atomic (indivisible) values.

        Primary Keys: Each table in your database has a primary key, as evidenced by the PRIMARY KEY constraint in their definitions.
        Atomic Values: All attributes in your tables appear to store atomic values. There are no repeating groups or arrays, and each column holds a single piece of data of a consistent type.

    2NF (Second Normal Form)
        All non-key attributes are fully functionally dependent on the primary key.

        Full Functional Dependency: In each table, the non-key attributes are fully functionally dependent on the primary key. For example, in the members table, attributes like first_name, last_name, email, etc., are all dependent on member_id and not on any subset of it.

    3NF (Third Normal Form)
        No transitive dependency exists between non-key attributes and the primary key.

        There are no attributes that are transitively dependent on the primary key through another non-key attribute. Each attribute is directly dependent on the primary key. For example, in the nutrition_plans table, daily_calories, protein_target, etc., are directly dependent on member_id and not through another non-key attribute.
        Thus, based on the structure and definitions of your tables, your database appears to be in compliance with the 1NF, 2NF, and 3NF normalization forms. Each table maintains a primary key, attributes are atomic, non-key attributes are fully functionally dependent on their respective primary keys, and there are no transitive dependencies between non-key attributes and primary keys.

10 SQL COMMANDS FROM NODE ENDPOINT
    Account Data Insertion Query:
        INSERT INTO members (first_name, last_name, date_of_birth, email, password, time_created)
        VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)
        RETURNING member_id;

    Metrics Data Insertion Query:
        INSERT INTO members_metrics (member_id, height_cm, weight_kg, gender, workout_frequency)
        VALUES ($1, $2, $3, $4, $5);
        Login Endpoint (/login):

    User Authentication Query:
        SELECT member_id, password, auth_key FROM members WHERE email = $1

    Username Availability Check Query:
        SELECT COUNT(*) FROM members WHERE username = $1

    Insert Workout Query:
        INSERT INTO workouts (member_id, exercise_ids)
        VALUES ($1, $2)
        RETURNING workout_id;

    Update User Information Query:
        UPDATE members
        SET first_name = $1, last_name = $2, date_of_birth = $3, email = $4, username = $5
        WHERE member_id = $6;

    Fetch User Data Query:
        SELECT first_name, last_name, date_of_birth, email, username FROM members WHERE member_id = $1

    Check Gym Membership Query:
        SELECT * FROM gym_memberships WHERE member_id = $1
    
    Update Gym Membership Query:
        UPDATE gym_memberships
        SET gym = $2, address = $3, membership_type = $4
        WHERE member_id = $1;
    
    Insert Gym Membership Query:
        INSERT INTO gym_memberships (member_id, gym, address, membership_type)
        VALUES ($1, $2, $3, $4);

    Fetch Workouts Query:
        SELECT * FROM workouts
        WHERE member_id = $1;

    Fetch Metrics Query:
        SELECT * FROM members_metrics
        WHERE member_id = $1;

    Insert New Workout Query:
        INSERT INTO workouts (member_id, workout_name, exercise_ids)
        VALUES ($1, $2, $3);
