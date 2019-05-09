import {
  fetchRegistrationsStart,
  fetchRegistrationsSuccess
} from 'Redux/actions/registrationsActions';

angular.module('calcentral.factories').factory('registrationsFactory', function(apiService, $ngRedux) {
  var getRegistrations = function(options) {
    var url = '/api/my/registrations';
    // var url = '/dummy/json/my_registrations.json'

    const { myRegistrations } = $ngRedux.getState();

    if (myRegistrations.loaded || myRegistrations.isLoading) {
      return apiService.http.request(options, url);
    } else {
      $ngRedux.dispatch(fetchRegistrationsStart());
      const promise = apiService.http.request(options, url);

      promise.then(({ data }) => {
        $ngRedux.dispatch(fetchRegistrationsSuccess(data));
      });

      return promise;
    }
  };

  return {
    getRegistrations: getRegistrations
  };
});
