'use strict';

var _ = require('lodash');

angular.module('calcentral.services').service('finaidService', function($rootScope, userService) {
  var options = {
    finaidYear: false
  };

  var findFinaidYear = function(data, finaidYearId) {
    return _.find(data.finaidSummary.finaidYears, function(finaidYear) {
      return finaidYear.id === finaidYearId;
    });
  };

  /**
   * See whether the finaid year option combination exists
   * @param {Object} data Summary data
   * @param {String} finaidYearId e.g. 2015
   * @return {Boolean} true if combination exists, otherwise false
   */
  var combinationExists = function(data, finaidYearId) {
    return !!findFinaidYear(data, finaidYearId);
  };

  var findDefaultFinaidYear = function(finaidYears) {
    return _.find(finaidYears, function(finaidYear) {
      return finaidYear.default;
    });
  };

  var setDefaultFinaidYear = function(data, finaidYearId) {
    if (data && data.finaidSummary && data.finaidSummary.finaidYears) {
      if (finaidYearId) {
        if (combinationExists(data, finaidYearId)) {
          setFinaidYear(findFinaidYear(data, finaidYearId));
        } else {
          userService.redirectToPage('finances');
        }
      } else {
        // If no aid year has been selected before, select the default one
        var finaidYear = findDefaultFinaidYear(data.finaidSummary.finaidYears);

        // If no default is found, use the first one
        if (!finaidYear) {
          finaidYear = data.finaidSummary.finaidYears[0];
        }

        setFinaidYear(finaidYear);
      }
    }
    return options.finaidYear;
  };

  var setFinaidYear = function(finaidYear) {
    options.finaidYear = finaidYear;
    if (options.finaidYear) {
      $rootScope.$broadcast('calcentral.custom.api.finaid.finaidYear');
    }
  };

  // Expose the methods
  return {
    combinationExists: combinationExists,
    findFinaidYear: findFinaidYear,
    options: options,
    setDefaultFinaidYear: setDefaultFinaidYear,
    setFinaidYear: setFinaidYear
  };
});
