import { FETCH_LINK_START, FETCH_LINK_SUCCESS } from '../action-types';

export const fetchLinkStart = key => ({
  type: FETCH_LINK_START,
  key: key,
});

export const fetchLinkSuccess = (key, value) => ({
  type: FETCH_LINK_SUCCESS,
  key: key,
  value: value,
});
