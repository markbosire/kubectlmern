import { useState } from "react";
import { AddPerson, PersonList } from "./components";
import { ToastContainer, toast } from 'react-toastify';


function App() {

  const [ currentUpdatePerson, setCurrentUpdatePerson ] = useState(0);

  return (
    <div className="container-main">
      <AddPerson currentUpdatePerson={currentUpdatePerson} setCurrentUpdatePerson={setCurrentUpdatePerson} />
      <PersonList currentUpdatePerson={currentUpdatePerson} setCurrentUpdatePerson={setCurrentUpdatePerson} />
      <ToastContainer position='top-center' />
    </div>
  )
}

export default App
