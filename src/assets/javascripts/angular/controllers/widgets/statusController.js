'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Status controller
 */
angular.module('calcentral.controllers').controller('StatusController', function(academicStatusFactory, activityFactory, apiService, statusHoldsService, badgesFactory, financesFactory, registrationsFactory, $http, $scope, $q) {
  $scope.finances = {};
  $scope.regStatus = {
    hasData: false,
    registrations: [],
    isLoading: true
  };

  // Keep track on whether the status has been loaded or not
  var hasLoaded = false;

  var loadCarsFinances = function(response) {
    if (response.data && response.data.summary) {
      $scope.finances.carsFinances = response.data.summary;
    }
  };

  var loadCsFinances = function(response) {
    if (_.get(response, 'data.feed.summary')) {
      $scope.finances.csFinances = response.data.feed.summary;
    }
  };

  var parseFinances = function() {
    $scope.totalPastDueAmount = 0;
    $scope.minimumAmountDue = 0;
    var cars = {
      pastDue: 0,
      minDue: 0
    };
    var cs = {
      pastDue: 0,
      minDue: 0
    };

    if (!$scope.finances.carsFinances && !$scope.finances.csFinances) {
      return;
    }
    if ($scope.finances.carsFinances) {
      cars = {
        pastDue: $scope.finances.carsFinances.totalPastDueAmount,
        minDue: $scope.finances.carsFinances.minimumAmountDue
      };
      $scope.totalPastDueAmount += cars.pastDue;
      $scope.minimumAmountDue += cars.minDue;
    }
    if ($scope.finances.csFinances) {
      cs = {
        pastDue: $scope.finances.csFinances.pastDueAmount,
        minDue: $scope.finances.csFinances.amountDueNow
      };
      $scope.totalPastDueAmount += cs.pastDue;
      $scope.minimumAmountDue += cs.minDue;
    }
    if (cars.pastDue > 0 || cs.pastDue > 0) {
      $scope.count++;
      $scope.hasAlerts = true;
    } else if (cars.minDue > 0 || cs.minDue > 0) {
      $scope.count++;
      $scope.hasWarnings = true;
    }

    if ($scope.minimumAmountDue) {
      $scope.hasBillingData = true;
    }
  };

  var parseRegistrations = function(response) {
    var registrations = _.get(response, 'data.registrations');
    _.forEach(registrations, function(registration) {
      if (_.get(registration, 'showRegStatus')) {
        $scope.regStatus.registrations.push(registration);
      }
    });

    if (registrations.length) {
      _.forEach(registrations, function(registration) {
        var registrationStatus = _.get(registration, 'regStatus.summary');
        if (registrationStatus !== 'Officially Registered') {
          $scope.regStatus.hasData = true;
        }
      });
    }
  };

  var parseRegistrationCounts = function() {
    _.forEach($scope.regStatus.registrations, function(registration) {
      var positiveIndicators = _.get(registration, 'positiveIndicators');
      var indicatorTypes = [];
      var career = _.get(registration, 'academicCareer.code');
      _.forEach(positiveIndicators, function(indicator) {
        var indicatorType = _.get(indicator, 'type.code');
        indicatorTypes.push(indicatorType);
      });

      // Count for registration status
      if (registration.regStatus.summary !== 'Officially Registered') {
        $scope.count++;
        $scope.hasAlerts = true;
      }
      // Count for CNP status.  Per design, we do not want an alert for CNP if a student is "Not Enrolled" or "Officially Registered".
      if (registration.regStatus.summary === 'Not Officially Registered') {
        if (!_.includes(indicatorTypes, '+ROP') && !_.includes(indicatorTypes, '+R99') && registration.termFlags.pastFinancialDisbursement) {
          if ((career === 'UGRD') && !registration.termFlags.pastClassesStart) {
            $scope.count++;
            $scope.hasAlerts = true;
          }
          if ((career !== 'UGRD') && !registration.pastAddDrop) {
            $scope.count++;
            $scope.hasAlerts = true;
          }
        }
      }
    });
  };

  var loadHolds = function() {
    var deferred;

    if (!apiService.user.profile.features.csHolds ||
      !(apiService.user.profile.roles.student || apiService.user.profile.roles.applicant)) {
      deferred = $q.defer();
      deferred.resolve();
      return deferred.promise;
    }
    return academicStatusFactory.getHolds().then(
      function(parsedHolds) {
        var holdsCount;
        if (parsedHolds.isError) {
          $scope.holds = {
            errored: true
          };
          $scope.count++;
          $scope.hasWarnings = true;
        } else {
          $scope.holds = _.get(parsedHolds, 'holds');
          holdsCount = _.get(parsedHolds, 'holds.length');
          $scope.count += holdsCount;
          $scope.hasAlerts = (holdsCount > 0);
        }
      }
    );
  };

  var finishLoading = function() {
    // Hides the spinner
    $scope.statusLoading = '';
  };

  $scope.cnpStatusIcon = statusHoldsService.cnpStatusIcon;

  /**
   * Listen for this event in order to make a refresh request which updates the
   * displayed `api.user.profile.firstName` in the gear_popover.
   */
  $scope.$on('calcentral.custom.api.preferredname.update', function() {
    apiService.user.fetch({
      refreshCache: true
    });
  });

  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated && !hasLoaded) {
      // Make sure to only load this once
      hasLoaded = true;

      // Set the error count to 0
      $scope.count = 0;
      $scope.hasAlerts = false;
      $scope.hasWarnings = false;

      // We use this to show the spinner.
      if (!apiService.user.profile.delegateActingAsUid && !apiService.user.profile.advisorActingAsUid) {
        $scope.statusLoading = 'Process';
      }

      // Will contain loadError flag if image cannot be fetched.
      $scope.photo = {};

      // Get all the necessary data from the different factories
      var getRegistrations = registrationsFactory.getRegistrations().then(parseRegistrations);
      var statusGets = [loadHolds(), getRegistrations];

      // Only fetch financial data for delegates who have been given explicit permssion.
      var includeFinancial = (!apiService.user.profile.delegateActingAsUid || apiService.user.profile.canActOnFinances);
      if (includeFinancial) {
        var getCarsFinances = financesFactory.getFinances().then(loadCarsFinances);
        var getCsFinances = financesFactory.getCsFinances().then(loadCsFinances);
        statusGets.push(getCarsFinances, getCsFinances);
      }

      // Make sure to hide the spinner when everything is loaded
      $q.all(statusGets).then(function() {
        parseRegistrationCounts();
        if (includeFinancial) {
          parseFinances();
        }
      }).then(finishLoading);
    }
  });
});
