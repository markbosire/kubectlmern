require('dotenv').config();
require('express-async-errors');

const express = require("express");
const app = express();
const cors = require('cors');
const connectDB = require("./db/connect");
const peopleRouter = require("./routes/people");

app.use(express.json());
app.use(cors({
  origin: [`http://${process.env.IP}`, 'http://localhost:5173']
})); 

app.use("/api/v1", peopleRouter);



const port = process.env.PORT || 3000;

const start = async () => {
    try {
        const mongoURI = `mongodb://${process.env.MONGO_USERNAME}:${process.env.MONGO_PASSWORD}@${process.env.MONGO_URI}:27017`;
        
        await connectDB(mongoURI);
        app.listen(port, () => {
            console.log("Server is listening on port " + port);
             console.log("frontend ip is " + process.env.IP);
        });
    } catch (error) {
        console.log("MongoDB URI:", mongoURI);
        console.log(error);
    }
}

start();
