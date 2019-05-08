import {
  fetchTransferCreditStart,
  fetchTransferCreditSuccess,
  fetchTransferCreditFailure
} from 'Redux/actions/transferCreditActions';

/**
 * Transfer Credit Factory
 */
angular.module('calcentral.factories').factory('transferCreditFactory', function(apiService, $route, $routeParams, $ngRedux) {
  // var urlAdvisingTransferCredit = '/dummy/json/edodb_transfer_credits.json';

  var getTransferCredit = function(options) {
    if ($route.current.isAdvisingStudentLookup) {
      const url = '/api/advising/transfer_credit/';
      return apiService.http.request(options, url);
    } else {
      const url = '/api/academics/transfer_credits';
      const { myTransferCredit } = $ngRedux.getState();

      if (myTransferCredit.loaded || myTransferCredit.isLoading) {
        return apiService.http.request(options, url);
      } else {
        $ngRedux.dispatch(fetchTransferCreditStart());

        const promise = apiService.http.request(options, url);

        promise.then(({ data }) => {
          $ngRedux.dispatch(fetchTransferCreditSuccess(data));
        }).catch(error => {
          $ngRedux.dispatch(fetchTransferCreditFailure({ status: error.status, statusText: error.statusText }));
        });

        return promise;
      }
    }
  };

  return {
    getTransferCredit: getTransferCredit
  };
});
