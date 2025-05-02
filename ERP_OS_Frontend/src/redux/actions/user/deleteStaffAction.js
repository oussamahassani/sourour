import { DELETE_STAFF } from "../../types/UserType";
import axios from "axios";

const deleteStaffAction = (id) => {
	return {
		type: DELETE_STAFF,
		payload: id,
	};
};

export const AdmindeleteStaff = (id) => {
	//dispatching with an call back function and returning that
	return async (dispatch) => {
		try {
			await axios({
				method: "delete",
				headers: {
					Accept: "application/json",
					"Content-Type": "application/json;charset=UTF-8",
				},
				url: `admin/${id}`,
				data: {
					status: false,
				},
			});
			//dispatching data
			dispatch(deleteStaffAction(id));
		} catch (error) {
			console.log(error.message);
		}
	};
}
export const deleteStaff = (id) => {
	//dispatching with an call back function and returning that
	return async (dispatch) => {
		try {
			await axios({
				method: "delete",
				headers: {
					Accept: "application/json",
					"Content-Type": "application/json;charset=UTF-8",
				},
				url: `user/employees/${id}`,
				data: {
					status: false,
				},
			});
			//dispatching data
			dispatch(deleteStaffAction(id));
		} catch (error) {
			console.log(error.message);
		}
	};
};
