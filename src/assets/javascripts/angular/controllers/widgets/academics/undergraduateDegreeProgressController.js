'use strict';


var _ = require('lodash');

angular.module('calcentral.controllers').controller('UndergraduateDegreeProgressController', function(academicsService, degreeProgressFactory, apiService, $scope) {
  $scope.degreeProgress = {
    undergraduate: {
      isLoading: true
    }
  };

  var showTip = function() {
    $scope.degreeProgress.undergraduate.tipVisible = true;
    return false;
  };

  var loadDegreeProgress = function() {
    return degreeProgressFactory.getUndergraduateRequirements().then(
      function(response) {
        $scope.degreeProgress.undergraduate.progresses = _.get(response, 'data.feed.degreeProgress.progresses');
        $scope.degreeProgress.undergraduate.transferCreditReviewDeadline = _.get(response, 'data.feed.degreeProgress.transferCreditReviewDeadline');
        $scope.degreeProgress.undergraduate.links = _.get(response, 'data.feed.links');
        $scope.degreeProgress.undergraduate.errored = _.get(response, 'data.errored');
        $scope.degreeProgress.undergraduate.showCard = apiService.user.profile.features.csDegreeProgressUgrdStudent && apiService.user.profile.roles.undergrad && !academicsService.isNonDegreeSeekingSummerVisitor(apiService.user.profile.academicRoles);
        $scope.degreeProgress.undergraduate.showTip = showTip;
      }
    );
  };

  var loadInformation = function() {
    loadDegreeProgress()
      .finally(function() {
        $scope.degreeProgress.undergraduate.isLoading = false;
      });
  };

  loadInformation();
});
