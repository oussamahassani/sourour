import {
  CheckOutlined, FileDoneOutlined,
  FileOutlined,
  FileSyncOutlined, FundOutlined, HomeOutlined,
  InboxOutlined,
  MinusSquareOutlined,
  PlusSquareOutlined,
  SettingOutlined, ShopOutlined, ShoppingCartOutlined, UnorderedListOutlined,
  UsergroupAddOutlined,
  UserOutlined,
  UserSwitchOutlined
} from "@ant-design/icons";
import { Menu } from "antd";
import React from "react";
import { NavLink } from "react-router-dom";
// import styles from "./Sidenav.module.css";

const Test = ({ color }) => {
  const menu = [
    {
      label: (
        <NavLink to="/dashboard">
          <span>Dashboard</span>
        </NavLink>
      ),
      key: "dashboard",
      icon: <HomeOutlined />,
    },
    {
      label: "PRODUCT",
      key: "product",
      icon: <ShopOutlined />,
      children: [
        {
          label: (
            <NavLink to="/product">
              <span>Products</span>
            </NavLink>
          ),
          key: "products",
          icon: <UnorderedListOutlined />,
        }
      ],
    },
    {
      label: "PURCHASE",
      key: "purchaseSection",
      icon: <PlusSquareOutlined />,
      children: [
        {
          label: (
            <NavLink to="/supplier">
              <span>Suppliers</span>
            </NavLink>
          ),
          key: "suppliers",
          icon: <UserOutlined />,
        },

        {
          label: (
            <NavLink to="/purchaselist">
              <span>Purchase List</span>
            </NavLink>
          ),
          key: "purchaseList",
          icon: <UnorderedListOutlined />,
        },
      ],
    },
    {
      label: "SALE",
      key: "saleSection",
      icon: <MinusSquareOutlined />,
      children: [
        {
          label: (
            <NavLink to="/customer">
              <span>Customers</span>
            </NavLink>
          ),
          key: "customers",
          icon: <UserOutlined />,
        },

        {
          label: (
            <NavLink to="/salelist">
              <span>Payements List</span>
            </NavLink>
          ),
          key: "saleList",
          icon: <UnorderedListOutlined />,
        },
      ],
    },
    {
      label: "Intervention",
      key: "accountSection",
      icon: <InboxOutlined />,
      children: [
        {
          label: (
            <NavLink to="/account/">
              <span>Intervention</span>
            </NavLink>
          ),
          key: "accountList",
          icon: <UnorderedListOutlined />,
        },

      ],
    },

    {
      label: "HR",
      key: "hrSection",
      icon: <UserOutlined />,
      children: [
        {
          label: (
            <NavLink to="/hr/staffsAdmin">
              <span>AdminStaffs</span>
            </NavLink>
          ),
          key: "staffsAdmin",
          icon: <UsergroupAddOutlined />,
        },
        {
          label: (
            <NavLink to="/hr/staffs">
              <span>Employer</span>
            </NavLink>
          ),
          key: "Employer",
          icon: <UsergroupAddOutlined />,
        },
        {
          label: (
            <NavLink to="/role">
              <span>Role & Permissions</span>
            </NavLink>
          ),
          key: "roleAndPermissions",
          icon: <UserSwitchOutlined />,
        },

      ],
    },



  ];

  return (
    <div>
      <Menu
        theme="dark"
        mode="inline"
        items={menu}
        className="sidenav-menu"
      // style={{ backgroundColor: "transparent" }}
      />
    </div>
  );
};

export default Test;
