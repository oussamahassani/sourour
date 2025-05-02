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
import { addStaffAdmin } from "../../redux/actions/user/addStaffAciton";
import { getRoles } from "../role/roleApis";

const AddUser = () => {
  const [loader, setLoader] = useState(false);
  const dispatch = useDispatch();
  const { Title } = Typography;
  const { Option } = Select;
  const [list, setList] = useState(null);

  useEffect(() => {
    getRoles()
      .then((d) => setList(d))
      .catch((error) => console.log(error));
  }, []);



  const [form] = Form.useForm();

  const onFinish = async (values) => {
    try {
      const resp = await dispatch(addStaffAdmin(values));
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
                label="User Name"
                name="nom"
                rules={[
                  {
                    required: true,
                    message: "Please input username!",
                  },
                ]}
              >
                <Input />
              </Form.Item>

              <Form.Item
                style={{ marginBottom: "10px" }}
                label="Password"
                name="motDePasse"
                rules={[
                  {
                    required: true,
                    message: "Please input your password !",
                  },
                ]}
              >
                <Input />
              </Form.Item>

              <Form.Item
                style={{ marginBottom: "10px" }}
                label="Email"
                name="email"
                rules={[
                  {
                    required: true,
                    message: "Please input email!",
                  },
                ]}
              >
                <Input />
              </Form.Item>

        

     

              <Form.Item
                rules={[
                  {
                    required: true,
                    message: "Pleases Select Type!",
                  },
                ]}
                label="Role"
                name={"role"}
                style={{ marginBottom: "20px" }}
              >
                <Select
                  loading={!list}
                  optionFilterProp="children"
                  showSearch
                  filterOption={(input, option) =>
                    option.children.toLowerCase().includes(input.toLowerCase())
                  }
                  mode="single"
                  allowClear
                  style={{
                    width: "100%",
                  }}
                  placeholder="Please select"
                >
                  {list &&
                    list.map((role) => (
                      <Option key={role.name}>{role.name}</Option>
                    ))}
                </Select>
              </Form.Item>


              <Form.Item
                style={{ marginBottom: "10px" }}
                label="Phone"
                name="telephone"
                rules={[
                  {
                    required: true,
                    message: "Please input phone",
                  },
                ]}
              >
                <Input />
              </Form.Item>
              <Form.Item
                style={{ marginBottom: "10px" }}
                label="Last Name"
                name="prenom"
                rules={[
                  {
                    required: true,
                    message: "Please input Last Name",
                  },
                ]}
              >
                <Input />
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
