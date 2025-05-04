import "bootstrap-icons/font/bootstrap-icons.css";
import { Link, Navigate } from "react-router-dom";
import "./sale.css";

import { SearchOutlined } from "@ant-design/icons";
import {
    Button,
    DatePicker,
    Dropdown,
    Form,
    Menu,
    Segmented,
    Select,
    Table
} from "antd";
import moment from "moment";
import { useEffect, useState } from "react";
import { CSVLink } from "react-csv";
import { useDispatch, useSelector } from "react-redux";
import { loadAllSale } from "../../redux/actions/sale/getSaleAction";
import PageTitle from "../page-header/PageHeader";



function CustomTable({ list, total, startdate, enddate, count, user }) {
  const [columnItems, setColumnItems] = useState([]);
  const [columnsToShow, setColumnsToShow] = useState([]);
  const dispatch = useDispatch();

  const columns = [
    {
      title: "Invoice No",
      dataIndex: "_id",
      key: "_id",
      render: (name, { _id }) => <Link to={`/sale/${_id}`}>{_id}</Link>,
    },
    {
      title: "Date",
      dataIndex: "createdAt",
      key: "createdAt",
      render: (createdAt) => moment(createdAt).format("ll"),
    },
    {
      title: "Total Paye ",
      dataIndex: `totalPaye`,
      key: "totalPaye",
      render: (totalPaye) => totalPaye,
    },

    {
      title: "reste A Payer",
      dataIndex: "resteAPayer",
      key: "resteAPayer",
    },
    {
      title: "Responsable",
      dataIndex: "responsable",
      key: "responsable",
    },


    //Update Supplier Name here


  ];

  useEffect(() => {
    setColumnItems(menuItems);
    setColumnsToShow(columns);
  }, []);

  const colVisibilityClickHandler = (col) => {
    const ifColFound = columnsToShow.find((item) => item.key === col.key);
    if (ifColFound) {
      const filteredColumnsToShow = columnsToShow.filter(
        (item) => item.key !== col.key
      );
      setColumnsToShow(filteredColumnsToShow);
    } else {
      const foundIndex = columns.findIndex((item) => item.key === col.key);
      const foundCol = columns.find((item) => item.key === col.key);
      let updatedColumnsToShow = [...columnsToShow];
      updatedColumnsToShow.splice(foundIndex, 0, foundCol);
      setColumnsToShow(updatedColumnsToShow);
    }
  };

  const menuItems = columns.map((item) => {
    return {
      key: item.key,
      label: <span>{item.title}</span>,
    };
  });

  const addKeys = (arr) => arr.map((i) => ({ ...i, key: i.id }));

  return (
    <>
      {list && (
        <div style={{ marginBottom: "30px" }}>
          <Dropdown
            overlay={
              <Menu onClick={colVisibilityClickHandler} items={columnItems} />
            }
            placement="bottomLeft"
          >
            <Button className="column-visibility">Column Visibility</Button>
          </Dropdown>
        </div>
      )}
      <Table
        scroll={{ x: true }}
        loading={!list}
        pagination={{
          pageSize: count || 10,
          pageSizeOptions: [10, 20, 50, 100, 200],
          showSizeChanger: true,
          total: total,

          onChange: (page, limit) => {
            dispatch(
              loadAllSale({ page, limit, startdate, enddate, user: user || "" })
            );
          },
        }}
        columns={columnsToShow}
        dataSource={list ? addKeys(list) : []}
      />
    </>
  );
}

const GetAllSale = (props) => {
  const dispatch = useDispatch();
  const list = useSelector((state) => state.sales.list);
  const total = useSelector((state) => state.sales.total);
  const userList = useSelector((state) => state.users.list);
  const [user, setUser] = useState("");
  const [count, setCount] = useState(0);
  const [loading, setLoading] = useState(false);


	const [startdate, setStartdate] = useState(
		moment().startOf("month").format("YYYY-MM-DD")
	);
	const [enddate, setEnddate] = useState(
		moment().endOf("month").format("YYYY-MM-DD")
	);




  const totalCount = total?._count?.id;

  useEffect(() => {
    setCount(totalCount);
  }, [totalCount]);


	useEffect(() => {
		dispatch(
			loadAllSale({
				page: 1,
				limit: 10,
				startdate: moment().startOf("month"),
				enddate: moment().endOf("month"),
				user: "",
			})
		);
	}, []);


  const CSVlist = list?.map((i) => ({
    ...i,
    customer: i?.customer?.name,
  }));

  const onSearchFinish = async (values) => {
    setCount(total?._count?.id);
    setUser(values?.user);
    const resp = await dispatch(
      loadAllSale({
        page: 1,
        limit: "",
        startdate: startdate,
        enddate: enddate,
        user: values.user ? values.user : "",
      })
    );
    if (resp.message === "success") {
      setLoading(false);
    } else {
      setLoading(false);
    }
  };
  const [form] = Form.useForm();
  const onSwitchChange = (value) => {
    setCount(value);
    dispatch(
      loadAllSale({
        page: 1,
        limit: "",
        startdate: startdate,
        enddate: enddate,
        user: user || "",
      })
    );
  };


	const onCalendarChange = (dates) => {
		const newStartdate = dates[0].format("YYYY-MM-DD");
		const newEnddate = dates[1].format("YYYY-MM-DD");
		setStartdate(newStartdate ? newStartdate : startdate);
		setEnddate(newEnddate ? newEnddate : enddate);
	};


  const isLogged = Boolean(localStorage.getItem("isLogged"));

  if (!isLogged) {
    return <Navigate to={"/auth/login"} replace={true} />;
  }


	return (
		<>
			<PageTitle title={"Back"} />
			<div className='card card-custom mt-1'>
				<div className='card-body'>
				
     
          <br />
          <div>
            <div>
              <h5>Sales History</h5>
              {list && (
                <div className="card-title d-flex justify-content-end ">
                  <div className="me-2">
                    <CSVLink
                      data={CSVlist}
                      className="btn btn-dark btn-sm mb-1"
                      filename="sales"
                    >
                      Download CSV
                    </CSVLink>
                  </div>
                  <div className="me-2" style={{ marginTop: "-4px" }}>
                    <Segmented
                      className="text-center rounded danger"
                      size="middle"
                      options={[
                        {
                          label: (
                            <span>
                              <i className="bi bi-person-lines-fill"></i> All
                            </span>
                          ),
                          value: totalCount,
                        },
                        {
                          label: (
                            <span>
                              <i className="bi bi-person-dash-fill"></i>{" "}
                              Paginated
                            </span>
                          ),
                          value: 10,
                        },
                      ]}
                      value={count}
                      defaultChecked={totalCount}
                      onChange={onSwitchChange}
                    />
                  </div>

                 
                </div>
              )}
            </div>
          </div>
          <CustomTable
            list={list}
            total={total?._count?.id}
            startdate={startdate}
            enddate={enddate}
            count={count}
            user={user}
          />
        </div>
      </div>
    </>
  );
};

export default GetAllSale;
