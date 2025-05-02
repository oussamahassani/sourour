import { DETAIL_STAFF } from "../../types/UserType";

import axios from "axios";

const detailStaffAction = (data) => {
  return {
    type: DETAIL_STAFF,
    payload: data,
  };
};
export const AdminloadSingleStaff = (id) => {
  //dispatching with an call back function and returning that
  return async (dispatch) => {
    try {
      const data = await axios.get(`admin/${id}`);
      //dispatching data
      dispatch(detailStaffAction(data));
    } catch (error) {
      console.log(error.message);
    }
  };
};

export const loadSingleStaff = (id) => {
  //dispatching with an call back function and returning that
  return async (dispatch) => {
    try {
      const data = await axios.get(`user/employees/${id}`);
      //dispatching data
      dispatch(detailStaffAction(data));
    } catch (error) {
      console.log(error.message);
    }
  };
};
