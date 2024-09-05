import axios from "axios";

const API_URL = "http://localhost:40853/api/Values";
export const postData = async (endpoint, data, options = {}) => {
    try {
      const response = await axios({
        url: `${API_URL}/${endpoint}`,
        method: 'POST',
        data,
        ...options,
      });
      return response.data;
    } catch (error) {
      console.error('API Post Error:', error.response?.statusText || error.message);
      throw error;
    }
}

export const fetchData = async (endpoint, options = {}) => {
    try {
      const response = await axios({
        url: `${API_URL}/${endpoint}`,
        ...options,
      });
      return response.data;
    } catch (error) {
      console.error('API Fetch Error:', error.response?.statusText || error.message);
      throw error;
    }
};
