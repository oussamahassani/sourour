import { Bar } from "@ant-design/plots";

import { useSelector } from "react-redux";

const DemoBar = () => {
	const data = useSelector((state) => state.dashboard.list?.UserInfo);


	return (

		<table class="table">
			<thead>
				<tr>
					<th scope="col">#</th>
					<th scope="col">User name</th>
					<th scope="col">Role</th>

				</tr>
			</thead>
			<tbody>
				{data &&
					data.map((el, index) => {
						return (
							<tr key={index}>
								<th scope="row">{index}</th>
								<td>{el.label}</td>
								<td>{el.role}</td>

							</tr>
						)
					})
				}


			</tbody>
		</table>
	)
};

export default DemoBar;
