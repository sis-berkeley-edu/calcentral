'use strict';



/**
 * Serves data to Students about Advising Relationships, Action Items, and Appointments
 */
angular.module('calcentral.factories').factory('myAdvisingFactory', function(apiService, $route, $routeParams) {
  var urlStudentAdvisingInfo = '/api/advising/my_advising';
  // var urlStudentAdvisingInfo = '/dummy/json/my_advising.json';
  var urlAdvisingStudentAdvisingInfo = '/api/advising/advising/';
  // var urlAdvisingStudentAdvisingInfo = '/dummy/json/my_advising.json';

  var getStudentAdvisingInfo = function(options) {
    var url = $route.current.isAdvisingStudentLookup ? urlAdvisingStudentAdvisingInfo + $routeParams.uid : urlStudentAdvisingInfo;
    return apiService.http.request(options, url);
  };

  return {
    getStudentAdvisingInfo: getStudentAdvisingInfo
  };
});
