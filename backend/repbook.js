const express = require('express');
const bodyParser = require('body-parser');
const crypto = require('crypto');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const app = express();
const port = 3000;
require('dotenv').config({ path: './.gitignore' }); // Use the correct relative path

app.use(bodyParser.json());

app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    next();
});

const pool = new Pool({
    user: process.env.DB_USER || "postgres",
    host: process.env.DB_HOST || "localhost",
    database: process.env.DB_NAME || "aaronmclean",
    password: process.env.DB_PASSWORD || "Apple1206",
    port: process.env.DB_PORT || 4126,
});

/**
 * @api {post} /signup User Signup
 * @apiDescription Register a new user with account and metrics data.
 * @apiBody {String} firstName User's first name.
 * @apiBody {String} lastName User's last name.
 * @apiBody {Date} dateOfBirth User's date of birth.
 * @apiBody {String} email User's email address.
 * @apiBody {String} password User's password.
 * @apiBody {String} username User's chosen username.
 * @apiBody {Number} heightCm User's height in centimeters.
 * @apiBody {Number} weightKg User's weight in kilograms.
 * @apiBody {String} gender User's gender.
 * @apiBody {String} workoutFrequency User's workout frequency.
 * @apiResponse {JSON} member_id Newly created member's ID.
 * @apiResponse {String} auth_key Authentication key for the user.
 * @apiError 400 Missing required fields.
 * @apiError 500 Internal Server Error.
 */

