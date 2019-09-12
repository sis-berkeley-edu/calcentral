var _ = require('lodash');

import { fetchStatusAndHolds } from 'Redux/actions/statusActions';

const StatusController = (academicStandingsFactory,
  holdsFactory,
  activityFactory,
  apiService,
  statusHoldsService,
  badgesFactory,
  financesFactory,
  registrationsFactory,
  $http,
  $scope,
  $q,
  $ngRedux
) => {
  $ngRedux.subscribe(() => {
    const {
      myStatusAndHolds: {
        termRegistrations = []
      }
    } = $ngRedux.getState();

    const badgeCount = termRegistrations.map(reg => reg.badgeCount).reduce((val, prev) => (val + prev), 0);

    if (badgeCount > 0) {
      $scope.hasAlerts = true;
    }

    $scope.badgeCount = $scope.count + badgeCount;
  });

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
        var registrationExplanation = _.get(registration, 'regStatus.explanation');
        if (registrationStatus !== 'Officially Registered' && registrationExplanation) {
          $scope.regStatus.hasData = true;
        }
      });
    }
  };

  var parseRegistrationCounts = function() {
    _.forEach($scope.regStatus.registrations, function(registration) {
      var positiveIndicators = _.get(registration, 'positiveIndicators');
      var indicatorTypes = [];

      _.forEach(positiveIndicators, function(indicator) {
        var indicatorType = _.get(indicator, 'type.code');
        indicatorTypes.push(indicatorType);
      });
    });
  };

  var loadHolds = function() {
    var deferred;

    if (!(apiService.user.profile.roles.student || apiService.user.profile.roles.applicant || apiService.user.profile.roles.exStudent || apiService.user.profile.roles.concurrentEnrollmentStudent)) {
      deferred = $q.defer();
      deferred.resolve();
      return deferred.promise;
    }

    return holdsFactory.getHolds().then(
      function(response) {
        var holdsCount;
        if (_.get(response, 'data.errored')) {
          $scope.holds = {
            errored: true
          };
          $scope.count++;
          $scope.hasWarnings = true;
        } else {
          $scope.holds = _.get(response, 'data.feed.holds');
          holdsCount = _.get(response, 'data.feed.holds.length');
          $scope.count += holdsCount;
          $scope.hasAlerts = (holdsCount > 0) || $scope.hasStandingAlert;
        }
      }
    );
  };

  var loadStandings = function() {
    var deferred;
    if (!apiService.user.profile.roles.undergrad) {
      deferred = $q.defer();
      deferred.resolve();
      return deferred.promise;
    }
    return academicStandingsFactory.getStandings().then(
      function(response) {
        var currentStandings = _.get(response, 'data.feed.currentStandings');
        if (currentStandings.length !== 0 && currentStandings[0].acadStandingStatus !== 'GST') {
          $scope.count += 1;
          $scope.hasStandingAlert = true;
          $scope.hasAlerts = true;
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

      $ngRedux.dispatch(fetchStatusAndHolds());

      // Set the error count to 0
      $scope.count = 0;
      $scope.hasAlerts = false;
      $scope.hasWarnings = false;

      // We use this to show the spinner.
      if (!apiService.user.profile.delegateActingAsUid && !apiService.user.profile.advisorActingAsUid) {
        $scope.statusLoading = 'Process';
      }

      // Set necessary function definitions.
      $scope.cnpStatusIcon = statusHoldsService.cnpStatusIcon;
      $scope.regStatusIcon = statusHoldsService.regStatusIcon;

      // Will contain loadError flag if image cannot be fetched.
      $scope.photo = {};

      // Get all the necessary data from the different factories
      var getRegistrations = registrationsFactory.getRegistrations().then(parseRegistrations);
      var statusGets = [loadHolds(), loadStandings(), getRegistrations];

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
};

angular.module('calcentral.controllers').controller('StatusController', StatusController);
