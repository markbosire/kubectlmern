const Person = require("../models/Person");

const getAllPeople = async (req, res) => {
    const people = await Person.find({});
    res.status(200).json({ people, count: people.length });
  };

  const addPerson = async (req,res) => {
    const people = await Person.create(req.body);
    res.status(201).json({ people });
  }

  const getPerson = async (req, res) => {

    const { id: personID } = req.params

    const person = await Person.findOne({
      _id: personID
    });
    if (!person) {
      res.status(404).json({ msg: `Person with ${personID} doesn't exist` });
    }
    return res.status(200).json({ person });
    
  };

  const updatePerson = async (req, res) => {
    const {
      body: { name, email },
      params: { id: personID },
    } = req
  
    if (name === '' || email === '') {
      return res.status(400).json({msg: "Bad request error. Please add values to all fields"});
    }
    const person = await Person.findByIdAndUpdate(
      { _id: personID },
      req.body,
      { new: true, runValidators: true }
    )
    if (!person) {
      return res.status(404).json({msg: `No person with id ${id}. Please enter valid id`});
    }
    return res.status(200).json({ person });
  }

  const deleteJob = async (req, res) => {
    const {
      params: {id: personID}
    } = req;
    
    const person = await Person.findOneAndDelete({ _id: personID });
  
    if (!person) {
      return res.status(404).json({msg: `No person with id ${id} found`})
    }
    res.status(200).send();
  };


  module.exports = {
    getAllPeople,
    addPerson,
    getPerson,
    updatePerson,
    deleteJob
  }