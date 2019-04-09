'use strict';

var _ = require('lodash');

/**
 * Academics status, holds & blocks controller
 */
angular.module('calcentral.controllers').controller('AcademicsStatusHoldsBlocksController', function(apiService, academicsFactory, linkService, slrDeeplinkFactory, registrationsFactory, statusHoldsService, holdsFactory, calGrantsFactory, $scope, $routeParams) {
  linkService.addCurrentRouteSettings($scope);

  $scope.statusHolds = {
    isLoading: true
  };
  $scope.regStatus = {
    registrations: [],
    show: false
  };

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
      $scope.regStatus.registrations.push(registration);
    });
    if ($scope.regStatus.registrations.length) {
      $scope.regStatus.show = true;
    }
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
      message: {}
    }
  });

  var getCalResidency = academicsFactory.getResidency;
  var parseCalResidency = function(response) {
    var residency = _.get(response, 'data.residency');
    angular.merge($scope.residency, residency);
  };

  // When returning from the CalGrant Activity Guide the querystring will
  // contain refresh=true. We need to request fresh data, not using the browser
  // cache. Also, passing expireCache=true to the server to clear memcached and
  // ensure we receive the latest data immediately.
  //
  // Otherwise, pass empty options and use existing caches as usual.
  let refreshOptions = {};

  if ($routeParams.refresh) {
    refreshOptions = { refreshCache: true, params: { expireCache: true } };
  }

  var getCalGrants = function() {
    calGrantsFactory.getCalGrants(refreshOptions)
    .then(({ data: { acknowledgements, viewAllLink } }) => {
      $scope.calgrantAcknowledgements = acknowledgements;
      $scope.viewAllLink = viewAllLink;
    });
  };

  var getHolds = function() {
    return holdsFactory.getHolds(refreshOptions).then(function(response) {
      $scope.holds = _.get(response, 'data.feed.holds');
    });
  };

  var loadStatusInformation = function() {
    getCalResidency()
    .then(parseCalResidency)
    .then(getSlrDeeplink)
    .then(getRegistrations)
    .then(getCalGrants)
    .then(getHolds)
    .finally(function() {
      $scope.statusHolds.isLoading = false;
    });
  };

  loadStatusInformation();
  $scope.cnpStatusIcon = statusHoldsService.cnpStatusIcon;
  $scope.regStatusIcon = statusHoldsService.regStatusIcon;
});
