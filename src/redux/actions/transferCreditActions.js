import axios from 'axios';

// var urlTransferCredit = '/dummy/json/edodb_transfer_credits.json';

import {
  FETCH_TRANSFER_CREDIT_START,
  FETCH_TRANSFER_CREDIT_SUCCESS,
  FETCH_TRANSFER_CREDIT_FAILURE,
} from '../action-types';

export const fetchTransferCreditStart = () => ({
  type: FETCH_TRANSFER_CREDIT_START,
});

export const fetchTransferCreditSuccess = transferCredit => ({
  type: FETCH_TRANSFER_CREDIT_SUCCESS,
  value: transferCredit,
});

export const fetchTransferCreditFailure = error => ({
  type: FETCH_TRANSFER_CREDIT_FAILURE,
  value: error,
});

export const fetchTransferCredit = () => {
  return (dispatch, getState) => {
    const { myTransferCredit } = getState();

    if (myTransferCredit.loaded || myTransferCredit.isLoading) {
      return new Promise((resolve, _reject) => resolve(myTransferCredit));
    } else {
      dispatch(fetchTransferCreditStart());

      return axios
        .get('/api/academics/transfer_credits')
        .then(response => {
          dispatch(fetchTransferCreditSuccess(response.data));
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchTransferCreditFailure(failure));
          }
        });
    }
  };
};
