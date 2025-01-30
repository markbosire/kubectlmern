import { createSlice } from "@reduxjs/toolkit";
import { createAsyncThunk } from "@reduxjs/toolkit";
import axios from "axios";

export const fetchPerson = createAsyncThunk(
  "people/fetchPerson",
  async (data) => {
    const response = await axios(
      `http://localhost:3000/api/v1/people/${data.person._id}`
    );

    return response.data;
  }
);
const initialState = {
  inputValues: { name: "", email: "", password: "" },
  statusListener: false,
  currentUpdatePerson: 0,
};

const globalSlice = createSlice({
  name: "globalValues",
  initialState,
  reducers: {
    resetInputValues: (state) => {
      state.inputValues = { name: "", email: "", password: "" };
    },
    updateNameInputValue: (state, action) => {
      state.inputValues.name = action.payload.name;
    },
    updateEmailInputValue: (state, action) => {
      state.inputValues.email = action.payload.email;
    },
    updatePasswordInputValue: (state, action) => {
      state.inputValues.password = action.payload.password;
    },
    changeStatusListener: (state) => {
      state.statusListener = !state.statusListener;
    },
    changeCurrentUpdatePerson: (state, action) => {
      state.currentUpdatePerson = action.payload.id;
    },
  },

  extraReducers: (builder) => {
    builder
      .addCase(fetchPerson.pending, (state) => {})
      .addCase(fetchPerson.fulfilled, (state, action) => {
        state.currentUpdatePerson = action.payload.person._id;
        state.inputValues.name = action.payload.person.name;
        state.inputValues.email = action.payload.person.email;
        state.inputValues.password = action.payload.person.password;
      })
      .addCase(fetchPerson.rejected, (state, action) => {});
  },
});

// console.log(cartSlice);
export const {
  resetInputValues,
  updateNameInputValue,
  updateEmailInputValue,
  updatePasswordInputValue,
  changeStatusListener,
  changeCurrentUpdatePerson,
} = globalSlice.actions;

export default globalSlice.reducer;
