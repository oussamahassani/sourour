import axios from "axios";

const GetTotalCustomers = async () => {
  const data = await axios.get(`clients?query=info`);
  const totalCustomers = data.data.clients.length;
  return totalCustomers;
};

export default GetTotalCustomers;
