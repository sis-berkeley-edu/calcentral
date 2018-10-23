'use strict';

angular.module('calcentral.factories').factory('academicRecordsFactory', function(apiService) {
  var urlAcademicRecords = '/api/my/academic_records';
  var urlHasExamResults = '/api/academics/has_exam_results';
  var urlExamResultsData = '/api/academics/exam_results';
  // var urlAcademicRecords = '/dummy/json/my_academic_records.json';
  // var urlHasExamResults = '/dummy/json/has_exam_results.json';
  // var urlExamResultsData = '/dummy/json/exam_results.json';

  var getTranscriptData = function(options) {
    return apiService.http.request(options, urlAcademicRecords);
  };

  var getExamResultsExists = function(options) {
    return apiService.http.request(options, urlHasExamResults);
  };

  var getExamResultsData = function(options) {
    return apiService.http.request(options, urlExamResultsData);
  };

  return {
    getExamResultsData: getExamResultsData,
    getExamResultsExists: getExamResultsExists,
    getTranscriptData: getTranscriptData
  };
});
