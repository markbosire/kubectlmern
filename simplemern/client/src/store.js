import { configureStore } from "@reduxjs/toolkit";
import cartReducer from "./features/globalValues/globalSlice";


export const store = configureStore({
  reducer: {
    globalValues: cartReducer,
  },
});