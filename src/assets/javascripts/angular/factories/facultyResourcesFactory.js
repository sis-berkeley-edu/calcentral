'use strict';

angular.module('calcentral.factories').factory('facultyResourcesFactory', function(apiService) {
  var urlFacultyResources = '/api/campus_solutions/faculty_resources';
  // var urlFacultyResources = '/dummy/json/faculty_resources.json';

  var getFacultyResources = function(options) {
    return apiService.http.request(options, urlFacultyResources);
  };

  return {
    getFacultyResources: getFacultyResources
  };
});
