import { Card } from "antd";
import moment from "moment";
import React, { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useParams } from "react-router-dom";
import { loadSingleAccount } from "../../redux/actions/account/detailAccountAction";

import Loader from "../loader/loader";
import PageTitle from "../page-header/PageHeader";
import UpdateAccount from "./updateAccount";

const DetailAccount = () => {
	// const [data, setData] = useState(null);
	const data = useSelector((state) => state.accounts.intervention);
	const { id } = useParams("id");
	const dispatch = useDispatch();
	//make a use effect to get the data from the getTrailBalance function
	useEffect(() => {
		// getSubAccount(id).then((data) => {
		// 	setData(data);
		// });
		dispatch(loadSingleAccount(id));
	}, []);

	return (
		<>
			<PageTitle title={"Back"} />
			<br />
			<Card>
				{data ? (
					<div className='card-custom card-body'>
						<div className='card-title d-flex justify-content-between'>
							<h5>
								<i className='bi bi-card-list'>
									<span className='ms-2'> Intervention Details: {data.name}</span>{" "}
								</i>
							</h5>
							<UpdateAccount account={data} id={id} />
						</div>
						<table className='table detail-account-table'>
							<thead className='thead-dark'>
								<tr>
									<th scope='col'>technicianName</th>
									<th scope='col'>time</th>
									<th scope='col'> interventionType</th>
									<th scope='col'> Date</th>
								</tr>
							</thead>
							<tbody>
							
											<tr>
												<td>{data.technicianName}</td>
												<td>{data.time}</td>
												<td>{data.interventionType}</td>
												<td>{moment(data.date).format("YYYY-MM-DD")}</td>
											</tr>
											</tbody>
											</table>
											<table className='table detail-account-table'>
							<thead className='thead-dark'>
								<tr>
								
									<th scope='col'>reference</th>
									<th scope='col'> description</th>
									<th scope='col'> actionsTaken</th>
								</tr>
							</thead>
							<tbody>
											<tr>
												<td>{data.reference}</td>
												<td>{data.description}</td>
												<td>{data.actionsTaken}</td>
											</tr>
							

								{data && (
									<tr className='text-center'>
										<td colspan='2' class='table-active '>
											<strong>clientSatisfied</strong>
										</td>
										<td>
											<strong>{data?.clientSatisfied ? "Client satisfait" : "Non satisfait"}</strong>
										</td>
									</tr>
								)}
							</tbody>
						</table>
					</div>
				) : (
					<Loader />
				)}
			</Card>
		</>
	);
};

export default DetailAccount;
