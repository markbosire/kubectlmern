const express = require("express");
const router = express.Router();

const { getAllPeople, addPerson, getPerson, updatePerson, deleteJob } = require("../controllers/people");

router.route("/people").get(getAllPeople).post(addPerson);
router.route("/people/:id").get(getPerson).patch(updatePerson).delete(deleteJob);

module.exports = router;