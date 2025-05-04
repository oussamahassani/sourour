import { DeleteOutlined } from "@ant-design/icons";
import { Badge, Button, Card, Col, Popover, Row, Typography } from "antd";
import moment from "moment";
import { Fragment, useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link, Navigate, useNavigate, useParams } from "react-router-dom";
import { toast } from "react-toastify";
import { deletePurchase } from "../../redux/actions/purchase/deletePurchaseAction";
import { loadSinglePurchase } from "../../redux/actions/purchase/detailPurchaseAction";
import CardComponent from "../Card/card.components";

import Loader from "../loader/loader";
import PageTitle from "../page-header/PageHeader";
import axios from "axios";

const DetailsPurch = () => {
	const { id } = useParams();
	let navigate = useNavigate();

	//dispatch
	const dispatch = useDispatch();
	const purchase = useSelector((state) => state.purchases.purchase);

	const onValidate = async () => {
		  try {
			await axios({
			  method: "put",
			  headers: {
				Accept: "application/json",
				"Content-Type": "application/json;charset=UTF-8",
			  },
			  url: `achat/${purchase._id}`,
			  data: {
				...purchase,validation_admin:true
			  },
			});
			return "success";
			// return data;
		  } catch (error) {
			console.log(error.message);
		  }
		  	  toast.success("Achat details is updated");
				return navigate("/purchaselist");

	}
	//Delete Supplier
	const onDelete = () => {
		try {
			dispatch(deletePurchase(id));

			setVisible(false);
			toast.warning(`Purchase : ${purchase.id} is removed `);
			return navigate("/purchaselist");
		} catch (error) {
			console.log(error.message);
		}
	};
	// Delete Supplier PopUp
	const [visible, setVisible] = useState(false);

	const handleVisibleChange = (newVisible) => {
		setVisible(newVisible);
	};

	useEffect(() => {
		dispatch(loadSinglePurchase(id));
	}, [id]);

	const isLogged = Boolean(localStorage.getItem("isLogged"));

	if (!isLogged) {
		return <Navigate to={"/auth/login"} replace={true} />;
	}

	return (
		<div>
			<PageTitle title=' Back ' />
			<div className='mr-top'>
				{purchase ? (
					<Fragment key={purchase.id}>
						<Card bordered={false} className='criclebox h-full'>
							<div className='card-header d-flex justify-content-between'>
								<h5>
									<i className='bi bi-person-lines-fill'></i>
									<span className='mr-left'>
										ID : {purchase._id} |
									</span>
								</h5>
								<div className='card-header d-flex justify-content-between'>
									<div className='me-2'>
									
										{!purchase.validation_admin && 
											<Button type='primary' shape='round' onClick={onValidate}>
												{" "}
												Validate Purchase{" "}
											</Button>
}
									
									</div>
									<div className='me-2'>
										<Popover
											content={
												<a onClick={onDelete}>
													<Button type='primary' danger>
														Yes Please !
													</Button>
												</a>
											}
											title='Are you sure you want to delete ?'
											trigger='click'
											visible={visible}
											onVisibleChange={handleVisibleChange}>
											<Button
												type='danger'
												DetailCust
												shape='round'
												icon={<DeleteOutlined />}></Button>
										</Popover>
									</div>
									
								</div>
							</div>
							<div className='card-body'>
								<Row justify='space-around'>
									<Col span={11}>
										<CardComponent title=' Initial invoice infromation '>
											<br />
											<p>
												<Typography.Text strong>
													Purchase Date :
												</Typography.Text>{" "}
												<strong>
													{moment(purchase.date_achat).format("ll")}
												</strong>
											</p>

											<p>
												<Typography.Text strong>Total Amount :</Typography.Text>{" "}
												<strong>{purchase.prix_achatTTC} </strong>
											</p>
											<p>
												<Typography.Text strong>Quantity :</Typography.Text>{" "}
												<strong>{purchase.quantité}</strong>
											</p>
											<p>
												<Typography.Text strong>TVA :</Typography.Text>{" "}
												<strong>{purchase.TVA}</strong>
											</p>

											<p>
												<Typography.Text strong>HT :</Typography.Text>{" "}
												<strong className='text-danger'>
													{" "}
													{purchase.prix_achatHT}
												</strong>
											</p>
										</CardComponent>
									</Col>
									<Col span={12}>
								
										<div className='mt-1'>
											<CardComponent>
												<p>
													<Typography.Text strong>
														Supplier Memo No :
													</Typography.Text>{" "}
													<strong>
														{purchase.id_fournisseur?.nomF}
													</strong>
												</p>

												<p>
													<Typography.Text strong>Mat :</Typography.Text>{" "}
													<strong>{purchase.id_fournisseur?.matricule}</strong>
												</p>
											</CardComponent>
										</div>
									</Col>
								</Row>
								<br />

								
							</div>
						</Card>
					</Fragment>
				) : (
					<Loader />
				)}
			</div>
		</div>
	);
};

export default DetailsPurch;
