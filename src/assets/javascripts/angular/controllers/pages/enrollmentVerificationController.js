'use strict';

var _ = require('lodash');
var angular = require('angular');

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
    },
    profile: apiService.user.profile
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
    $scope.enrollVerification.requestOfficialVerificationLink = _.get(response, 'data.requestUrl');
    $scope.enrollVerification.academicRoles = _.get(response, 'data.academicRoles');

    /* summarize logic for exclusive law role */
    if (_.isPlainObject($scope.enrollVerification.academicRoles)) {
      $scope.enrollVerification.academicRoles.lawExclusive = isRoleExclusive('law', $scope.enrollVerification.academicRoles);
    }

    var messages = _.get(response, 'data.messages');
    if (messages) {
      $scope.enrollVerification.messages.viewOnline = _.find(messages, {
        'messageNbr': '1'
      });
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

  loadEnrollmentVerificationFeed();
});
