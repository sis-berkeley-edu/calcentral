'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Status controller
 */
angular.module('calcentral.controllers').controller('StatusController', function(academicStatusFactory, activityFactory, apiService, statusHoldsService, badgesFactory, financesFactory, registrationsFactory, studentAttributesFactory, $http, $scope, $q) {
  $scope.finances = {};
  $scope.regStatus = {
    terms: [],
    registrations: [],
    positiveIndicators: [],
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
    _.forOwn(response.data.terms, function(value, key) {
      if (key === 'current' || key === 'next') {
        if (value) {
          $scope.regStatus.terms.push(value);
        }
      }
    });
    _.forEach($scope.regStatus.terms, function(term) {
      var regStatus = response.data.registrations[term.id];

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

    if (_.first($scope.regStatus.registrations)) {
      $scope.hasRegistrationData = true;
    }
    return;
  };

  var parseStudentAttributes = function(response) {
    var studentAttributes = _.get(response, 'data.feed.student.studentAttributes.studentAttributes');
    // Strip all positive student indicators from student attributes feed.
    _.forEach(studentAttributes, function(attribute) {
      if (_.startsWith(attribute.type.code, '+')) {
        $scope.regStatus.positiveIndicators.push(attribute);
      }
    });
  };

  var parseRegistrationCounts = function() {
    _.forEach($scope.regStatus.registrations, function(registration) {
      if (!registration.isShown) {
        return;
      }
      // Count for registration status
      if (registration.summary !== 'Officially Registered') {
        $scope.count++;
        $scope.hasAlerts = true;
      }
      // Count for CNP status.  Per design, we do not want an alert for CNP if a student is "Not Enrolled" or "Officially Registered".
      if (registration.summary === 'Not Officially Registered') {
        if (!registration.positiveIndicators.ROP && !registration.positiveIndicators.R99 && registration.pastFinancialDisbursement) {
          if ((registration.academicCareer.code === 'UGRD') && (!registration.pastClassesStart || (registration.term.id === '2168' && !registration.pastFall2016Extension))) {
            $scope.count++;
            $scope.hasAlerts = true;
          }
          if ((registration.academicCareer.code !== 'UGRD') && !registration.pastAddDrop) {
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
      var getStudentAttributes = studentAttributesFactory.getStudentAttributes().then(parseStudentAttributes);
      var statusGets = [loadHolds(), getRegistrations, getStudentAttributes];

      // Only fetch financial data for delegates who have been given explicit permssion.
      var includeFinancial = (!apiService.user.profile.delegateActingAsUid || apiService.user.profile.delegateViewAsPrivileges.financial);
      if (includeFinancial) {
        var getCarsFinances = financesFactory.getFinances().then(loadCarsFinances);
        var getCsFinances = financesFactory.getCsFinances().then(loadCsFinances);
        statusGets.push(getCarsFinances, getCsFinances);
      }

      // Make sure to hide the spinner when everything is loaded
      $q.all(statusGets).then(function() {
        statusHoldsService.matchTermIndicators($scope.regStatus.positiveIndicators, $scope.regStatus.registrations);
        statusHoldsService.checkShownRegistrations($scope.regStatus.registrations);
        parseRegistrationCounts();
        if (includeFinancial) {
          parseFinances();
        }
      }).then(finishLoading);
    }
  });
});
