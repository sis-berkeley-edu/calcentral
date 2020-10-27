const getJSON = path => fetch(path).then(response => response.json());

const headers = () => ({
  'Content-Type': 'application/json',
  'X-CSRF-TOKEN': document
    .querySelector('meta[name=csrf-token]')
    .getAttribute('content'),
});

const apiRequest = method => path => values => {
  return fetch(path, {
    method: method,
    headers: headers(),
    body: JSON.stringify(values),
  }).then(response =>
    response.json().then(data => {
      return new Promise((resolve, reject) => {
        if (response.ok) {
          resolve(data);
        } else {
          reject(data);
        }
      });
    })
  );
};

const post = apiRequest('POST');
const put = apiRequest('PUT');

const destroy = path => {
  return fetch(path, {
    method: 'DELETE',
    headers: headers(),
  });
};

const getServiceAlert = id => getJSON(`/api/service_alerts/${id}`);
const getServiceAlerts = () => getJSON('/api/service_alerts');
const getDisplayedServiceAlerts = () =>
  getJSON('/api/service_alerts?displayed=true');

const createServiceAlert = values =>
  post('/api/service_alerts/')({
    service_alert: values,
  });

const updateServiceAlert = (id, values) =>
  put(`/api/service_alerts/${id}`)({ service_alert: values });

const destroyServiceAlert = id => destroy(`/api/service_alerts/${id}`);

const findUserAuth = uid => getJSON(`/api/user_auths?uid=${uid}`);

const createUserAuth = values => post('/api/user_auths')({ user_auth: values });

const updateUserAuth = (id, values) =>
  put(`/api/user_auths/${id}`)({ user_auth: values });

const destroyUserAuth = id => destroy(`/api/user_auths/${id}`);

export {
  getServiceAlert,
  getServiceAlerts,
  getDisplayedServiceAlerts,
  createServiceAlert,
  updateServiceAlert,
  destroyServiceAlert,
  findUserAuth,
  createUserAuth,
  updateUserAuth,
  destroyUserAuth,
};
