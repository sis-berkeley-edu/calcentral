'use strict';

var _ = require('lodash');

angular.module('calcentral.services').service('finaidService', function($rootScope, userService) {
  var options = {
    finaidYear: false
  };

  var findFinaidYear = function(aidYears, finaidYearId) {
    return _.find(aidYears, function(finaidYear) {
      return finaidYear.id === finaidYearId;
    });
  };

  /**
   * @param {Array} aidYears Array of aidYear objects
   * @param {String} finaidYearId e.g. 2015
   * @return {Boolean} true if combination exists, otherwise false
   */
  var combinationExists = function(aidYears, finaidYearId) {
    return !!findFinaidYear(aidYears, finaidYearId);
  };

  var findDefaultFinaidYear = function(aidYears) {
    return _.find(aidYears, function(aidYear) {
      return aidYear.default;
    });
  };

  var setDefaultFinaidYear = function(aidYears, finaidYearId) {
    if (aidYears) {
      if (finaidYearId) {
        if (combinationExists(aidYears, finaidYearId)) {
          setFinaidYear(findFinaidYear(aidYears, finaidYearId));
        } else {
          userService.redirectToPage('finances');
        }
      } else {
        // If no aid year has been selected before, select the default one
        var aidYear = findDefaultFinaidYear(aidYears);

        // If no default is found, use the first one
        if (!aidYear) {
          aidYear = aidYears[0];
        }

        setFinaidYear(aidYear);
      }
    }
    return options.finaidYear;
  };

  var setFinaidYear = function(aidYear) {
    options.finaidYear = aidYear;
    if (options.finaidYear) {
      $rootScope.$broadcast('calcentral.custom.api.finaid.finaidYear');
    }
  };

  return {
    combinationExists: combinationExists,
    findFinaidYear: findFinaidYear,
    options: options,
    setDefaultFinaidYear: setDefaultFinaidYear,
    setFinaidYear: setFinaidYear
  };
});
