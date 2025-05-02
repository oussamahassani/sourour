import {
	Button,
	Card,
	Col,
	DatePicker,
	Form,
	Input,
	InputNumber,
	Row,
	Select,
	Typography
} from "antd";

import { Fragment, useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { addStaff } from "../../redux/actions/user/addStaffAciton";
import { getRoles } from "../role/roleApis";

const AddUser = () => {
  const [loader, setLoader] = useState(false);
  const dispatch = useDispatch();
  const { Title } = Typography;
  const { Option } = Select;
  const [list, setList] = useState(null);


  // useseletor to get designations from redux

  useEffect(() => {
    getRoles()
      .then((d) => setList(d))
      .catch((error) => console.log(error));
  }, []);



  const [form] = Form.useForm();

  const onFinish = async (values) => {
    try {
      const resp = await dispatch(addStaff(values));
      setLoader(true);
      if (resp === "success") {
        setLoader(false);
      } else {
        setLoader(false);
      }

      form.resetFields();
    } catch (error) {
      console.log(error.message);
      setLoader(false);
    }
  };

  const onFinishFailed = (errorInfo) => {
    setLoader(false);
    console.log("Failed:", errorInfo);
  };

  return (
    <Fragment bordered={false}>
      <Row className="mr-top">
        <Col
          xs={24}
          sm={24}
          md={24}
          lg={16}
          xl={12}
          className="column-design border rounded bg-white"
        >
          <Card bordered={false}>
            <Title level={4} className="m-2 text-center">
              Add New Staff
            </Title>
            <Form
              form={form}
              name="basic"
              labelCol={{
                span: 6,
              }}
              wrapperCol={{
                span: 18,
              }}
              initialValues={{
                remember: true,
              }}
              onFinish={onFinish}
              onFinishFailed={onFinishFailed}
              autoComplete="off"
            >
              <Form.Item
                style={{ marginBottom: "10px" }}
                label="full name "
                name="full_name"
                rules={[
                  {
                    required: true,
                    message: "Please inputfull name!",
                  },
                ]}
              >
                <Input />
              </Form.Item>

              <Form.Item
                style={{ marginBottom: "10px" }}
                label="department"
                name="department"
                rules={[
                  {
                    required: true,
                    message: "Please input your department !",
                  },
                ]}
              >
                <Input />
              </Form.Item>

              <Form.Item
                style={{ marginBottom: "10px" }}
                label="type contrat"
                name="type_contrat"
                rules={[
                  {
                    required: true,
                    message: "Please input type contrat!",
                  },
                ]}
              >
                <Input />
              </Form.Item>

              <Form.Item
                style={{ marginBottom: "10px" }}
                label="Joining Date"
                name="date_hire"
                rules={[
                  {
                    required: true,
                    message: "Please input joining date!",
                  },
                ]}
              >
                <DatePicker className="date-picker" />
              </Form.Item>

              <Form.Item
                style={{ marginBottom: "10px" }}
                label="Fin contrat Date"
                name="date_fin_contrat"
                rules={[
                  {
                    required: true,
                    message: "Please input leave date!",
                  },
                ]}
              >
                <DatePicker className="date-picker" />
              </Form.Item>

              <Form.Item
                style={{ marginBottom: "10px" }}
                label="Number conges"
                name="jours_conges_restants"
                rules={[
                  {
                    required: true,
                    message: "Please input conges Number",
                  },
                ]}
              >
                <Input />
              </Form.Item>
              <Form.Item
                style={{ marginBottom: "10px" }}
                label="Address"
                name="adresse"
                rules={[
                  {
                    required: true,
                    message: "Please input address",
                  },
                ]}
              >
                <Input />
              </Form.Item>

              <Form.Item
                style={{ marginBottom: "10px" }}
                label="Salary"
                name="salary"
                rules={[
                  {
                    required: true,
                    message: "Please input salary",
                  },
                ]}
              >
                <InputNumber />
              </Form.Item>
              <Form.Item
                style={{ marginBottom: "10px" }}
                label="Num securite sociale"
                name="num_securite_sociale"
                rules={[
                  {
                    required: true,
                    message: "Please input num securite sociale",
                  },
                ]}
              >
                <InputNumber />
              </Form.Item>

              
  
              <Form.Item
                style={{ marginBottom: "10px" }}
                wrapperCol={{
                  offset: 4,
                  span: 16,
                }}
              >
                <Button
                  onClick={() => setLoader(true)}
                  block
                  type="primary"
                  htmlType="submit"
                  shape="round"
                  loading={loader}
                >
                  Add New Staff
                </Button>
              </Form.Item>
            </Form>
          </Card>
        </Col>
      </Row>
    </Fragment>
  );
};

export default AddUser;
