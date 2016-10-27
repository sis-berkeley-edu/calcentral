'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('DegreeProgressController', function(degreeProgressFactory, $scope) {

  $scope.degreeProgressGraduate = {
    isLoading: true
  };

  var loadDegreeProgress = function() {
    degreeProgressFactory.getDegreeProgress()
      .then(function(data) {
        $scope.degreeProgressGraduate.progresses = _.get(data, 'data.feed.degreeProgress');
        $scope.degreeProgressGraduate.links = _.get(data, 'data.feed.links');
        $scope.degreeProgressGraduate.errored = _.get(data, 'errored');
      })
      .finally(function() {
        $scope.degreeProgressGraduate.isLoading = false;
      });
  };

  loadDegreeProgress();
});
