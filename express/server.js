const express = require("express");
const axios = require("axios");

const app = express();

// Replace with Flask private IP (for Part 2)
 const FLASK_URL = process.env.FLASK_URL || "http://localhost:5000";
//
app.get("/", async (req, res) => {
   try {
       const response = await axios.get(`${FLASK_URL}/api/data`);
           res.send(`
                 <h1>Express Frontend 🚀</h1>
                       <p>Backend Data:</p>
                             <pre>${JSON.stringify(response.data, null, 2)}</pre>
                                 `);
                                   } catch (error) {
                                       res.send("Error connecting to Flask backend");
                                         }
                                         });

                                         app.listen(3000, () => {
                                           console.log("Express running on port 3000");
                                           });
