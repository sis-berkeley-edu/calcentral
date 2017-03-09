'use strict';

var _ = require('lodash');
var angular = require('angular');

angular.module('calcentral.services').service('finaidService', function($rootScope) {
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
   */
  var combinationExists = function(data, finaidYearId) {
    return !!findFinaidYear(data, finaidYearId);
  };

  /**
   * Find the aid year which has the default=true attribute
   */
  var findDefaultFinaidYear = function(finaidYears) {
    return _.find(finaidYears, function(finaidYear) {
      return finaidYear.default;
    });
  };

  /**
   * Set the default Finaid year
   */
  var setDefaultFinaidYear = function(data, finaidYearId) {
    if (data && data.finaidSummary && data.finaidSummary.finaidYears) {
      if (finaidYearId) {
        setFinaidYear(findFinaidYear(data, finaidYearId));
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
    $rootScope.$broadcast('calcentral.custom.api.finaid.finaidYear');
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
