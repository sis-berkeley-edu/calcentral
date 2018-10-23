'use strict';

var _ = require('lodash');

angular.module('calcentral.controllers').controller('ExamResultsController', function($scope, academicRecordsFactory) {
  $scope.examResults = {
    exams: null,
    isLoading: true,
    review: null
  };

  var parseExamResults = function(response) {
    var exams = _.get(response, 'data.exams');
    var review = _.get(response, 'data.review');
    _.set($scope, 'examResults.exams', exams);
    _.set($scope, 'examResults.review', review);
  };

  var initialize = function() {
    academicRecordsFactory.getExamResultsData()
    .then(parseExamResults)
    .finally(function() {
      $scope.examResults.isLoading = false;
    });
  };

  initialize();
});
