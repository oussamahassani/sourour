import { DeleteOutlined } from "@ant-design/icons";
import { Badge, Button, Card, Col, Popover, Row, Typography } from "antd";
import { Fragment, useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link, Navigate, useNavigate, useParams } from "react-router-dom";
import { toast } from "react-toastify";
import CardComponent from "../Card/card.components";
import Loader from "../loader/loader";
import PageTitle from "../page-header/PageHeader";

import { loadSingleSale } from "../../redux/actions/sale/detailSaleAction";

import { deleteSale } from "../../redux/actions/sale/deleteSaleAction";


import moment from "moment";
//PopUp

const DetailSale = () => {
	const { id } = useParams();
	let navigate = useNavigate();

	//dispatch
	const dispatch = useDispatch();
	const sale = useSelector((state) => state.sales.sale);
	

	//Delete Customer
	const onDelete = () => {
		try {
			dispatch(deleteSale(id));

			setVisible(false);
			toast.warning(`Sale : ${sale.id} is removed `);
			return navigate("/salelist");
		} catch (error) {
			console.log(error.message);
		}
	};
	// Delete Customer PopUp
	const [visible, setVisible] = useState(false);

	const handleVisibleChange = (newVisible) => {
		setVisible(newVisible);
	};

	useEffect(() => {
		dispatch(loadSingleSale(id));
	}, [id]);

	const isLogged = Boolean(localStorage.getItem("isLogged"));

	if (!isLogged) {
		return <Navigate to={"/auth/login"} replace={true} />;
	}

	return (
		<div>
			<PageTitle title='Back' />

			<div className='mr-top'>
				{sale ? (
					<Fragment key={sale._id}>
						<Card bordered={false} className='card-custom'>
							<h5 className='m-2'>
								<i className='bi bi-person-lines-fill'></i>
								<span className='mr-left'>ID : {sale._id} |</span>
							</h5>
							<div className='card-header d-flex justify-content-center '>
								<div className='me-2'>
										<Button type='primary' shape='round'>
											{" "}
											Validate Payement{" "}
										</Button>
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
							<div className='card-body'>
								<Row justify='space-around'>
									<Col span={11}>
										<CardComponent title='Initial Invoice Information '>
											<div className='d-flex justify-content-between'>
												<div>
													<p>
														<Typography.Text strong>
															Payements Date :
														</Typography.Text>{" "}
														<strong>
															{moment(sale.datePaiement).format("ll")}
														</strong>
													</p>
													<p>
														<Typography.Text strong>
															Customer :{" "}
														</Typography.Text>{" "}
														<Link
															to={`/customer/${sale?.customer?._id}`}>
															<strong>{sale?.customer?.name}</strong>
														</Link>
													</p>

													<p>
														<Typography.Text strong>
															Total Amount :
														</Typography.Text>{" "}
														<strong>{sale.totalAPayer}</strong>
													</p>
													<p>
														<Typography.Text strong>Discount :</Typography.Text>{" "}
														<strong>{sale.discount}</strong>
													</p>
													<p>
														<Typography.Text strong>
															Paid Amount :
														</Typography.Text>{" "}
														<strong>{sale.totalPaye}</strong>
													</p>
													<p>
														<Typography.Text strong>
															Due Amount :
														</Typography.Text>{" "}
														<strong style={{ color: "red" }}>
															{" "}
															{sale.resteAPayer}
														</strong>
													</p>
												
												</div>

												<div className='me-2'>


													{sale.paiements.map(el =>{
                                                       return(
														<>
															<p>
														<Typography.Text strong>
														Paid Amount :
														</Typography.Text>{" "}
														<strong style={{ color: "red" }}>
															{" "}
															{el.montantPaye}
														</strong>
													</p>
													<p>
														<Typography.Text strong>
														Mode Paiement :
														</Typography.Text>{" "}
														<strong style={{ color: "red" }}>
															{" "}
															{el.modePaiement}
														</strong>
													</p>
														</>
													   )
													}
														)}
												</div>
											</div>
										</CardComponent>
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

export default DetailSale;