app.post('/signup', async (req, res) => {
    try {
        // Extract account and metrics data from the request body
        const { firstName, lastName, dateOfBirth, email, password, username, heightCm, weightKg, gender, workoutFrequency } = req.body;

        // Validate account data
        if (!firstName || !lastName || !dateOfBirth || !email || !password || !username) {
            return res.status(400).send('Missing required account fields');
        }

        // Validate metrics data
        if (!heightCm || !weightKg || !gender || !workoutFrequency) {
            return res.status(400).send('Missing required metrics fields');
        }

        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Generate a unique auth_key
        const authKey = crypto.randomBytes(20).toString('hex');

        // SQL query to insert account data
        const accountQuery = `
            INSERT INTO members (first_name, last_name, date_of_birth, email, password, username, auth_key, time_created)
            VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP)
            RETURNING member_id;
        `;
        const accountValues = [firstName, lastName, dateOfBirth, email, hashedPassword, username, authKey];

        // Execute account data insertion
        const accountResult = await pool.query(accountQuery, accountValues);
        const memberId = accountResult.rows[0].member_id;

        // SQL query to insert metrics data
        const metricsQuery = `
            INSERT INTO members_metrics (member_id, height_cm, weight_kg, gender, workout_frequency)
            VALUES ($1, $2, $3, $4, $5);
        `;
        const metricsValues = [memberId, heightCm, weightKg, gender, workoutFrequency];

        // Execute metrics data insertion
        await pool.query(metricsQuery, metricsValues);

        // Send back the member_id and auth_key
        res.status(201).json({ member_id: memberId, auth_key: authKey });
    } catch (err) {
        console.error(`Error during signup: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {post} /login User Login
 * @apiDescription Authenticate a user and provide an auth key.
 * @apiBody {String} [email] User's email address (optional, if username is provided).
 * @apiBody {String} [username] User's username (optional, if email is provided).
 * @apiBody {String} password User's password.
 * @apiResponse {JSON} member_id Authenticated member's ID.
 * @apiResponse {String} auth_key Authentication key for the user.
 * @apiError 400 Email or username is required.
 * @apiError 401 Invalid credentials.
 * @apiError 500 Internal Server Error.
 */

app.post('/login', async (req, res) => {
    try {
        const { email, username, password } = req.body;
        let query, values;

        if (email) {
            query = 'SELECT member_id, password, auth_key FROM members WHERE email = $1';
            values = [email];
        } else if (username) {
            query = 'SELECT member_id, password, auth_key FROM members WHERE username = $1';
            values = [username];
        } else {
            return res.status(400).send('Email or username is required');
        }

        const result = await pool.query(query, values);
        if (result.rows.length > 0) {
            const user = result.rows[0];
            const match = await bcrypt.compare(password, user.password);

            if (match) {
                // Return both member_id and auth_key
                res.json({ member_id: user.member_id, auth_key: user.auth_key });
            } else {
                res.status(401).send('Invalid credentials');
            }
        } else {
            res.status(401).send('Invalid credentials');
        }
    } catch (err) {
        console.error(`Error during login: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {get} /checkUsername/:username Check Username Availability
 * @apiDescription Check if a username is available for registration.
 * @apiParam {String} username Username to check for availability.
 * @apiResponse {JSON} isAvailable Boolean indicating if the username is available.
 * @apiError 500 Internal Server Error.
 */

app.get('/checkUsername/:username', async (req, res) => {
    try {
        const { username } = req.params;
        const query = 'SELECT COUNT(*) FROM members WHERE username = $1';
        const result = await pool.query(query, [username]);
        const isAvailable = result.rows[0].count === '0';
        res.json({ isAvailable });
    } catch (err) {
        console.error(`Error checking username: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {post} /exercises Add Exercises to Workout
 * @apiDescription Record a new workout for a user with specified exercises.
 * @apiBody {Number} memberId ID of the member.
 * @apiBody {Array} exerciseIds Array of exercise IDs to be included in the workout.
 * @apiResponse {JSON} workoutId ID of the newly created workout.
 * @apiError 400 Invalid input data.
 * @apiError 500 Internal Server Error.
 */


app.post('/exercises', authenticate, async (req, res) => {
    try {
        const { memberId, exerciseIds } = req.body;

        // Validate input
        if (!memberId || !exerciseIds || !Array.isArray(exerciseIds)) {
            return res.status(400).send('Invalid input data');
        }

        const query = `
            INSERT INTO workouts (member_id, exercise_ids)
            VALUES ($1, $2)
            RETURNING workout_id;
        `;
        const values = [memberId, exerciseIds];

        const result = await pool.query(query, values);
        
        res.status(201).json({ workoutId: result.rows[0].workout_id });
    } catch (err) {
        console.error(`Error during workout creation: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {post} /updateUserInfo/:memberId Update User Information
 * @apiDescription Update personal information for a specific user.
 * @apiParam {Number} memberId ID of the member whose information is to be updated.
 * @apiBody {String} firstName User's first name.
 * @apiBody {String} lastName User's last name.
 * @apiBody {Date} dateOfBirth User's date of birth.
 * @apiBody {String} email User's email address.
 * @apiBody {String} username User's username.
 * @apiResponse {String} message Success message.
 * @apiError 400 Missing required fields.
 * @apiError 500 Internal Server Error.
 */


app.post('/updateUserInfo/:memberId', authenticate, async (req, res) => {
    try {
        const { memberId } = req.params;
        const { firstName, lastName, dateOfBirth, email, username } = req.body;
        
        // Validate the input
        if (!firstName || !lastName || !dateOfBirth || !email || !username) {
            return res.status(400).send('Missing required fields');
        }

        // SQL query to update user information
        const query = `
            UPDATE members
            SET first_name = $1, last_name = $2, date_of_birth = $3, email = $4, username = $5
            WHERE member_id = $6;
        `;
        const values = [firstName, lastName, dateOfBirth, email, username, memberId];

        await pool.query(query, values);
        
        res.send('User information updated successfully');
    } catch (err) {
        console.error(`Error during updating user information: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {get} /userDataAndMetrics/:memberId Fetch User Data and Metrics
 * @apiDescription Retrieve user data and physical metrics for a specific member.
 * @apiParam {Number} memberId ID of the member.
 * @apiResponse {JSON} userData User's personal and metrics data.
 * @apiError 400 Invalid memberId.
 * @apiError 404 Member not found.
 * @apiError 500 Internal Server Error.
 */


app.get('/userDataAndMetrics/:memberId', authenticate, async (req, res) => {
    try {
      let { memberId } = req.params;
      memberId = parseInt(memberId, 10);
  
      if (isNaN(memberId)) {
        return res.status(400).send('Invalid memberId');
      }
  
      const client = await pool.connect();
      const queryText = 'SELECT first_name, last_name, date_of_birth, email, username FROM members WHERE member_id = $1';
      
      // Log the query and parameters
      console.log('Executing query:', queryText, 'with memberId:', memberId);
  
      const result = await client.query(queryText, [memberId]);
      client.release();
  
      if (result.rows.length > 0) {
        res.json(result.rows[0]);
      } else {
        res.status(404).send('Member not found');
      }
    } catch (error) {
      console.error('Error fetching user data', error);
      res.status(500).send('Internal Server Error');
    }
  });

/**
 * @api {post} /setGymMembership Set Gym Membership
 * @apiDescription Update or set gym membership details for a user.
 * @apiBody {Number} memberId ID of the member.
 * @apiBody {String} gym Name of the gym.
 * @apiBody {String} address Address of the gym.
 * @apiBody {String} membershipType Type of gym membership.
 * @apiResponse {String} message Success message.
 * @apiError 500 Internal Server Error.
 */


// Endpoint to set gym membership information for a user
app.post('/setGymMembership', authenticate, async (req, res) => {
    try {
        const { memberId, gym, address, membershipType } = req.body;

        // Check if the member_id already has gym membership data
        let checkQuery = 'SELECT * FROM gym_memberships WHERE member_id = $1';
        let checkResult = await pool.query(checkQuery, [memberId]);

        let query;
        if (checkResult.rows.length > 0) {
            // Update existing gym membership data
            query = `
                UPDATE gym_memberships
                SET gym = $2, address = $3, membership_type = $4
                WHERE member_id = $1;
            `;
        } else {
            // Insert new gym membership data
            query = `
                INSERT INTO gym_memberships (member_id, gym, address, membership_type)
                VALUES ($1, $2, $3, $4);
                VALUES ($1, $2, $3, $4);
            `;
        }
        
        // Execute the query
        await pool.query(query, [memberId, gym, address, membershipType]);
        res.send('Gym membership information updated successfully');
    } catch (err) {
        console.error(`Error during setting gym membership: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {get} /workouts/:memberId Get Workouts
 * @apiDescription Retrieve all workouts for a specific member.
 * @apiParam {Number} memberId ID of the member.
 * @apiResponse {Array} workouts Array of workout records.
 * @apiError 400 Member ID required.
 * @apiError 500 Internal Server Error.
 */

app.get('/workouts/:memberId', authenticate, async (req, res) => {
    try {
        const { memberId } = req.params;
        console.log(`Fetching workouts for memberId: ${memberId}`);

        // Validate memberId
        if (!memberId) {
            console.error('Member ID is required but not provided');
            return res.status(400).send('Member ID is required');
        }

        // SQL query to fetch workouts for the given member ID
        const query = `
            SELECT * FROM workouts
            WHERE member_id = $1;
        `;
        const values = [memberId];

        console.log(`Executing SQL query: ${query} with memberId: ${memberId}`);
        const result = await pool.query(query, values);

        console.log(`Workouts fetched successfully for memberId: ${memberId}`);
        // Send the workouts back in the response
        res.json(result.rows);
    } catch (err) {
        console.error(`Error during fetching workouts for memberId: ${req.params.memberId}, Error: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {get} /membersMetrics/:memberId Get Member's Metrics
 * @apiDescription Retrieve physical metrics data for a specific member.
 * @apiParam {Number} memberId ID of the member.
 * @apiResponse {Array} metrics Array of metric records.
 * @apiError 400 Member ID required.
 * @apiError 500 Internal Server Error.
 */

app.get('/membersMetrics/:memberId', authenticate, async (req, res) => {
    try {
        const { memberId } = req.params;

        // Validate memberId
        if (!memberId) {
            console.error('Member ID is required but not provided');
            return res.status(400).send('Member ID is required');
        }

        // SQL query to fetch metrics for the given member ID
        const query = `
            SELECT * FROM members_metrics
            WHERE member_id = $1;
        `;
        const values = [memberId];

        console.log(`Executing SQL query: ${query} with memberId: ${memberId}`);
        const result = await pool.query(query, values);

        console.log(`Metrics fetched successfully for memberId: ${memberId}`);
        // Send the metrics back in the response
        res.json(result.rows);
    } catch (err) {
        console.error(`Error during fetching metrics for memberId: ${memberId}, Error: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {post} /createWorkout/:memberId Create Workout
 * @apiDescription Create a new workout record for a member.
 * @apiParam {Number} memberId ID of the member.
 * @apiBody {String} workoutName Name of the workout.
 * @apiBody {Array} exerciseIds Array of exercise IDs included in the workout.
 * @apiResponse {String} message Success message.
 * @apiError 400 Missing required fields.
 * @apiError 500 Internal Server Error.
 */

app.post('/createWorkout/:memberId', authenticate, async (req, res) => {
    try {
        const { memberId } = req.params;
        const { workoutName, exerciseIds } = req.body;

        console.log(`Received workout creation request for memberId: ${memberId}`);
        console.log(`Workout Name: ${workoutName}, Exercise IDs: ${exerciseIds}`);

        // Validate the input
        if (!workoutName || !Array.isArray(exerciseIds) || exerciseIds.length === 0) {
            console.warn('Validation failed: Missing required fields');
            return res.status(400).send('Missing required fields');
        }

        // SQL query to insert a new workout
        const query = `
            INSERT INTO workouts (member_id, workout_name, exercise_ids)
            VALUES ($1, $2, $3);
        `;
        const values = [memberId, workoutName, exerciseIds];

        console.log('Executing query to insert new workout:', query);
        console.log('Values:', values);

        await pool.query(query, values);

        console.log('Workout created successfully for memberId:', memberId);
        res.send('Workout created successfully');
    } catch (err) {
        console.error(`Error during workout creation for memberId ${memberId}: ${err.message}`);
        res.status(500).send(err.message);
    }
});

/**
 * @api {get} /exercises Fetch Exercises
 * @apiDescription Retrieve a list of all exercises.
 * @apiResponse {Array} exercises Array of exercise records.
 * @apiError 404 No exercises found.
 * @apiError 500 Internal Server Error.
 */

app.get('/exercises', async (req, res) => {
    try {
        console.log("Fetching exercises...");

        const query = 'SELECT * FROM exercises'; // Make sure the table name is correct
        const result = await pool.query(query);
        console.log(`Query executed. Number of exercises found: ${result.rows.length}`);

        if (result.rows.length > 0) {
            res.json(result.rows);
        } else {
            console.log("No exercises found.");
            res.status(404).send('No exercises found');
        }
    } catch (err) {
        console.error(`Error fetching exercises: ${err.message}`);
        res.status(500).send(`Internal Server Error: ${err.message}`);
    }
});

async function authenticate(req, res, next) {
    try {
        const { memberId } = req.params;
        const authKey = req.header('Auth-Key'); // Assuming the authKey is sent in the header

        console.log(`Authenticating memberId: ${memberId} with authKey: ${authKey}`);

        const query = 'SELECT auth_key FROM members WHERE member_id = $1';
        const result = await pool.query(query, [memberId]);

        if (result.rows.length > 0) {
            console.log(`Stored authKey for memberId ${memberId}: ${result.rows[0].auth_key}`);
            if (result.rows[0].auth_key === authKey) {
                next(); // authKey is valid, proceed to the endpoint
            } else {
                res.status(401).send('Unauthorized: Invalid authKey');
            }
        } else {
            res.status(401).send('Unauthorized: memberId not found');
        }
    } catch (error) {
        console.error('Authentication error', error);
        res.status(500).send('Internal Server Error');
    }
}

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});