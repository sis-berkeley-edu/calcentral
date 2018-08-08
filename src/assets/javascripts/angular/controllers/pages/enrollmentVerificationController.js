'use strict';

var _ = require('lodash');


/**
 * Enrollment Verification Controller
 */
angular.module('calcentral.controllers').controller('EnrollmentVerificationController', function(apiService, enrollmentVerificationFactory, linkService, $scope) {
  linkService.addCurrentRouteSettings($scope);
  apiService.util.setTitle($scope.currentPage.name);

  $scope.enrollVerification = {
    isLoading: true,
    hasMessages: false,
    messages: {
      lawVerification: {},
      requestOfficial: {},
      viewOnline: {}
    }
  };
  $scope.enrollmentVerificationServices = {
    url: 'http://registrar.berkeley.edu/academic-records/verification-enrollment-degrees',
    title: 'Learn more about enrollment verification services'
  };

  var isRoleExclusive = function(roleKey, roles) {
    if (!_.get(roles, roleKey)) {
      return false;
    }
    return !_.find(roles, function(roleValue, currentRoleKey) {
      return (currentRoleKey !== roleKey && roleValue);
    });
  };

  var parseEnrollmentVerificationData = function(response) {
    var messages = _.get(response, 'data.messages');
    $scope.enrollVerification.requestOfficialVerificationLink = _.get(response, 'data.requestUrl');
    $scope.enrollVerification.lawExclusive = isRoleExclusive('law', apiService.user.profile.academicRoles.current);

    if (messages) {
      if ($scope.enrollVerification.lawExclusive) {
        $scope.enrollVerification.messages.viewOnline = _.find(messages, {
          'messageNbr': '5'
        });
      } else {
        $scope.enrollVerification.messages.viewOnline = _.find(messages, {
          'messageNbr': '1'
        });
      }
      $scope.enrollVerification.messages.requestOfficial = _.find(messages, {
        'messageNbr': '2'
      });
      $scope.enrollVerification.messages.lawVerification = _.find(messages, {
        'messageNbr': '3'
      });
      $scope.enrollVerification.hasMessages = true;
    }
  };

  var loadEnrollmentVerificationFeed = function() {
    enrollmentVerificationFactory.getEnrollmentVerificationData()
      .then(parseEnrollmentVerificationData)
      .finally(function() {
        $scope.enrollVerification.isLoading = false;
      });
  };

  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated) {
      $scope.canViewAcademics = apiService.user.profile.hasAcademicsTab;
    }
  });

  loadEnrollmentVerificationFeed();
});
