import PageTitle from "../page-header/PageHeader";

import { Navigate } from "react-router-dom";

import GetAllAccount from "./getAllAccount";

const Account = (props) => {
  const isLogged = Boolean(localStorage.getItem("isLogged"));

  if (!isLogged) {
    return <Navigate to={"/auth/login"} replace={true} />;
  }

  return (
    <div>
      <PageTitle title="Back" />
   

      <GetAllAccount />
    </div>
  );
};

export default Account;
