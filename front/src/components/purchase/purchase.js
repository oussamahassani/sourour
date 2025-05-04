import PageTitle from "../page-header/PageHeader";

import { Navigate } from "react-router-dom";

const Purchase = (props) => {
	const isLogged = Boolean(localStorage.getItem("isLogged"));

	if (!isLogged) {
		return <Navigate to={"/auth/login"} replace={true} />;
	}
	return (
		<div>
			<PageTitle title='Back' />

		</div>
	);
};

export default Purchase;
