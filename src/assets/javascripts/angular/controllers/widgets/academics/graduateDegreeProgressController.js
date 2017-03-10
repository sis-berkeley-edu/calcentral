'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('GraduateDegreeProgressController', function(degreeProgressFactory, $scope) {

  $scope.degreeProgress = {
    graduate: {
      isLoading: true
    }
  };

  var loadGraduateDegreeProgress = function() {
    degreeProgressFactory.getGraduateMilestones()
      .then(function(data) {
        $scope.degreeProgress.graduate.progresses = _.get(data, 'data.feed.degreeProgress');
        $scope.degreeProgress.graduate.links = _.get(data, 'data.feed.links');
        $scope.degreeProgress.graduate.errored = _.get(data, 'errored');
      })
      .finally(function() {
        $scope.degreeProgress.graduate.isLoading = false;
      });
  };

  loadGraduateDegreeProgress();
});
