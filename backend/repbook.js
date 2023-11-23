const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const app = express();
const port = 3000;
require('dotenv').config();

// Use body-parser middleware to parse JSON body
app.use(bodyParser.json());

app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    next();
});

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
});

// Login endpoint
app.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        console.log(`Received login request: `, req.body);

        // Query the database for a user with the provided email
        const query = 'SELECT member_id, password FROM members WHERE email = $1';
        console.log(`Executing query: ${query} with email: ${email}`);
        const values = [email];
        const result = await pool.query(query, values);
        console.log(`Query result: `, result.rows);

        if (result.rows.length > 0) {
            const user = result.rows[0];
            const match = await bcrypt.compare(password, user.password);
            console.log(`Password match: ${match}`);

            if (match) {
                res.json({ member_id: user.member_id });
            } else {
                res.status(401).send('Invalid email or password');
            }
        } else {
            res.status(401).send('Invalid email or password');
        }
    } catch (err) {
        console.error(`Error during login: ${err.message}`);
        res.status(500).send(err.message);
    }
});

app.get('/userDataAndMetrics/:memberId', async (req, res) => {
    try {
        const memberId = req.params.memberId;
        console.log(`Fetching data for member ID: ${memberId}`);

        // Query to get user data from members table
        let query = 'SELECT first_name, last_name, date_of_birth FROM members WHERE member_id = $1';
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


// Signup endpoint
app.post('/signup', async (req, res) => {
    try {
        const { firstName, lastName, dateOfBirth, email, password } = req.body;
        console.log(`Received signup request: `, req.body);

        const hashedPassword = await bcrypt.hash(password, 10);
        const query = `INSERT INTO members (first_name, last_name, date_of_birth, email, password, time_created) VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP) RETURNING member_id;`;
        const values = [firstName, lastName, dateOfBirth, email, hashedPassword];
        console.log(`Executing query: ${query} with values: `, values);

        const result = await pool.query(query, values);
        console.log(`Signup query result: `, result.rows);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(`Error during signup: ${err.message}`);
        res.status(500).send(err.message);
    }
});

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
