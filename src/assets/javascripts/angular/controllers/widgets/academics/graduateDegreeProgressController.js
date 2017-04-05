'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('GraduateDegreeProgressController', function(degreeProgressFactory, apiService, $scope) {

  $scope.degreeProgress = {
    graduate: {
      isLoading: true
    }
  };

  var loadGraduateDegreeProgress = function() {
    degreeProgressFactory.getGraduateMilestones().then(
      function(response) {
        var links = _.get(response, 'data.feed.links');
        $scope.degreeProgress.graduate.links = _.isEmpty(links) ? undefined : links;
        $scope.degreeProgress.graduate.progresses = _.get(response, 'data.feed.degreeProgress');
        $scope.degreeProgress.graduate.errored = _.get(response, 'errored');
      }
    ).finally(
      function() {
        var isHigherDegreeStudent = apiService.user.profile.roles.graduate || apiService.user.profile.roles.law;
        var isExStudentWithMilestones = apiService.user.profile.roles.exStudent && $scope.degreeProgress.graduate.progresses.length;
        $scope.degreeProgress.graduate.showCard = apiService.user.profile.features.csDegreeProgressGradStudent && (isHigherDegreeStudent || isExStudentWithMilestones);
        $scope.degreeProgress.graduate.isLoading = false;
      }
    );
  };

  loadGraduateDegreeProgress();
});
