const authProvider = {
  // send username and password to the auth server and get back credentials
  login: async (params) => {
    const { email, password } = params;
    const request = new Request("http://localhost:8080/api/user/login ", {
      method: "POST",
      body: JSON.stringify({ email, password }),
      headers: new Headers({
        Accept: "application/json",
        "Content-Type": "application/json",
      }),
    });
    await fetch(request)
      .then((response) => {
        console.log({ response });
        if (response.status < 200 || response.status >= 300) {
          throw new Error(response.statusText);
        }
        return response.json();
      })
      .then(({ access_token, user }) => {
        const expiryDate = new Date();
        expiryDate.setSeconds(expiryDate.getSeconds() + 3600);
        const token = {
          access_token,
          expiryDate,
        };
        localStorage.setItem("token", JSON.stringify(token));
        localStorage.setItem("uuid_business_id", user.uuid_business_id);
      });
    return Promise.resolve();
  },
  // when the dataProvider returns an error, check if this is an authentication error
  checkError: (error) => {
    console.log({ error: error.toString() });
    const status = error.status;
    if (status === 401 || status === 403) {
      localStorage.removeItem("token");
      return Promise.reject();
    }
    return Promise.resolve();
  },
  // when the user navigates, make sure that their credentials are still valid
  checkAuth: (params) => {
    return localStorage.getItem("token") ? Promise.resolve() : Promise.reject();
  },
  // remove local credentials and notify the auth server that the user logged out
  logout: () => {
    localStorage.removeItem("token");
    return Promise.resolve();
  },
  // get the user's profile
  getIdentity: () => Promise.resolve(),
  // get the user permissions (optional)
  getPermissions: () =>
    localStorage.getItem("token") ? Promise.resolve() : Promise.reject(),
};

export default authProvider;
