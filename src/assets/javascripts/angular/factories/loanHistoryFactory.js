'use strict';

angular.module('calcentral.factories').factory('loanHistoryFactory', function(apiService) {
  var urlAidYears = 'api/my/loan_history_aid_years';
  var urlCumulative = 'api/my/loan_history_cumulative';
  var urlInactive = 'api/my/loan_history_inactive';
  var urlSummary = 'api/my/loan_history_summary';

  var getAidYears = function(options) {
    return apiService.http.request(options, urlAidYears);
  };

  var getCumulative = function(options) {
    return apiService.http.request(options, urlCumulative);
  };

  var getInactive = function(options) {
    return apiService.http.request(options, urlInactive);
  };

  var getSummary = function(options) {
    return apiService.http.request(options, urlSummary);
  };

  return {
    getAidYears: getAidYears,
    getCumulative: getCumulative,
    getInactive: getInactive,
    getSummary: getSummary
  };

});

