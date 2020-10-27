import axios from 'axios';

import {
  SERVICE_ALERTS_START,
  SERVICE_ALERTS_SUCCESS,
  SERVICE_ALERTS_FAILURE,
} from '../action-types';

const fetchServiceAlertsStart = () => ({
  type: SERVICE_ALERTS_START,
});

const fetchServiceAlertsSuccess = data => ({
  type: SERVICE_ALERTS_SUCCESS,
  value: data,
});

const fetchServiceAlertsFailure = error => ({
  type: SERVICE_ALERTS_FAILURE,
  value: error,
});

export function fetchServiceAlerts() {
  return (dispatch, getState) => {
    const { serviceAlerts } = getState();

    if (serviceAlerts.loadState === 'success') {
      return new Promise(resolve => resolve(serviceAlerts));
    } else if (serviceAlerts.loadState !== 'pending') {
      dispatch(fetchServiceAlertsStart());
      return axios
        .get('/api/service_alerts/feed')
        .then(({ data }) => dispatch(fetchServiceAlertsSuccess(data)))
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchServiceAlertsFailure(failure));
          }
        });
    }
  };
}
