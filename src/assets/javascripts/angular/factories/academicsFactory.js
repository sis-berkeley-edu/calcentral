import {
  fetchAcademicsStart,
  fetchAcademicsSuccess,
  fetchAcademicsFailure
} from 'Redux/actions/academicsActions';

angular.module('calcentral.factories').factory('academicsFactory', function(apiService, $ngRedux) {
  var urlResidency = '/api/my/residency';
  // var urlResidency = '/dummy/json/residency.json';

  const getAcademics = function(options) {
    const url = '/api/my/academics';
    // const url = '/dummy/json/academics.json';
    // const url = '/dummy/json/academics_reserved_seats.json';

    const { myAcademics } = $ngRedux.getState();

    if (myAcademics.loaded || myAcademics.isLoading) {
      return apiService.http.request(options, url);
    } else {
      $ngRedux.dispatch(fetchAcademicsStart());

      const promise = apiService.http.request(options, url);

      promise.then(({ data }) => {
        $ngRedux.dispatch(fetchAcademicsSuccess(data));
      }).catch(error => {
        $ngRedux.dispatch(fetchAcademicsFailure({ status: error.status, statusText: error.statusText }));
      });

      return promise;
    }
  };

  var getResidency = function(options) {
    return apiService.http.request(options, urlResidency);
  };

  return {
    getAcademics: getAcademics,
    getResidency: getResidency
  };
});
