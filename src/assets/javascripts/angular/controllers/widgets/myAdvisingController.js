'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * My Advising controller
 */
angular.module('calcentral.controllers').controller('MyAdvisingController', function(academicsFactory, advisingFactory, myAdvisingFactory, userService, $route, $routeParams, $scope, $q) {
  $scope.myAdvising = {
    isLoading: true,
    roles: {}
  };

  var isHaasStudent = function() {
    var roles = $scope.myAdvising.roles;
    if (roles.haasFullTimeMba ||
          roles.haasEveningWeekendMba ||
          roles.haasExecMba ||
          roles.haasMastersFinEng ||
          roles.haasMbaPublicHealth ||
          roles.haasMbaJurisDoctor) {
      return true;
    }
    return false;
  };

  var loadFeeds = function() {
    var academicsSource = $route.current.isAdvisingStudentLookup ? advisingFactory.getStudentAcademics : academicsFactory.getAcademics;
    var options = {
      uid: $routeParams.uid
    };

    var getAcademics = academicsSource(options).then(function(response) {
      angular.extend($scope.myAdvising.roles, _.get(response, 'data.collegeAndLevel.roles'));
    });

    var getAdvisingInfo = myAdvisingFactory.getStudentAdvisingInfo().then(function(response) {
      angular.extend($scope.myAdvising, _.get(response, 'data.feed'));
      $scope.myAdvising.errored = _.get(response, 'data.errored');
    });

    $q.all([getAcademics, getAdvisingInfo]).then(function() {
      $scope.myAdvising.isLoading = false;
    });
  };

  $scope.showAdvisorsList = function() {
    return !isHaasStudent();
  };

  $scope.showAppointmentLinks = function() {
    if ($scope.myAdvising.links) {
      if (userService.profile.features.csAdvisingLinks) {
        return true;
      } else {
        if ($scope.myAdvising.roles.ugrdUrbanStudies) {
          return true;
        }
      }
    }
    return false;
  };

  loadFeeds();
});
