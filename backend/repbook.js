const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const app = express();
const port = 3000;
require('dotenv').config({ path: './.gitignore' }); // Use the correct relative path

// Use body-parser middleware to parse JSON body
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

app.post('/login', async (req, res) => {
    try {
        const { email, username, password } = req.body;
        console.log(`Received login request: `, req.body);

        let query, values;

        // Determine whether to use email or username for login
        if (email) {
            query = 'SELECT member_id, password FROM members WHERE email = $1';
            values = [email];
        } else if (username) {
            query = 'SELECT member_id, password FROM members WHERE username = $1';
            values = [username];
        } else {
            return res.status(400).send('Email or username is required');
        }

        console.log(`Executing query: ${query} with value: ${values[0]}`);
        const result = await pool.query(query, values);
        console.log(`Query result: `, result.rows);

        if (result.rows.length > 0) {
            const user = result.rows[0];
            const match = await bcrypt.compare(password, user.password);
            console.log(`Password match: ${match}`);

            if (match) {
                res.json({ member_id: user.member_id });
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

// Check if username is available
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


app.get('/userDataAndMetrics/:memberId', async (req, res) => {
    try {
        const memberId = req.params.memberId;
        console.log(`Fetching data for member ID: ${memberId}`);

        // Include email in the SELECT query
        let query = 'SELECT first_name, last_name, date_of_birth, email, username FROM members WHERE member_id = $1';
        let values = [memberId];
        let result = await pool.query(query, values);

        if (result.rows.length === 0) {
            res.status(404).send('Member not found');
            return;
        }

        let userData = result.rows[0];

        // Query to get metrics data
        query = 'SELECT height_cm, weight_kg, bench_max_kg, squat_max_kg, bmi FROM metrics WHERE member_id = $1';
        result = await pool.query(query, values);

        let metricsData = result.rows[0] || {};

        // Combine user data and metrics into a single object
        const userInfo = {
            firstName: userData.first_name,
            lastName: userData.last_name,
            dateOfBirth: userData.date_of_birth,
            email: userData.email,  // Add email here
            username: userData.username,
            memberId: parseInt(memberId),
            heightCm: metricsData.height_cm || 0,
            weightKg: metricsData.weight_kg || 0,
            benchMaxKg: metricsData.bench_max_kg || 0,
            squatMaxKg: metricsData.squat_max_kg || 0,
            bmi: metricsData.bmi || 0
        };

        res.json(userInfo);
    } catch (err) {
        console.error(`Error fetching user data and metrics: ${err.message}`);
        res.status(500).send(err.message);
    }
});


app.post('/signup', async (req, res) => {
    try {
        const { firstName, lastName, dateOfBirth, email, password, username } = req.body;
        console.log(`Received signup request: `, req.body);

        const hashedPassword = await bcrypt.hash(password, 10);
        const query = `
            INSERT INTO members (first_name, last_name, date_of_birth, email, password, username, time_created)
            VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP)
            RETURNING member_id;
        `;
        const values = [firstName, lastName, dateOfBirth, email, hashedPassword, username];
        console.log(`Executing query: ${query} with values: `, values);

        const result = await pool.query(query, values);
        console.log(`Signup query result: `, result.rows);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(`Error during signup: ${err.message}`);
        res.status(500).send(err.message);
    }
});

// Endpoint to set gym membership information for a user
app.post('/setGymMembership', async (req, res) => {
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

// Endpoint to fetch all workouts
app.get('/workouts', async (req, res) => {
    try {
        const query = 'SELECT * FROM workouts'; // Adjust if you have a different table name
        const result = await pool.query(query);

        if (result.rows.length > 0) {
            res.json(result.rows);
        } else {
            res.status(404).send('No workouts found');
        }
    } catch (err) {
        console.error(`Error fetching workouts: ${err.message}`);
        res.status(500).send(err.message);
    }
});

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
