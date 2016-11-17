'use strict';

var angular = require('angular');

angular.module('calcentral.factories').factory('academicRecordsFactory', function(apiService) {

  var url = '/api/campus_solutions/cs_official_transcript';
  // var url = '/dummy/json/cs_official_transcript.json';

  var getTranscriptData = function(options) {
    return apiService.http.request(options, url);
  };

  return {
    getTranscriptData: getTranscriptData
  };
});
