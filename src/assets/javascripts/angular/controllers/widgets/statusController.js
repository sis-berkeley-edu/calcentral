'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Status controller
 */
angular.module('calcentral.controllers').controller('StatusController', function(academicStatusFactory, activityFactory, apiService, statusHoldsService, badgesFactory, financesFactory, registrationsFactory, studentAttributesFactory, userService, $http, $scope, $q) {
  $scope.finances = {};
  $scope.regStatus = {
    terms: [],
    registrations: [],
    positiveIndicators: [],
    isLoading: true
  };

  // Keep track on whether the status has been loaded or not
  var hasLoaded = false;

  var loadStudentInfo = function(data) {
    if (!data.studentInfo || !apiService.user.profile.roles.student) {
      return;
    }

    $scope.studentInfo = data.studentInfo;

    if (_.get(data, 'studentInfo.regStatus.code')) {
      $scope.hasRegistrationData = true;
    }
    if (_.get(data, 'studentInfo.regStatus.needsAction') && apiService.user.profile.features.regstatus) {
      $scope.count++;
      $scope.hasAlerts = true;
    }
    if (data.studentInfo.regBlock.activeBlocks && apiService.user.profile.features.legacyRegblocks) {
      $scope.count += data.studentInfo.regBlock.activeBlocks;
      $scope.hasAlerts = true;
    } else if (data.studentInfo.regBlock.errored) {
      $scope.count++;
      $scope.hasWarnings = true;
    }
  };

  var loadCarsFinances = function(data) {
    if (data.summary) {
      $scope.finances.carsFinances = data.summary;
    }
  };

  var loadCsFinances = function(data) {
    if (_.get(data, 'feed.summary')) {
      $scope.finances.csFinances = data.feed.summary;
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

  var parseStudentAttributes = function(data) {
    var studentAttributes = _.get(data, 'data.feed.student.studentAttributes.studentAttributes');
    // Strip all positive student indicators from student attributes feed.
    _.forEach(studentAttributes, function(attribute) {
      if (_.startsWith(attribute.type.code, '+')) {
        $scope.regStatus.positiveIndicators.push(attribute);
      }
    });
  };

  var parseRegistrationCounts = function() {
    _.forEach($scope.regStatus.registrations, function(registration) {
      if (registration.isSummer || !registration.positiveIndicators.S09) {
        return;
      }
      if (registration.summary !== 'Officially Registered') {
        $scope.count++;
        $scope.hasAlerts = true;
      }
      if (!registration.positiveIndicators.ROP && !registration.positiveIndicators.R99 && registration.pastFinancialDisbursement) {
        if (userService.profile.roles.undergrad && (!registration.pastClassesStart || (registration.term.id === '2168' && !registration.pastFallExtension))) {
          $scope.count++;
          $scope.hasAlerts = true;
        }
        if ((userService.profile.roles.graduate || userService.profile.roles.law) && !registration.pastAddDrop) {
          $scope.count++;
          $scope.hasAlerts = true;
        }
      }
    });
  };

  var loadActivity = function(data) {
    if (data.activities) {
      $scope.countUndatedFinaid = data.activities.filter(function(element) {
        return element.date === '' && element.emitter === 'Financial Aid' && element.type === 'alert';
      }).length;
      if ($scope.countUndatedFinaid) {
        $scope.count += $scope.countUndatedFinaid;
        $scope.hasAlerts = true;
      }
    }
  };

  var loadHolds = function(data) {
    if (!apiService.user.profile.features.csHolds ||
      !(apiService.user.profile.roles.student || apiService.user.profile.roles.applicant)) {
      return;
    }
    $scope.holds = _.get(data, 'data.feed.student.holds');
    var numberOfHolds = _.get($scope, 'holds.length');
    if (numberOfHolds) {
      $scope.count += numberOfHolds;
      $scope.hasAlerts = true;
    } else if (_.get(data, 'data.errored')) {
      $scope.holds = {
        errored: true
      };
      $scope.count++;
      $scope.hasWarnings = true;
    }
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

      // We use this to show the spinner
      $scope.statusLoading = 'Process';

      // Get all the necessary data from the different factories
      var getBadges = badgesFactory.getBadges().success(loadStudentInfo);
      var getHolds = academicStatusFactory.getAcademicStatus().then(loadHolds);
      var getRegistrations = registrationsFactory.getRegistrations().then(parseRegistrations);
      var getStudentAttributes = studentAttributesFactory.getStudentAttributes().then(parseStudentAttributes);
      var statusGets = [getBadges, getHolds, getRegistrations, getStudentAttributes];

      // Only fetch financial data for delegates who have been given explicit permssion.
      var includeFinancial = (!apiService.user.profile.delegateActingAsUid || apiService.user.profile.delegateViewAsPrivileges.financial);
      if (includeFinancial) {
        var getCarsFinances = financesFactory.getFinances().success(loadCarsFinances);
        var getCsFinances = financesFactory.getCsFinances().success(loadCsFinances);
        var getFinaidActivityOld = activityFactory.getFinaidActivityOld().then(loadActivity);
        statusGets.push(getCarsFinances, getCsFinances, getFinaidActivityOld);
      }

      // Make sure to hide the spinner when everything is loaded
      $q.all(statusGets).then(function() {
        statusHoldsService.matchTermIndicators($scope.regStatus.positiveIndicators, $scope.regStatus.registrations);
        parseRegistrationCounts();
        if (includeFinancial) {
          parseFinances();
        }
      }).then(finishLoading);
    }
  });
});
