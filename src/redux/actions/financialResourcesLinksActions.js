import axios from 'axios';


export const FETCH_FINRES_LINKS_START = 'FETCH_FINRES_LINKS_START';
export const FETCH_FINRES_LINKS_SUCCESS = 'FETCH_FINRES_LINKS_SUCCESS';
export const FETCH_FINRES_LINKS_FAILURE = 'FETCH_FINRES_LINKS_FAILURE';

export const fetchFinresLinksStart = () => ({
  type: FETCH_FINRES_LINKS_START
});

export const fetchFinresLinksSuccess = links => ({
  type: FETCH_FINRES_LINKS_SUCCESS,
  value: links
});

export const fetchFinresLinksFailure = error => ({
  type: FETCH_FINRES_LINKS_FAILURE,
  value: error
});

export const fetchFinresLinks = () => {
  return (dispatch, getState) => {
    const { financialResourcesLinks } = getState();

    if (financialResourcesLinks.loaded || financialResourcesLinks.isLoading) {
      return new Promise((resolve, _reject) => resolve(financialResourcesLinks));
    } else {
      dispatch(fetchFinresLinksStart());

      return axios.get(`/api/financial_aid/financial_resources`)
        .then(response => {
          dispatch(fetchFinresLinksSuccess(response.data));
        })
        .catch(error => {
          if (error.response) {
            const failure = { status: error.response.status, statusText: error.response.statusText };
            dispatch(fetchFinresLinksFailure(failure));
          }
        });
    }
  };
};
