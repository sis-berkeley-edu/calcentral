'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Enrollment Verification Controller
 */
angular.module('calcentral.controllers').controller('EnrollmentVerificationController', function(apiService, csLinkFactory, enrollmentVerificationFactory, linkService, $scope) {
  linkService.addCurrentRouteSettings($scope);
  apiService.util.setTitle($scope.currentPage.name);

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

  var getCsLink = function() {
    csLinkFactory.getLink({
      urlId: 'UC_CX_SS_ENRL_VER_REQ'
    }).then(
      function successCallback(response) {
        $scope.requestOfficialVerificationLink = _.get(response, 'data.link');
      },
      function errorCallback() {
        $scope.requestOfficialVerificationLink = null;
      }
    );
  };

  var getMessages = function() {
    enrollmentVerificationFactory.getEnrollmentVerificationMessages()
      .then(parseMessages)
      .then(getCsLink)
      .finally(function() {
        $scope.enrollmentMessages.isLoading = false;
      });
  };

  getMessages();
});
