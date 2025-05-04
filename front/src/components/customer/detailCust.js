import { DeleteOutlined, EditOutlined } from "@ant-design/icons";
import { Button, Card, Popover, Typography } from "antd";
import { Fragment, useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link, Navigate, useNavigate, useParams } from "react-router-dom";
import { toast } from "react-toastify";
import { deleteCustomer } from "../../redux/actions/customer/deleteCustomerAction";
import { loadSingleCustomer } from "../../redux/actions/customer/detailCustomerAction";
import Loader from "../loader/loader";
import PageTitle from "../page-header/PageHeader";


//PopUp

const DetailCust = () => {
  const { id } = useParams();
  let navigate = useNavigate();

  //dispatch
  const dispatch = useDispatch();
  const customer = useSelector((state) => state.customers.customer);

  //Delete Supplier
  const onDelete = () => {
    try {
      dispatch(deleteCustomer(id));

      setVisible(false);
      toast.warning(`Customer : ${customer.nom} is removed `);
      return navigate("/customer");
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
    dispatch(loadSingleCustomer(id));
  }, [id]);

  const isLogged = Boolean(localStorage.getItem("isLogged"));

  if (!isLogged) {
    return <Navigate to={"/auth/login"} replace={true} />;
  }

  return (
    <div>
      <PageTitle title=" Back " subtitle=" " />

      <div className="mr-top">
        {customer ? (
          <Fragment key={customer._id}>
            <Card bordered={false} style={{}}>
              <div className="card-header d-flex justify-content-between m-3">
                <h5>
                  <i className="bi bi-person-lines-fill"></i>
                  <span className="mr-left">
                    ID : {customer._id} | {customer.nom}
                  </span>
                </h5>
                <div className="text-end">
                  <Link
                    className="m-2"
                    to={`/customer/${customer._id}/update`}
                    state={{ data: customer }}
                  >
                    <Button
                      type="primary"
                      shape="round"
                      icon={<EditOutlined />}
                    ></Button>
                  </Link>
                  <Popover
                    content={
                      <a onClick={onDelete}>
                        <Button type="primary" danger>
                          Yes Please !
                        </Button>
                      </a>
                    }
                    title="Are you sure you want to delete ?"
                    trigger="click"
                    visible={visible}
                    onVisibleChange={handleVisibleChange}
                  >
                    <Button
                      type="danger"
                      DetailCust
                      shape="round"
                      icon={<DeleteOutlined />}
                    ></Button>
                  </Popover>
                </div>
              </div>
              <div className="card-body m-2">
                   <p>
                  <Typography.Text strong>Phone Number :</Typography.Text>{" "}
                  {customer.telephone}
                </p>

                <p>
                  <Typography.Text strong>Address :</Typography.Text>{" "}
                  {customer.adresse}
                </p>

                <p>
                  <Typography.Text strong>Email :</Typography.Text>{" "}
                  {customer.email}
                </p>
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

export default DetailCust;
