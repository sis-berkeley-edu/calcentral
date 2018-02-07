'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * My Advising controller
 */
angular.module('calcentral.controllers').controller('MyAdvisingController', function(myAdvisingFactory, advisingFactory, apiService, $route, $routeParams, $scope, $q) {
  $scope.myAdvising = {
    isLoading: true
  };

  var isHaasStudent = function(academicRoles) {
    if (academicRoles.haasFullTimeMba ||
      academicRoles.haasEveningWeekendMba ||
      academicRoles.haasExecMba ||
      academicRoles.haasMastersFinEng ||
      academicRoles.haasMbaPublicHealth ||
      academicRoles.haasMbaJurisDoctor) {
      return true;
    }
    return false;
  };

  var loadStudentAdvisingInfo = function(response) {
    angular.extend($scope.myAdvising, _.get(response, 'data.feed'));
    $scope.myAdvising.errored = _.get(response, 'data.errored');
    $scope.showAppointmentLinks = apiService.user.profile.features.csAdvisingLinks && _.get(response, 'data.feed.links');
  };

  var getStudentAcademicRoles = function() {
    var params;
    var deferred;
    if ($route.current.isAdvisingStudentLookup) {
      params = {
        uid: $routeParams.uid
      };
      return advisingFactory.getStudent(params);
    } else {
      deferred = $q.defer();
      deferred.resolve({
        data: apiService.user.profile
      });
      return deferred.promise;
    }
  };

  var loadStudentAcademicRoles = function(response) {
    var academicRoles = _.get(response, 'data.academicRoles');
    $scope.academicRoles = academicRoles;
    $scope.showAdvisorsList = !isHaasStudent(academicRoles);
  };

  var loadFeeds = function() {
    myAdvisingFactory.getStudentAdvisingInfo()
      .then(loadStudentAdvisingInfo)
      .then(getStudentAcademicRoles)
      .then(loadStudentAcademicRoles)
      .finally(function() {
        $scope.myAdvising.isLoading = false;
      });
  };

  loadFeeds();
});
