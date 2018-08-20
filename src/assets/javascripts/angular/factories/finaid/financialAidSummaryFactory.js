'use strict';

var angular = require('angular');

/**
 * Financial Aid Summary Factory
 */
angular.module('calcentral.factories').factory('financialAidSummaryFactory', function(apiService) {
  var url = '/api/my/financial_aid_summary/';

  var getFinancialAidSummary = function(options) {
    return apiService.http.request(options, url + options.aidYear);
  };

  return {
    getFinancialAidSummary: getFinancialAidSummary
  };
});
