'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Academics status, holds & blocks controller
 */
angular.module('calcentral.controllers').controller('AcademicsStatusHoldsBlocksController', function(apiService, enrollmentVerificationFactory, academicsFactory, slrDeeplinkFactory, studentAttributesFactory, registrationsFactory, statusHoldsService, $scope) {
  // Data for csHolds is pulled by the AcademicsController that
  // governs the academics template. The statusHoldsBlocks segment watches those
  // for changes in order to display the corresponding UI elements.
  $scope.statusHoldsBlocks = {};
  $scope.regStatus = {
    messages: '',
    terms: [],
    registrations: [],
    positiveIndicators: [],
    isLoading: true
  };

  $scope.$watchGroup(['(regStatus.registrations[0].summary && regStatus.registrations[0].academicCareer.code !== "UCBX")',
                      '(regStatus.registrations[1].summary && regStatus.registrations[1].academicCareer.code !== "UCBX")',
                      'api.user.profile.features.csHolds'], function(newValues) {
    var enabledSections = [];

    if (newValues[0] || newValues[1]) {
      enabledSections.push('Status');
    }

    if (newValues[2]) {
      enabledSections.push('Holds');
    }

    $scope.statusHoldsBlocks.enabledSections = enabledSections;
  });

  // Request-and-parse sequence for the Statement of Legal Residency deeplink
  var fetchSlrDeeplink = slrDeeplinkFactory.getUrl;

  var parseSlrDeeplink = function(data) {
    $scope.slr.deeplink = _.get(data, 'data.feed.root.ucSrSlrResources.ucSlrLinks.ucSlrLink');
    $scope.slr.isErrored = _.get(data, 'data.errored');
    $scope.slr.isLoading = false;
  };

  var getRegistrations = function() {
    registrationsFactory.getRegistrations()
      .then(parseRegistrations)
      .then(getStudentAttributes);
  };

  /**
   * Checks to see whether the registration is on or before Settings.terms.legacy_cutoff.
   * This code should be able to be removed by Fall 2016, when we should start getting term data exclusively from the hub.
   * There is also the possibility of the hub bringing over more than one registration for a term.
   */
  var parseRegistrations = function(data) {
    _.forOwn(data.data.terms, function(value, key) {
      if (key === 'current' || key === 'next') {
        if (value) {
          $scope.regStatus.terms.push(value);
        }
      }
    });
    _.forEach($scope.regStatus.terms, function(term) {
      var regStatus = data.data.registrations[term.id];

      if (regStatus && regStatus[0]) {
        _.merge(regStatus[0], term);
        regStatus[0].isSummer = _.startsWith(term.name, 'Summer');

        if (regStatus[0].isLegacy) {
          $scope.regStatus.registrations.push(statusHoldsService.parseLegacyTerm(regStatus[0]));
        } else {
          $scope.regStatus.registrations.push(statusHoldsService.parseCsTerm(regStatus[0]));
        }
      }
    });

    return;
  };

  var getStudentAttributes = function() {
    studentAttributesFactory.getStudentAttributes()
    .then(parseStudentAttributes);
  };

  var parseStudentAttributes = function(data) {
    var studentAttributes = _.get(data, 'data.feed.student.studentAttributes.studentAttributes');
    // Strip all positive student indicators from student attributes feed.
    _.forEach(studentAttributes, function(attribute) {
      if (_.startsWith(attribute.type.code, '+')) {
        $scope.regStatus.positiveIndicators.push(attribute);
      }
    });

    statusHoldsService.matchTermIndicators($scope.regStatus.positiveIndicators, $scope.regStatus.registrations);
    $scope.hasShownRegistrations = statusHoldsService.checkShownRegistrations($scope.regStatus.registrations);
  };

  var getMessages = function() {
    enrollmentVerificationFactory.getEnrollmentVerificationMessages()
      .then(function(data) {
        var messages = _.get(data, 'data.feed.root.getMessageCatDefn');
        if (messages) {
          $scope.regStatus.messages = {};
          _.merge($scope.regStatus.messages, statusHoldsService.getRegStatusMessages(messages));
        }
      });
  };

  var getSlrDeeplink = function() {
    // Users in 'view-as' mode are not allowed to access the student's SLR link.
    // Guard here to keep this function self-contained.
    if (apiService.user.profile.actingAsUid || !apiService.user.profile.canSeeCSLinks) {
      return;
    }

    angular.extend($scope, {
      slr: {
        backToText: 'My Academics',
        deeplink: false,
        isErrored: false,
        isLoading: true
      }
    });

    fetchSlrDeeplink().then(parseSlrDeeplink);
  };

  // Request-and-parse sequence on the student feed for California Residency status.
  angular.extend($scope, {
    residency: {
      isLoading: true,
      message: {}
    }
  });

  var getCalResidency = academicsFactory.getResidency;
  var parseCalResidency = function(data) {
    var residency = _.get(data, 'data.residency');
    angular.merge($scope.residency, residency);
  };

  $scope.showCNP = function(registration) {
    return statusHoldsService.showCNP(registration);
  };

  var loadStatusInformation = function() {
    getCalResidency()
    .then(parseCalResidency)
    .then(getSlrDeeplink)
    .then(getRegistrations)
    .then(getMessages)
    .finally(function() {
      $scope.residency.isLoading = false;
      $scope.regStatus.isLoading = false;
    });
  };

  loadStatusInformation();
});
