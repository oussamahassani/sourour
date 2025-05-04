import { Button,Select, Card, Col, Form, Input, Row, Typography } from "antd";

import { Fragment, useState } from "react";
import { useDispatch } from "react-redux";
import { addCustomer } from "../../redux/actions/customer/addCustomerAciton";
import styles from "./AddCust.module.css";

const AddCust = () => {
	const dispatch = useDispatch();
	const { Title } = Typography;
	const [loading, setLoading] = useState(false);
	const onClick = () => {
		setLoading(true);
	};

	const [form] = Form.useForm();

	const onFinish = async (values) => {
		try {
             const id= localStorage.getItem('id')
			const resp = await dispatch(addCustomer({...values , commercial_assigne:id}));
			if (resp.message === "success") {
				setLoading(false);
				form.resetFields();
			} else {
				setLoading(false);
			}
		} catch (error) {
			setLoading(false);
			console.log(error.message);
		}
	};

	const onFinishFailed = (errorInfo) => {
		setLoading(false);
		console.log("Failed:", errorInfo);
	};

	return (
		<Fragment>
			<Row className='mr-top' justify='space-between' gutter={[0, 30]}>
				<Col
					xs={24}
					sm={24}
					md={24}
					lg={11}
					xl={11}
					className='rounded column-design'>
					<Card bordered={false}>
						<Title level={4} className='m-2 text-center'>
							Add Customer
						</Title>
						<Form
							form={form}
							name='basic'
							labelCol={{
								span: 7,
							}}
							wrapperCol={{
								span: 16,
							}}
							initialValues={{
								remember: true,
							}}
							onFinish={onFinish}
							onFinishFailed={onFinishFailed}
							autoComplete='off'>
							<Form.Item
								style={{ marginBottom: "10px" }}
								label='Name'
								name='nom'
								rules={[
									{
										required: true,
										message: "Please input customer name!",
									},
								]}>
								<Input />
							</Form.Item>
							<Form.Item
								style={{ marginBottom: "10px" }}
								label='Last Name'
								name='prenom'
								rules={[
									{
										required: true,
										message: "Please input customer Last name!",
									},
								]}>
								<Input />
							</Form.Item>
							<Form.Item
								style={{ marginBottom: "10px" }}
								label='Email'
								name='email'
								rules={[
									{
										required: true,
										message: "Please input customer email!",
									},
								]}>
								<Input />
							</Form.Item>
							<Form.Item
								style={{ marginBottom: "10px" }}
								label='Plafond credit'
								name='plafond_credit'
								rules={[
									{
										required: true,
										message: "Please input plafond credit!",
									},
								]}>
								<Input />
							</Form.Item>
							<Form.Item
								style={{ marginBottom: "10px" }}
								label='Entreprise'
								name='entreprise'
								rules={[
									
								]}>
								<Input />
							</Form.Item>
							<Form.Item
								style={{ marginBottom: "10px" }}
								label='Matricule'
								name='matricule'
								rules={[
									
								]}>
								<Input />
							</Form.Item>
							<Form.Item
								style={{ marginBottom: "10px" }}
								label='Cin'
								name='cin'
								rules={[
									
								]}>
								<Input />
							</Form.Item>
							{/*<Form.Item
								style={{ marginBottom: "10px" }}
								label='Commercial assigne'
								name='commercial_assigne'
								rules={[
									
								]}>
								<Input />
							</Form.Item>*/}
							<Form.Item
								style={{ marginBottom: "10px" }}
								label='Phone'
								name='telephone'
								rules={[
									{
										required: true,
										message: "Please input customer Phone!",
									},
								]}>
								<Input />
							</Form.Item>

							<Form.Item
								style={{ marginBottom: "10px" }}
								label='Address'
								name='adresse'
								rules={[
									{
										required: true,
										message: "Please input customer Address!",
									},
								]}>
								<Input />
							</Form.Item>
 <Form.Item
				style={{ marginBottom: "15px" }}
				name="validation_admin"
				label="Select Validation Type "
				rules={[
				  {
					required: true,
					message: "Please select Validation !",
				  },
				]}
			  >
				<Select
				  name="validation_admin"
				
				  placeholder="validation_admin"
				  optionFilterProp="children"
				  filterOption={(input, option) =>
					option.children.includes(input)
				  }
				  filterSort={(optionA, optionB) =>
					optionA.children
					  .toLowerCase()
					  .localeCompare(optionB.children.toLowerCase())
				  }
				>
				 <Select.Option key={false} value={false}>
						{" non valider"}
					  </Select.Option>
					  <Select.Option key={true} value={true}>
						{"valider"}
					  </Select.Option>
			
				</Select>
			  </Form.Item>

							{/* Customer due droped */}

							<Form.Item
								style={{ marginBottom: "10px" }}
								className={styles.addCustomerBtnContainer}>
								<Button
									loading={loading}
									onClick={onClick}
									type='primary'
									htmlType='submit'
									shape='round'>
									Add Customer
								</Button>
							</Form.Item>
						</Form>
					</Card>
				</Col>
			
			</Row>
		</Fragment>
	);
};

export default AddCust;
