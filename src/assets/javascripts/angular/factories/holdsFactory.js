import {
  fetchHoldsStart,
  fetchHoldsSuccess
} from 'Redux/actions/holdsActions';

angular.module('calcentral.factories').factory('holdsFactory', function(apiService, $route, $ngRedux, $routeParams) {
  var getHolds = function(options) {
    if ($route.current.isAdvisingStudentLookup) {
      const url = `/api/advising/holds/${$routeParams.uid}`;
      // var urlAdvisingStudentHolds = '/dummy/json/holds_present.json';

      return apiService.http.request(options, url);
    } else {
      const url = '/api/my/holds';
      // var urlHolds = '/dummy/json/holds_empty.json';
      // var urlHolds = '/dummy/json/holds_errored.json';
      // var urlHolds = '/dummy/json/holds_present.json';

      const { myHolds } = $ngRedux.getState();

      if (myHolds.loaded || myHolds.isLoading) {
        return apiService.http.request(options, url);
      } else {
        $ngRedux.dispatch(fetchHoldsStart());
        const promise = apiService.http.request(options, url);

        promise.then(({ data }) => {
          $ngRedux.dispatch(fetchHoldsSuccess(data.feed.holds));
        });

        return promise;
      }
    }
  };

  return {
    getHolds: getHolds
  };
});
