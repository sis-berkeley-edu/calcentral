'use strict';

var angular = require('angular');

angular.module('calcentral.factories').factory('academicRecordsFactory', function(apiService) {

  var url = '/api/my/academic_records';
  // var url = '/dummy/json/my_academic_records.json';

  var getTranscriptData = function(options) {
    return apiService.http.request(options, url);
  };

  return {
    getTranscriptData: getTranscriptData
  };
});
