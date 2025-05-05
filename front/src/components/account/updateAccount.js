import { Button, Form, Input, Modal, Select, Typography } from "antd";
import React, { useEffect, useState } from "react";
import { useDispatch } from "react-redux";
import { useNavigate } from "react-router-dom";
import { toast } from "react-toastify";
import { getMainAccount, updateAccount } from "./account.api";

const UpdateAccount = ({ account, id }) => {
	const [loading, setLoading] = useState(false);
	const [open, setOpen] = useState(false);
	const navigate = useNavigate();
	const dispatch = useDispatch();
	const { Title } = Typography;

	const [form] = Form.useForm();

	const [accounts, setAccounts] = useState(null);
	const [initValues, setInitValues] = useState({
		technicianName: account.technicianName,
		address: account.address,
		interventionType: account.interventionType,
		description: account.description,


	});

	useEffect(() => {
		const getAccounts = async () => {
			const response = await getMainAccount();
			setAccounts(response);
		};
		getAccounts();
	}, []);

	const onFinish = async (values) => {
		try {
			const resp = await updateAccount(id, values);
			if (resp === "success") {
				setLoading(false);
				setOpen(false);
				navigate(`/account`);
			}
			toast.success("Account Updated");
			form.resetFields();
			setInitValues({});
			setLoading(false);
		} catch (error) {
			toast.error("Error in adding account");
			console.log(error.message);
			setLoading(false);
		}
	};

	const onFinishFailed = (errorInfo) => {
		console.log("Failed:", errorInfo);
		setLoading(false);
	};

	const showModal = () => {
		setOpen(true);
	};

	const handleOk = () => {
		setLoading(true);
		setTimeout(() => {
			setLoading(false);
			setOpen(false);
		}, 3000);
	};

	const handleCancel = () => {
		setOpen(false);
	};

	return (
		<>
			<Button onClick={showModal} size='small'>
				Update Account
			</Button>
			<Modal
				open={open}
				title='Title'
				onOk={handleOk}
				onCancel={handleCancel}
				footer={[
					<Button key='back' type='danger' onClick={handleCancel}>
						cancel
					</Button>,
				]}>
				<Form
					form={form}
					className='m-4'
					name='basic'
					labelCol={{
						span: 8,
					}}
					wrapperCol={{
						span: 16,
					}}
					initialValues={{
						...initValues,
					}}
					onFinish={onFinish}
					onFinishFailed={onFinishFailed}
					autoComplete='off'>
					<Form.Item
						style={{ marginBottom: "10px" }}
						name='technicianName'
						label='TechnicianName'
						rules={[
							{
								required: true,
								message: "Please input technicianName!",
							},
						]}>
						<Input  readOnly={true} />
					</Form.Item>

					<Form.Item
						style={{ marginBottom: "10px" }}
						name='address'
						label='Address Intervention '
						rules={[
							{
								required: true,
								message: "Please input address Intervention!",
							},
						]}>
										<Input readOnly={true} />

					</Form.Item>
					<Form.Item
						style={{ marginBottom: "10px" }}
						name='interventionType'
						label='Intervention Type  '
						rules={[
							{
								required: true,
								message: "Please input  Type Intervention!",
							},
						]}>
										<Input readOnly={true}  />

					</Form.Item>
					<Form.Item
						style={{ marginBottom: "10px" }}
						name='description'
						label='Description   '
						rules={[
							{
								required: true,
								message: "Please input  description Intervention!",
							},
						]}>
										<Input />

					</Form.Item>
					<Form.Item
						style={{ marginBottom: "10px" }}
						wrapperCol={{
							offset: 8,
							span: 16,
						}}>
						<Button
							block
							type='primary'
							htmlType='submit'
							shape='round'
							loading={loading}
							onClick={() => setLoading(true)}>
							Update Account
						</Button>
					</Form.Item>
				</Form>
			</Modal>
		</>
	);
};

export default UpdateAccount;
