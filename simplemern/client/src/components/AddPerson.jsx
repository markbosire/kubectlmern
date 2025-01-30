import "../styles/AddPerson.css";
import axios from "axios";
import { useDispatch, useSelector } from "react-redux";
import {
  changeCurrentUpdatePerson,
  changeStatusListener,
  resetInputValues,
  updateEmailInputValue,
  updateNameInputValue,
  updatePasswordInputValue,
} from "../features/globalValues/globalSlice";
import { store } from "../store";
import { toast } from "react-toastify";

// eslint-disable-next-line no-empty-pattern
const AddPerson = ({}) => {
  const { inputValues, currentUpdatePerson } = useSelector(
    (state) => state.globalValues
  );
  const dispatch = useDispatch();

  // eslint-disable-next-line no-undef
  const apiIp = import.meta.env.VITE_API_IP;
  console.log(apiIp)
  const apiUrl = `http://${apiIp}:3000/api/v1/people`;

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (currentUpdatePerson === 0) {
      try {
        // eslint-disable-next-line no-unused-vars
        const response = await axios.post(apiUrl, inputValues);
        store.dispatch(changeStatusListener());
        store.dispatch(resetInputValues());
        toast.success("Person added to the application!");
      } catch (error) {
        console.log(error);
        toast.error(error.message);
      }
    } else {
      try {
        // eslint-disable-next-line no-unused-vars
        const response = await axios.patch(
          `${apiUrl}/${currentUpdatePerson}`,
          inputValues
        );
        store.dispatch(changeCurrentUpdatePerson({ id: 0 }));
        store.dispatch(resetInputValues());
        toast.success(
          "Person successfully updated! Please refresh to see the changes."
        );
      } catch (error) {
        toast.error(error.message);
      }
    }
  };

  return (
    <div className="add-person-main">
      <h1 className="app-title">MERN Application</h1>
      <form className="add-person-form" onSubmit={handleSubmit}>
        <input
          className="form-input"
          type="text"
          name="name"
          placeholder="Enter person's name"
          value={inputValues.name}
          onChange={(e) =>
            dispatch(updateNameInputValue({ name: e.target.value }))
          }
        />
        <input
          className="form-input"
          type="email"
          name="email"
          placeholder="Enter person's email"
          value={inputValues.email}
          onChange={(e) =>
            dispatch(updateEmailInputValue({ email: e.target.value }))
          }
        />
        <input
          className="form-input"
          type="password"
          name="password"
          placeholder="Enter person's password"
          value={inputValues.password}
          onChange={(e) =>
            dispatch(updatePasswordInputValue({ password: e.target.value }))
          }
        />
        {currentUpdatePerson === 0 ? (
          <input className="form-submit" type="submit" value="Add Person" />
        ) : (
          <input type="submit" value="Update Person" className="form-submit" />
        )}
      </form>
    </div>
  );
};

export default AddPerson;
