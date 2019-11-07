import axios from 'axios';

import {
  FETCH_CHECKLIST_ITEMS_START,
  FETCH_CHECKLIST_ITEMS_SUCCESS,
  FETCH_CHECKLIST_ITEMS_FAILURE,
} from 'redux/action-types';

export const fetchChecklistItemsStart = () => ({
  type: FETCH_CHECKLIST_ITEMS_START,
});

export const fetchChecklistItemsSuccess = data => ({
  type: FETCH_CHECKLIST_ITEMS_SUCCESS,
  value: data,
});

export const fetchChecklistItemsFailure = () => ({
  type: FETCH_CHECKLIST_ITEMS_FAILURE,
});

export const fetchChecklistItems = () => {
  return (dispatch, getState) => {
    const { myChecklistItems } = getState();

    if (myChecklistItems.loaded || myChecklistItems.isLoading) {
      return new Promise((resolve, _reject) => resolve(myChecklistItems));
    } else {
      dispatch(fetchChecklistItemsStart());

      axios
        .get('/api/my/tasks/checklist_items')
        .then(({ data }) => dispatch(fetchChecklistItemsSuccess(data)))
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };

            dispatch(fetchChecklistItemsFailure(failure));
          }
        });
    }
  };
};
