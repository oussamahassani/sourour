import React, { useState } from "react";

import {
	Alert,
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
import axios from "axios";
import { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import {
	Navigate,
	useLocation,
	useNavigate,
	useParams
} from "react-router-dom";
import { toast } from "react-toastify";
import PageTitle from "../page-header/PageHeader";
import { getRoles } from "../role/roleApis";

//Update User API REQ
const updateStaff = async (id, values) => {
  try {
    await axios({
      method: "put",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json;charset=UTF-8",
      },
      url: `admin/${id}`,
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

function UpdateStaff() {
  const dispatch = useDispatch();
  const { Title } = Typography;
  const [form] = Form.useForm();
  const [success, setSuccess] = useState(false);
  const { id } = useParams();
  const [loader, setLoader] = useState(false);

  //Loading Old data from URL
  const location = useLocation();
  const { data } = location.state;
  const designation = useSelector((state) => state.designations?.list);


  const user = data;
  const [initValues, setInitValues] = useState({
    nom: user.nom,
    prenom: user.prenom,
    role: user.role,
    telephone: user.telephone,
   
  
  });

  const navigate = useNavigate();

  const { Option } = Select;
  const [list, setList] = useState(null);

  useEffect(() => {
    getRoles()
      .then((d) => setList(d))
      .catch((error) => console.log(error));
  }, []);

  const onFinish = async (values) => {
    try {
      const resp = await updateStaff(id, values);

      setSuccess(true);
      toast.success("User Details updated");
      setInitValues({});
      if (resp === "success") {
        setLoader(false);
        if (role !== "admin") {
          navigate("/auth/logout");
        }
      } else {
        setLoader(false);
      }
    } catch (error) {
      console.log(error.message);
      setLoader(false);
    }
  };

  const onFinishFailed = (errorInfo) => {
    console.log("Failed:", errorInfo);
    setLoader(false);
  };

  const isLogged = Boolean(localStorage.getItem("isLogged"));
  const role = localStorage.getItem("role");

  if (!isLogged) {
    return <Navigate to={"/auth/login"} replace={true} />;
  }

  return (
    <>
      <PageTitle title={`Back`} />
      <div className="text-center">
        <div className="">
          <Row className="mr-top">
            <Col
              xs={24}
              sm={24}
              md={12}
              lg={12}
              xl={14}
              className="border rounded column-design "
            >
              {success && (
                <div>
                  <Alert
                    message={`User details updated successfully`}
                    type="success"
                    closable={true}
                    showIcon
                  />
                </div>
              )}
              <Card bordered={false} className="criclebox h-full">
                <Title level={3} className="m-3 text-center">
                  Edit : {initValues.nom}
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
                    span: 20,
                  }}
                  onFinish={onFinish}
                  onFinishFailed={onFinishFailed}
                  autoComplete="off"
                >
                  <Form.Item
                    style={{ marginBottom: "10px" }}
                    fields={[{ name: "nom" }]}
                    label="Userame"
                    name="nom"
                    rules={[
                      {
                        required: true,
                        message: "Please input User name!",
                      },
                    ]}
                  >
                    <Input />
                  </Form.Item>

                {/*  <Form.Item
                    style={{ marginBottom: "10px" }}
                    label="Change Password"
                    name="password"
                    rules={[
                      {
                        required: true,
                        message: "Please input New Password!",
                      },
                    ]}
                  >
                    <Input />
                  </Form.Item>
*/}
                  {role === "admin" ? (
                    <Form.Item
                      rules={[
                        {
                          required: true,
                          message: "Pleases Select Type!",
                        },
                      ]}
                      label="Staff Type "
                      name={"role"}
                      style={{ marginBottom: "20px" }}
                    >
                      <Select
                        optionFilterProp="children"
                        showSearch
                        filterOption={(input, option) =>
                          option.children
                            .toLowerCase()
                            .includes(input.toLowerCase())
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
                  ) : (
                    ""
                  )}
             {/*
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
*/}
           

    

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
                        message: "Please input Last name",
                      },
                    ]}
                  >
                    <Input />
                  </Form.Item>

         

     

      

                  <Form.Item
                    style={{ marginBottom: "10px" }}
                    wrapperCol={{
                      offset: 8,
                    }}
                  >
                    <Button
                      onClick={() => setLoader(true)}
                      loading={loader}
                      block
                      type="primary"
                      htmlType="submit"
                      shape="round"
                    >
                      Change Now
                    </Button>
                  </Form.Item>
                </Form>
              </Card>
            </Col>
          </Row>
        </div>
      </div>
    </>
  );
}

export default UpdateStaff;
