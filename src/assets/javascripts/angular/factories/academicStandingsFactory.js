import {
  fetchStandingsSuccess
} from 'Redux/actions/standingsActions';

angular.module('calcentral.factories').factory('academicStandingsFactory', function(apiService, $route, $routeParams, $ngRedux) {
  var getStandings = function(options) {
    if ($route.current.isAdvisingStudentLookup) {
      // const url = '/dummy/json/standings_present.json';
      const url = '/api/advising/standings/' + $routeParams.uid;

      return apiService.http.request(options, url);
    } else {
      const url = '/api/my/standings';
      // var urlStandings = '/dummy/json/standings_present.json';

      const promise = apiService.http.request(options, url);

      promise.then((response) => {
        $ngRedux.dispatch(fetchStandingsSuccess(response.data.feed));
      });

      return promise;
    }
  };

  return {
    getStandings: getStandings
  };
});
