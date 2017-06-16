'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Academics status, holds & blocks controller
 */
angular.module('calcentral.controllers').controller('AcademicsStatusHoldsBlocksController', function(apiService, academicsFactory, linkService, slrDeeplinkFactory, registrationsFactory, statusHoldsService, $scope) {
  linkService.addCurrentRouteSettings($scope);

  // Data for csHolds is pulled by the AcademicsController that
  // governs the academics template. The statusHoldsBlocks segment watches those
  // for changes in order to display the corresponding UI elements.
  $scope.statusHoldsBlocks = {};
  $scope.regStatus = {
    registrations: [],
    isLoading: true
  };

  $scope.$watchGroup(['regStatus.registrations.length', 'api.user.profile.features.csHolds'], function(newValues) {
    var enabledSections = [];

    if (newValues[0]) {
      enabledSections.push('Status');
    }

    if (newValues[1]) {
      enabledSections.push('Holds');
    }

    $scope.statusHoldsBlocks.enabledSections = enabledSections;
  });

  // Request-and-parse sequence for the Statement of Legal Residency deeplink
  var fetchSlrDeeplink = slrDeeplinkFactory.getUrl;

  var parseSlrDeeplink = function(response) {
    $scope.slr.deeplink = _.get(response, 'data.feed.root.ucSrSlrResources.ucSlrLinks.ucSlrLink');
    $scope.slr.isErrored = _.get(response, 'data.errored');
    $scope.slr.isLoading = false;
  };

  var getRegistrations = function() {
    registrationsFactory.getRegistrations()
      .then(parseRegistrations);
  };
  var parseRegistrations = function(response) {
    var registrations = _.get(response, 'data.registrations');
    _.forEach(registrations, function(registration) {
      if (_.get(registration, 'showRegStatus')) {
        $scope.regStatus.registrations.push(registration);
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
  var parseCalResidency = function(response) {
    var residency = _.get(response, 'data.residency');
    angular.merge($scope.residency, residency);
  };

  var loadStatusInformation = function() {
    getCalResidency()
    .then(parseCalResidency)
    .then(getSlrDeeplink)
    .then(getRegistrations)
    .finally(function() {
      $scope.residency.isLoading = false;
      $scope.regStatus.isLoading = false;
    });
  };

  loadStatusInformation();
  $scope.cnpStatusIcon = statusHoldsService.cnpStatusIcon;
  $scope.regStatusIcon = statusHoldsService.regStatusIcon;
});
