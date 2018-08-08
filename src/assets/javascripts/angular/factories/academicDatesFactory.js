'use strict';



/**
 * Academics Factory
 */
angular.module('calcentral.factories').factory('academicDatesFactory', function(apiService) {
  // var url = '/api/my/academic_dates';
  var url = '/dummy/json/academic_dates.json';

  var getAcademicDates = function(options) {
    return apiService.http.request(options, url);
  };

  return {
    getAcademicDates: getAcademicDates
  };
});
