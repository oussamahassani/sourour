import React from "react";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import { ToastContainer } from "react-toastify";
import "./App.css";
import DetailsSup from "./components/suppliers/detailsSup";
import Suppliers from "./components/suppliers/suppliers";
import UpdateSup from "./components/suppliers/updateSup";

import DetailsProd from "./components/product/detailsProd";
import Product from "./components/product/product";
import UpdateProd from "./components/product/updateProd";

import DetailsPurch from "./components/purchase/detailsPurch";
import Purchase from "./components/purchase/purchase";

import Login from "./components/user/Login";
import Logout from "./components/user/Logout";
import UserList from "./components/user/user";
import AdminUserList from "./components/admin/user"

import "./assets/styles/main.css";
import "./assets/styles/responsive.css";
import Customer from "./components/customer/customer";
import DetailCust from "./components/customer/detailCust";
import UpdateCust from "./components/customer/updateCust";
import DetailSale from "./components/sale/detailSale";
import Sale from "./components/sale/sale";

import Page404 from "./components/404/404Page";
import Dashboard from "./components/Dashboard/Graph/Dashboard";

import GetAllPurch from "./components/purchase/getAllPurch";
import GetAllSale from "./components/sale/getAllSale";
import DetailStaff from "./components/user/detailsStaff";
import AdminUserDetail from "./components/admin/detailsStaff"
import UpdateAdminStaff from "./components/admin/updateStaff"
import UpdateStaff from "./components/user/updateStaff";


// import Register from "./components/user/Register";
import { Layout } from "antd";
import Account from "./components/account/account";
import BalanceSheet from "./components/account/balanceSheet";
import DetailAccount from "./components/account/detailAccount";
import IncomeStatement from "./components/account/incomeStatement";
import TrialBalance from "./components/account/trialBalance";

import Main from "./components/layouts/Main";

import AddPermission from "./components/role/AddPermission";
import DetailRole from "./components/role/DetailsRole";
import RoleList from "./components/role/role";

const { Sider } = Layout;

function App() {
  return (
    <div className="App container-fluid">
      <BrowserRouter>
        <Main>
          <ToastContainer />
          <Routes>
            <Route path="/dashboard" element={<Dashboard />}></Route>
            <Route path="/" element={<Dashboard />} />
            <Route path="*" element={<Page404 />} />

            <Route path="/supplier" exact element={<Suppliers />} />
            <Route path="/supplier/:id" element={<DetailsSup />} />
            <Route path="/supplier/:id/update" element={<UpdateSup />} />

            <Route path="/product" exact element={<Product />} />
            <Route path="/product/:id" element={<DetailsProd />} />
            <Route path="/product/:id/update" element={<UpdateProd />} />


            <Route path="/purchase" exact element={<Purchase />} />
            <Route path="/purchaselist" exact element={<GetAllPurch />} />
            <Route path="/purchase/:id" element={<DetailsPurch />} />

           
            <Route path="/customer" exact element={<Customer />} />
            <Route path="/customer/:id" element={<DetailCust />} />
            <Route path="/customer/:id/update" element={<UpdateCust />} />

            <Route path="/salelist" exact element={<GetAllSale />} />
            <Route path="/sale/:id" element={<DetailSale />} />
         
       
       

            <Route path="/auth/login" exact element={<Login />} />
            <Route path="/auth/logout" exact element={<Logout />} />
            {/*         <Route path='/auth/register' exact element={<Register />} /> */}
            <Route path="/hr/staffs" exact element={<UserList />} />
            <Route path="/hr/staffsAdmin" exact element={<AdminUserList />} />
            <Route path="/hr/staffsAdmin/:id" exact element={<AdminUserDetail />} />
            <Route path="/hr/adminstaffs/:id/update" element={<UpdateAdminStaff />} />

            
            <Route path="/hr/staffs/:id" exact element={<DetailStaff />} />
            <Route path="/hr/staffs/:id/update" element={<UpdateStaff />} />

            <Route path="/role" exact element={<RoleList />} />
            <Route path="/role/:id" element={<DetailRole />} />
            <Route path="/role/permit/:id/" element={<AddPermission />} />

            <Route path="/account" exact element={<Account />} />
            <Route path="/account/:id" element={<DetailAccount />} />
            <Route
              path="/account/trial-balance"
              exact
              element={<TrialBalance />}
            />
            <Route
              path="/account/balance-sheet"
              exact
              element={<BalanceSheet />}
            />
            <Route path="/account/income" exact element={<IncomeStatement />} />


          </Routes>
        </Main>
      </BrowserRouter>
    </div>
  );
}

export default App;
