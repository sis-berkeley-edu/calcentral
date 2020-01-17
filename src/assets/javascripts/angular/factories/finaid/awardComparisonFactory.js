'use strict';

/**
 * Award Comparison Factory
 */
angular
  .module('calcentral.factories')
  .factory('awardComparisonFactory', function(apiService) {
    var url = '/api/my/financial_aid/award_comparison/';

    var getAwardComparison = function(options) {
      return apiService.http.request(options, url + (options.finaidYear || ''));
    };

    return {
      getAwardComparison: getAwardComparison,
    };
  });
