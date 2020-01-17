import axios from 'axios';

import {
  FETCH_WEB_MESSAGES_START,
  FETCH_WEB_MESSAGES_SUCCESS,
  FETCH_WEB_MESSAGES_FAILURE,
} from 'redux/action-types';

export const fetchWebMessagesStart = () => ({
  type: FETCH_WEB_MESSAGES_START,
});

export const fetchWebMessagesSuccess = value => ({
  type: FETCH_WEB_MESSAGES_SUCCESS,
  value: value,
});

export const fetchWebMessagesFailure = error => ({
  type: FETCH_WEB_MESSAGES_FAILURE,
  value: error,
});

export const fetchWebMessages = () => {
  return (dispatch, getState) => {
    const { myWebMessages } = getState();

    if (myWebMessages.loaded || myWebMessages.isLoading) {
      return new Promise((resolve, _reject) => resolve(myWebMessages));
    } else {
      dispatch(fetchWebMessagesStart());

      axios
        .get('/api/my/tasks/web_messages')
        .then(({ data }) => dispatch(fetchWebMessagesSuccess(data)))
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };

            dispatch(fetchWebMessagesFailure(failure));
          }
        });
    }
  };
};
