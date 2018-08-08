'use strict';



/**
 * Finances Factory
 */
angular.module('calcentral.factories').factory('financesFactory', function(apiService) {
  // CARS billing data
  // var urlCars = '/dummy/json/financials.json';
  var urlCars = '/api/my/financials';
  // CS billing data
  // var urlCsBilling = '/dummy/json/billing.json';
  var urlCsBilling = '/api/campus_solutions/billing';

  var getFinances = function(options) {
    return apiService.http.request(options, urlCars);
  };

  var getCsFinances = function(options) {
    return apiService.http.request(options, urlCsBilling);
  };

  return {
    getFinances: getFinances,
    getCsFinances: getCsFinances
  };
});
