import { DeleteOutlined, EditOutlined } from "@ant-design/icons";
import { Button, Card, Popover, Typography } from "antd";
import moment from "moment";
import { Fragment, useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link, Navigate, useNavigate, useParams } from "react-router-dom";
import { toast } from "react-toastify";
import { AdmindeleteStaff } from "../../redux/actions/user/deleteStaffAction";
import { AdminloadSingleStaff } from "../../redux/actions/user/detailUserAction";
import Loader from "../loader/loader";
import PageTitle from "../page-header/PageHeader";

//PopUp

const DetailStaff = () => {
  const { id } = useParams();
  let navigate = useNavigate();

  //dispatch
  const dispatch = useDispatch();
  const user = useSelector((state) => state.users.user);

  //Delete Supplier
  const onDelete = () => {
    try {
      dispatch(AdmindeleteStaff(id));

      setVisible(false);
      toast.warning(`User Name : ${user.nom} is removed `);
      return navigate("/hr/staffsAdmin");
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
    dispatch(AdminloadSingleStaff(id));
  }, [id]);

  const isLogged = Boolean(localStorage.getItem("isLogged"));

  if (!isLogged) {
    return <Navigate to={"/auth/login"} replace={true} />;
  }
  return (
    <div>
      <PageTitle title=" Back  " />

      <div className="mr-top">
        {user ? (
          <Fragment key={user.id}>
            <Card bordered={false} className="card-custom">
              <div className="card-header d-flex justify-content-between m-3">
                <h5>
                  <i className="bi bi-person-lines-fill"></i>
                  <span className="mr-left">
                    ID : {user._id} | {user.nom}
                  </span>
                </h5>
                <div className="text-end">
                  <Link
                    className="m-2"
                    to={`/hr/adminstaffs/${user._id}/update`}
                    state={{ data: user }}
                  >
                    <Button
                      type="primary"
                      shape="round"
                      icon={<EditOutlined />}
                    ></Button>
                  </Link>
                  <Popover
                    className="m-2"
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
              <div className="card-body m-3">
              <p>
                  <Typography.Text strong>Last Name :</Typography.Text>{" "}
                  {user.prenom}
                </p>
                <p>
                  <Typography.Text strong>Role :</Typography.Text> {user.role}
                </p>
                <p>
                  <Typography.Text strong>email :</Typography.Text> {user.email}
                </p>
                <p>
                  <Typography.Text strong>status :</Typography.Text> {user.status ? "activer" : "desactiver"}
                </p>
              
                <p>
                  <Typography.Text strong>phone :</Typography.Text> {user.telephone}
                </p>
             
         

                <p>
                  <Typography.Text strong>Joining Date</Typography.Text>{" "}
                  {moment(user.join_date).format("YYYY-MM-DD")}
                </p>

                <p>
                  <Typography.Text strong>Leave Date</Typography.Text>{" "}
                  {moment(user.leave_date).format("YYYY-MM-DD")}
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

export default DetailStaff;
