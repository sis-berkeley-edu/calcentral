'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * My Advising controller
 */
angular.module('calcentral.controllers').controller('MyAdvisingController', function(academicsFactory, advisingFactory, myAdvisingFactory, $route, $routeParams, $scope, $q) {
  $scope.myAdvising = {
    isLoading: true,
    backToText: 'My Academics',
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

  $scope.showAdvisorsList = function() {
    return !isHaasStudent() ? true : false;
  };

  var loadFeeds = function() {
    var academicsSource = $route.current.isAdvisingStudentLookup ? advisingFactory.getStudentAcademics : academicsFactory.getAcademics;
    var options = {
      uid: $routeParams.uid
    };

    var getAcademics = academicsSource(options).then(function(data) {
      angular.extend($scope.myAdvising.roles, _.get(data, 'data.collegeAndLevel.roles'));
    });
    var getAdvisingInfo = myAdvisingFactory.getStudentAdvisingInfo().then(function(data) {
      angular.extend($scope.myAdvising, _.get(data, 'data.feed'));
      $scope.myAdvising.errored = _.get(data, 'data.errored');
    });

    $q.all([getAcademics, getAdvisingInfo]).then(function() {
      $scope.myAdvising.isLoading = false;
    });
  };

  loadFeeds();
});
