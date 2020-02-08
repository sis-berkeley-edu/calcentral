import axios from 'axios';

const buildDataActions = ({
  url,
  key,
  start_const,
  success_const,
  failure_const,
}) => {
  const onStart = () => ({
    type: start_const,
  });

  const onSuccess = err => ({
    type: success_const,
    value: err,
  });

  const onFailure = value => ({
    type: failure_const,
    value: value,
  });

  const loadData = () => {
    return (dispatch, getState) => {
      const state = getState()[key];

      if (state.loaded || state.isLoading) {
        return new Promise((resolve, _reject) => resolve(state));
      } else {
        dispatch(onStart());

        axios
          .get(url)
          .then(({ data }) => dispatch(onSuccess(data)))
          .catch(error => {
            if (error.response) {
              const failure = {
                status: error.response.status,
                statusText: error.response.statusText,
              };

              dispatch(onFailure(failure));
            }
          });
      }
    };
  };

  return {
    onStart,
    onSuccess,
    onFailure,
    loadData,
  };
};

export default buildDataActions;
