'use strict';

/**
 * Financial Aid Factory
 */
angular.module('calcentral.factories').factory('finaidFactory', function(apiService) {
  var urlAwards = '/api/campus_solutions/financial_aid_funding_sources';
  // var urlAwards = '/dummy/json/financial_aid_funding_sources.json';

  var urlAwardsTerm = '/api/campus_solutions/financial_aid_funding_sources_term';

  var urlCompareAwardsCurrent = '/api/campus_solutions/financial_aid_compare_awards_current';
  var urlCompareAwardsList = '/api/campus_solutions/financial_aid_compare_awards_list';
  var urlCompareAwardsPrior = '/api/campus_solutions/financial_aid_compare_awards_prior';

  var urlFinaidYear = '/api/campus_solutions/financial_aid_data';
  // var urlFinaidYear = '/dummy/json/financial_aid_data.json';
  // var urlFinaidYear = '/dummy/json/financial_aid_data_summer_only.json';
  var urlFinancialAidSummary = 'api/my/financial_aid_summary';
  var urlSummary = '/api/my/aid_years';
  // var urlSummary = '/dummy/json/finaid_summary.json';

  var getAwards = function(options) {
    return apiService.http.request(options, urlAwards + '?aid_year=' + options.finaidYearId);
  };
  var getAwardsTerm = function(options) {
    return apiService.http.request(options, urlAwardsTerm + '?aid_year=' + options.finaidYearId);
  };

  var getAwardCompareCurrent = function(options) {
    return apiService.http.request(options, urlCompareAwardsCurrent +
      '?aid_year=' + options.finaidYearId
    );
  };
  var getAwardCompareList = function(options) {
    return apiService.http.request(options, urlCompareAwardsList +
      '?aid_year=' + options.finaidYearId
    );
  };
  var getAwardComparePrior = function(options) {
    return apiService.http.request(options, urlCompareAwardsPrior +
      '?aid_year=' + options.finaidYearId +
      '&date=' + options.date
    );
  };

  var getFinaidYearInfo = function(options) {
    return apiService.http.request(options, urlFinaidYear + '?aid_year=' + options.finaidYearId);
  };

  var getFinancialAidSummary = function(options) {
    return apiService.http.request(options, urlFinancialAidSummary);
  };

  var getSummary = function(options) {
    return apiService.http.request(options, urlSummary);
  };

  return {
    getAwards: getAwards,
    getAwardsTerm: getAwardsTerm,
    getAwardCompareCurrent: getAwardCompareCurrent,
    getAwardCompareList: getAwardCompareList,
    getAwardComparePrior: getAwardComparePrior,
    getFinaidYearInfo: getFinaidYearInfo,
    getFinancialAidSummary: getFinancialAidSummary,
    getSummary: getSummary
  };
});
