'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * My Advising controller
 */
angular.module('calcentral.controllers').controller('MyAdvisingController', function(myAdvisingFactory, apiService, $route, $routeParams, $scope) {
  $scope.myAdvising = {
    isLoading: true
  };

  var isHaasStudent = function() {
    if ($scope.academicRoles.haasFullTimeMba ||
      $scope.academicRoles.haasEveningWeekendMba ||
      $scope.academicRoles.haasExecMba ||
      $scope.academicRoles.haasMastersFinEng ||
      $scope.academicRoles.haasMbaPublicHealth ||
      $scope.academicRoles.haasMbaJurisDoctor) {
      return true;
    }
    return false;
  };

  var loadStudentAdvisingInfo = function(response) {
    angular.extend($scope.myAdvising, _.get(response, 'data.feed'));
    $scope.myAdvising.errored = _.get(response, 'data.errored');
    $scope.showAppointmentLinks = apiService.user.profile.features.csAdvisingLinks && _.get(response, 'data.feed.links');
  };

  var loadStudentAcademicRoles = function() {
    var isAdvisingStudentLookup = $route.current.isAdvisingStudentLookup;
    $scope.academicRoles = isAdvisingStudentLookup ? $scope.targetUser.academicRoles : apiService.user.profile.academicRoles;
    $scope.showAdvisorsList = !isHaasStudent();
  };

  var loadFeeds = function() {
    myAdvisingFactory.getStudentAdvisingInfo()
      .then(loadStudentAdvisingInfo)
      .then(loadStudentAcademicRoles)
      .finally(function() {
        $scope.myAdvising.isLoading = false;
      });
  };

  loadFeeds();
});
