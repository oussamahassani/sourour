import { DeleteOutlined, EditOutlined } from "@ant-design/icons";
import { Button, Card, Popover, Typography } from "antd";
import { Fragment, useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link, Navigate, useNavigate, useParams } from "react-router-dom";
import { toast } from "react-toastify";
import { deleteSupplier } from "../../redux/actions/supplier/deleteSupplierAction";
import { loadSupplier } from "../../redux/actions/supplier/detailSupplierAction";
import Loader from "../loader/loader";
import PageTitle from "../page-header/PageHeader";
import "./suppliers.css";

import { CSVLink } from "react-csv";


//PopUp

const DetailsSup = () => {
  const { id } = useParams();
  let navigate = useNavigate();

  //dispatch
  const dispatch = useDispatch();
  const supplier = useSelector((state) => state.suppliers.supplier);

  //Delete Supplier
  const onDelete = () => {
    try {
      dispatch(deleteSupplier(id));

      setVisible(false);
      toast.warning(`Supplier : ${supplier.nomF} is removed `);
      return navigate("/supplier");
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
    dispatch(loadSupplier(id));
  }, [id]);

  const isLogged = Boolean(localStorage.getItem("isLogged"));

  if (!isLogged) {
    return <Navigate to={"/auth/login"} replace={true} />;
  }

  return (
    <div>
      <PageTitle title=" Back " subtitle={`Supplier ${id} information`} />

      <div className="mr-top">
        {supplier ? (
          <Fragment key={supplier.id}>
            <Card bordered={false} style={{}}>
              <div className="card-header d-flex justify-content-between" style={{ padding: 0 }}>
              <div className="w-50">
                <h5>
                  <i className="bi bi-person-lines-fill"></i>
                  <span className="mr-left">
                    ID : {supplier._id} | {supplier.nomF}
                  </span>
                </h5>
                </div>
                <div className="text-end w-50">
                  <Link
                    className="me-3 d-inline-block"
                    to={`/supplier/${supplier._id}/update`}
                    state={{ data: supplier }}
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
                      shape="round"
                      icon={<DeleteOutlined />}
                    ></Button>
                  </Popover>
                </div>
              </div>
              <div className="mt-3 mb-3">
                <p>
                  <Typography.Text className="font-semibold">
                    Email  : {supplier.email}
                  </Typography.Text>{" "}
                </p>

                <p>
                  <Typography.Text className="font-semibold">
                    Address :
                  </Typography.Text>{" "}
                  {supplier.adresse}
                </p>

                <p>
                  <Typography.Text strong>Phone :</Typography.Text>{" "}
                  {supplier.telephone}
                </p>
              </div>
              <hr />
              <h6 className="font-semibold m-0 text-center">
                All Invoice Information
              </h6>
              <div className="text-center m-2 d-flex justify-content-end">
                {supplier.purchaseInvoice && (
                  <div>
                    <CSVLink
                      data={supplier.purchaseInvoice}
                      className="btn btn-dark btn-sm mb-1"
                      filename="suppliers"
                    >
                      Download CSV
                    </CSVLink>
                  </div>
                )}
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

export default DetailsSup;
