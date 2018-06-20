'use strict';

var angular = require('angular');

/**
 * Transfer Credit Factory
 */
angular.module('calcentral.factories').factory('transferCreditFactory', function(apiService, $route, $routeParams) {
  var urlTransferCredit = '/api/academics/transfer_credits';
  // var urlTransferCredit = '/dummy/json/edodb_transfer_credits.json';

  var urlAdvisingTransferCredit = '/api/advising/transfer_credit/';
  // var urlAdvisingTransferCredit = '/dummy/json/edodb_transfer_credits.json';

  var getTransferCredit = function(options) {
    var url = $route.current.isAdvisingStudentLookup ? urlAdvisingTransferCredit + $routeParams.uid : urlTransferCredit;
    return apiService.http.request(options, url);
  };

  return {
    getTransferCredit: getTransferCredit
  };
});
