import {
  fetchRegistrationsStart,
  fetchRegistrationsSuccess,
  fetchRegistrationsFailure
} from 'Redux/actions/registrationsActions';

angular.module('calcentral.factories').factory('registrationsFactory', function(apiService, $ngRedux) {
  var getRegistrations = function(options) {
    const url = '/api/my/registrations';
    const { myRegistrations } = $ngRedux.getState();

    if (!(myRegistrations.loaded || myRegistrations.isLoading)) {
      $ngRedux.dispatch(fetchRegistrationsStart());
    }

    const promise = apiService.http.request(options, url);

    promise.then(({ data }) => {
      $ngRedux.dispatch(fetchRegistrationsSuccess(data));
    }).catch(error => {
      $ngRedux.dispatch(fetchRegistrationsFailure({ status: error.status, statusText: error.statusText }));
    });

    return promise;
  };

  return {
    getRegistrations: getRegistrations
  };
});
