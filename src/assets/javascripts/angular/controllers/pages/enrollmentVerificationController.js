'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Enrollment Verification Controller
 */
angular.module('calcentral.controllers').controller('EnrollmentVerificationController', function(apiService, enrollmentVerificationFactory, $scope) {
  var title = 'My Enrollment Verification';
  apiService.util.setTitle(title);

  $scope.enrollmentCsDeeplink = {
    title: 'Request Other Verifications',
    backToText: 'My Academics'
  };
  $scope.enrollmentGoogleLink = {
    url: 'http://goo.gl/forms/xcYYehIBFDbDE92y1',
    title: 'Request Other Verifications'
  };
  $scope.enrollmentMessages = {
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

  var parseMessages = function(data) {
    var messages = data.data.feed.root.getMessageCatDefn;

    if (messages) {
      $scope.enrollmentMessages.messages.viewOnline = _.find(messages, {
        'messageNbr': '1'
      });
      $scope.enrollmentMessages.messages.requestOfficial = _.find(messages, {
        'messageNbr': '2'
      });
      $scope.enrollmentMessages.messages.lawVerification = _.find(messages, {
        'messageNbr': '3'
      });
      $scope.enrollmentMessages.hasMessages = true;
    }
  };

  var getDeeplink = function() {
    enrollmentVerificationFactory.getEnrollmentVerificationDeeplink()
      .then(function(data) {
        var enrollmentCsDeeplink = _.get(data, 'data.feed');
        _.merge($scope.enrollmentCsDeeplink, enrollmentCsDeeplink);
      });
  };

  var getMessages = function() {
    enrollmentVerificationFactory.getEnrollmentVerificationMessages()
      .then(parseMessages)
      .then(getDeeplink)
      .finally(function() {
        $scope.enrollmentMessages.isLoading = false;
      });
  };

  getMessages();
});
