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
    Primary Keys: Each table in the database has a defined primary key. For instance, the members table uses member_id as the primary key, ensuring each record is uniquely identifiable.
    Atomic Values: Every attribute in each table holds atomic, indivisible values. Take the exercises table as an example; attributes like name, muscle_group, and difficulty each store a single, indivisible piece of data, adhering to the 1NF requirement.

    2NF (Second Normal Form)
    Full Functional Dependency: In each table, the non-key attributes are fully functionally dependent on the primary key, and not on any subset of the primary key. In the gym_memberships table, the attributes gym and address depend entirely on member_id for their context and meaning, satisfying the 2NF condition.

    3NF (Third Normal Form)
    No Transitive Dependency: Tables show no signs of transitive dependencies where non-key attributes depend on other non-key attributes. For example, in the nutrition_plans table, the attributes like daily_calories, protein_target, etc., are directly dependent on member_id and not on any other non-key attribute, confirming adherence to 3NF.
    
    

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
