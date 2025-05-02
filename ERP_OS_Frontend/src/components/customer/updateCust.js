import { Alert, Button, Col, Form, Input, Row,Select, Typography } from "antd";
import axios from "axios";
import React, { useState } from "react";
import { Navigate, useLocation, useParams } from "react-router-dom";
import { toast } from "react-toastify";
import PageTitle from "../page-header/PageHeader";

//Update customer API REQ
const updateCustomer = async (id, values) => {
  try {
    await axios({
      method: "put",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json;charset=UTF-8",
      },
      url: `clients/${id}`,
      data: {
        ...values,
      },
    });
    return "success";
    // return data;
  } catch (error) {
    console.log(error.message);
  }
};

function UpdateCust() {
  const { Title } = Typography;
  const [form] = Form.useForm();
  const [success, setSuccess] = useState(false);
  const { id } = useParams();

  //Loading Old data from URL
  const location = useLocation();
  const { data } = location.state;

  const cust = data;
  const [initValues, setInitValues] = useState({
    nom: cust.nom,
    prenom:cust.prenom,
    telephone: cust.telephone,
    adresse: cust.adresse,
    validation_admin: cust.validation_admin,
  });

  const onFinish = (values) => {
    try {
      updateCustomer(id, values);
      setSuccess(true);
      toast.success("Customer details is updated");
      setInitValues({});
    } catch (error) {
      console.log(error.message);
    }
  };

  const onFinishFailed = (errorInfo) => {
    console.log("Failed:", errorInfo);
  };

  const isLogged = Boolean(localStorage.getItem("isLogged"));

  if (!isLogged) {
    return <Navigate to={"/auth/login"} replace={true} />;
  }

  return (
    <>
      <PageTitle
        title={`Update Customer/ ${id}`}
        subtitle="Update customer information"
      />
      <div className="text-center">
        <div className="">
          <Row className="mr-top">
            <Col
              xs={24}
              sm={24}
              md={12}
              lg={12}
              xl={14}
              className="border rounded column-design"
            >
              {success && (
                <div>
                  <Alert
                    message={`customer details updated successfully`}
                    type="success"
                    closable={true}
                    showIcon
                  />
                </div>
              )}
              <Title level={3} className="m-3 text-center">
                Edit Customer Form
              </Title>
              <Form
                initialValues={{
                  ...initValues,
                }}
                form={form}
                className="m-4"
                name="basic"
                labelCol={{
                  span: 8,
                }}
                wrapperCol={{
                  span: 16,
                }}
                onFinish={onFinish}
                onFinishFailed={onFinishFailed}
                autoComplete="off"
              >
                <Form.Item
                  style={{ marginBottom: "10px" }}
                  fields={[{ name: "Name" }]}
                  label="Name"
                  name="nom"
                  rules={[
                    {
                      required: true,
                      message: "Please input customer name!",
                    },
                  ]}
                >
                  <Input />
                </Form.Item>
                <Form.Item
                  style={{ marginBottom: "10px" }}
                  fields={[{ name: "Name" }]}
                  label="Prenom"
                  name="prenom"
                  rules={[
                    {
                      required: true,
                      message: "Please input customer prenom!",
                    },
                  ]}
                >
                  <Input />
                </Form.Item>
                <Form.Item
                  style={{ marginBottom: "10px" }}
                  label="Adresse"
                  name="adresse"
                  rules={[
                    {
                      required: true,
                      message: "Please input customer adresse!",
                    },
                  ]}
                >
                  <Input />
                </Form.Item>

                <Form.Item
                  style={{ marginBottom: "10px" }}
                  label="Phone"
                  name="telephone"
                  rules={[
                    {
                      required: true,
                      message: "Please input customer Phone!",
                    },
                  ]}
                >
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

                <Form.Item
                  style={{ marginBottom: "10px" }}
                  wrapperCol={{
                    offset: 8,
                    span: 16,
                  }}
                >
                  <Button block type="primary" htmlType="submit" shape="round">
                    Update Now
                  </Button>
                </Form.Item>
              </Form>
            </Col>
          </Row>
        </div>
      </div>
    </>
  );
}

export default UpdateCust;
