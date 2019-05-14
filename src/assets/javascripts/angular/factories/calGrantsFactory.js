import {
  fetchCalGrantsStart,
  fetchCalGrantsSuccess
} from 'Redux/actions/calGrantsActions';

angular.module('calcentral.factories').factory('calGrantsFactory', function(apiService, $ngRedux) {
  const getCalGrants = function(options) {
    const { myCalGrants } = $ngRedux.getState();

    if (myCalGrants.loaded || myCalGrants.isLoading) {
      return apiService.http.request(options, '/api/my/calgrant_acknowledgements');
    } else {
      $ngRedux.dispatch(fetchCalGrantsStart());
      const promise = apiService.http.request(options, '/api/my/calgrant_acknowledgements');

      promise.then(({ data }) => {
        $ngRedux.dispatch(fetchCalGrantsSuccess(data));
      });

      return promise;
    }
  };

  return { getCalGrants };
});
