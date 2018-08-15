'use strict';

angular.module('calcentral.services').service('financialsService', function(analyticsService) {
  var printPage = function() {
    analyticsService.sendEvent('Finances', 'Print');
    window.print();
  };

  /**
   * Create JavaScript date object based on the input from the datepicker
   * @param {String} date Date as a string input
   * @return {Object | String} Empty string when no date & date object when there is a date
   */
  var createDateValues = function(date) {
    var mmddyyRegex = /^(0[1-9]|1[012])[\/](0[1-9]|[12][0-9]|3[01])[\/]((19|20)\d\d)$/;

    if (date) {
      var dateValues = date.match(mmddyyRegex);
      return new Date(dateValues[3], parseInt(dateValues[1], 10) - 1, dateValues[2]);
    }
    return '';
  };

  // Expose methods
  return {
    printPage: printPage,
    createDateValues: createDateValues
  };
});
