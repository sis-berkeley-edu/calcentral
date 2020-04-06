import axios from 'axios';

import {
  FETCH_BILLING_ITEMS_START,
  FETCH_BILLING_ITEMS_SUCCESS,
  FETCH_BILLING_ITEMS_FAILURE,
  FETCH_BILLING_ITEM_START,
  FETCH_BILLING_ITEM_SUCCESS,
  FETCH_BILLING_ITEM_FAILURE,
} from '../action-types';

export const fetchBillingItemsStart = () => ({
  type: FETCH_BILLING_ITEMS_START,
});

export const fetchBillingItemsSuccess = billingItems => ({
  type: FETCH_BILLING_ITEMS_SUCCESS,
  value: billingItems,
});

export const fetchBillingItemsFailure = error => ({
  type: FETCH_BILLING_ITEMS_FAILURE,
  value: error,
});

export const fetchBillingItems = () => {
  return (dispatch, getState) => {
    const { billingItems } = getState();

    if (billingItems.loaded || billingItems.isLoading) {
      return new Promise((resolve, _reject) => resolve(billingItems));
    } else {
      dispatch(fetchBillingItemsStart());

      axios
        .get(`/api/my/finances/billing_items`)
        .then(response => {
          dispatch(fetchBillingItemsSuccess(response.data));
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchBillingItemsFailure(failure));
          }
        });
    }
  };
};

export const fetchBillingItemStart = id => ({
  type: FETCH_BILLING_ITEM_START,
  value: id,
});

export const fetchBillingItemSuccess = billingItem => ({
  type: FETCH_BILLING_ITEM_SUCCESS,
  value: billingItem,
});

export const fetchBillingItemFailure = (id, error) => ({
  type: FETCH_BILLING_ITEM_FAILURE,
  id: id,
  value: error,
});

export const fetchBillingItem = id => {
  return (dispatch, getState) => {
    const { billingItems: { items } = {} } = getState();

    const item = items.find(item => item.id === id);

    if (item.loadedPayments || item.loadingPayments) {
      return new Promise((resolve, _reject) => resolve(item));
    } else {
      dispatch(fetchBillingItemStart(id));
      axios
        .get(`/api/my/finances/billing_items/${item.id}`)
        .then(response => {
          dispatch(fetchBillingItemSuccess(response.data));
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchBillingItemFailure(item.id, failure));
          }
        });
    }
  };
};
