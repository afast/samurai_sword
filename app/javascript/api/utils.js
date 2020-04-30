export const makeRequest = (url, options = {}) => {
  options.headers = options.headers || {};
  options.method = options.method || 'GET';

  if (typeof options.body === 'string') {
    options.headers['Content-Type'] = 'application/json';
  }

  return fetch(url, options).then(checkStatus).then(response => {
    if (response.status === 204) {
      return {};
    }

    return options.blob ? response.blob() : response.json();
  });
};

export const makeAuthenticatedRequest = (url, options = {}) => {
  //const state = store.getState();

  options.headers = options.headers || {};
  //options.headers['X-Auth-Email'] = get(state, 'user.user.email');
  //options.headers['X-Auth-Token'] = get(state, 'user.user.authentication_token');

  return makeRequest(url, options);
};

const checkStatus = response => {
  if (response.ok) {
    return Promise.resolve(response);
  }

  return response.json().then(json => {
    const error = new Error(response.statusText);
    return Promise.reject(Object.assign(error, {json}));
  });
};
