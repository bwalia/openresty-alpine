const getHeaders = () => {
    const token = localStorage.getItem("token");
    const accessToken = JSON.parse(token);
  
    const basicHeaders = {
      Accept: "application/json",
      "Content-Type": "application/json",
    };
  
    if (accessToken?.access_token) {
      basicHeaders.Authorization = `Bearer ${accessToken.access_token}`;
    }
    return basicHeaders;
  };
  const dataProvider = (apiUrl, settings = {}) => ({
    get: async (resource, params) => {
      const url = `${apiUrl}/resource?_format=json&params=${JSON.stringify(
        params
      )}`;
      const response = await fetch(url, {
        method: "GET",
        headers: getHeaders(),
      });
      const { data } = await response.json();
      return { data };
    },
    getList: async (resource, params) => {
      try {
        params.businessUUID = localStorage.getItem("uuid_business_id");
        const pageResource = resource.includes("webimpetus-v1/")
          ? resource.split("/")[1]
          : resource;
        const url = `${apiUrl}/${pageResource}?_format=json&params=${JSON.stringify(
          params
        )}`;
        const response = await fetch(url, {
          method: "GET",
          headers: getHeaders(),
        });
  
        if (response.status < 200 || response.status >= 300 && response.status !== 404) {
          localStorage.removeItem("token");
          localStorage.removeItem("uuid_business_id");
          window.location.href = "/#/login";
        }
        const data = await response.json();
        return data;
      } catch (error) {
        console.warn({ error });
      }
    },
    getOne: async (resource, params) => {
      const { id } = params;
      const url = `${apiUrl}/${resource}/${id}?_format=json`;
      const response = await fetch(url, {
        method: "GET",
        headers: getHeaders(),
      });
      if (response.status < 200 || response.status >= 300) {
        localStorage.removeItem("token");
        localStorage.removeItem("uuid_business_id");
        window.location.href = "/login";
      }
      const data = await response.json();
      return data;
    },
    getMany: async (resource, params) => {
      const url = `${apiUrl}/${resource}?filter=${JSON.stringify(params)}`;
      const response = await fetch(url, {
        method: "GET",
        headers: getHeaders(),
      });
      if (response.status < 200 || response.status >= 300) {
        localStorage.removeItem("token");
        localStorage.removeItem("uuid_business_id");
        window.location.href = "/login";
      }
      const data = await response.json();
      return data;
    },
    create: async (resource, params) => {
      const url = `${apiUrl}/${resource}?_format=json`;
      const { data } = params;
      data.businessUUID = localStorage.getItem("uuid_business_id");
      try {
        const response = await fetch(url, {
          method: "POST",
          headers: getHeaders(),
          body: JSON.stringify(data),
        });
        if (response.status < 200 || response.status >= 300) {
          localStorage.removeItem("token");
          localStorage.removeItem("uuid_business_id");
          window.location.href = "/login";
        }
        const result = await response.json();
        return result;
      } catch (error) {
        console.error("Error:", error);
      }
    },
    update: async (resource, params) => {
      const pageResource = resource.split("/")[1];
      const { data } = params;
      const { id } = params;
      const url = `${apiUrl}/${pageResource}/${id}?_format=json`;
      data.businessUUID = localStorage.getItem("uuid_business_id");
      try {
        const response = await fetch(url, {
          method: "PUT",
          headers: getHeaders(),
          body: JSON.stringify(data),
        });
        if (response.status < 200 || response.status >= 300) {
          localStorage.removeItem("token");
          localStorage.removeItem("uuid_business_id");
          window.location.href = "/login";
        }
        const result = await response.json();
        return result;
      } catch (error) {
        console.error("Error:", error);
      }
    },
    getResource: async (resource, params) => {
      try {
        params.businessUUID = localStorage.getItem("uuid_business_id");
        const url = `${apiUrl}/${resource}?_format=json&${JSON.stringify(
          params
        )}`;
        const response = await fetch(url, {
          method: "GET",
          headers: getHeaders(),
        });
        if (response.status < 200 || response.status >= 300) {
          localStorage.removeItem("token");
          localStorage.removeItem("uuid_business_id");
          window.location.href = "/login";
        }
        const data = await response.json();
        return data;
      } catch (error) {
        console.log({ error });
        throw new Error(error);
      }
    },
  });
  export default dataProvider;