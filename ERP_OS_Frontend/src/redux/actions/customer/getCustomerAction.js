import { CUSTOMERS } from "../../types/CustomerType";
import axios from "axios";

const getCustomer = (data) => {
	return {
		type: CUSTOMERS,
		payload: data,
	};
};

export const loadAllCustomer = ({ page, limit, status }) => {
	//dispatching with an call back function and returning that
	return async (dispatch) => {
		try {
			const { data } = await axios.get(
				`clients?status=${status}&page=${page}&count=${limit}`
			);
			console.log(data)
			//dispatching data
			dispatch(getCustomer(data.clients));
		} catch (error) {
			console.log(error.message);
		}
	};
};
