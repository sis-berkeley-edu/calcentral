'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Status controller
 */
angular.module('calcentral.controllers').controller('StatusController', function(academicStatusFactory, activityFactory, apiService, badgesFactory, financesFactory, $http, $scope, $q) {
  $scope.finances = {};

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
      var statusGets = [getBadges, getHolds];

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
        if (includeFinancial) {
          parseFinances();
        }
      }).then(finishLoading);
    }
  });
});
