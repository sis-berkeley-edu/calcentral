'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Preview of user profile prior to viewing-as
 */
angular.module('calcentral.controllers').controller('UserOverviewController', function(academicsService, adminService, advisingFactory, academicStatusFactory, apiService, enrollmentVerificationFactory, linkService, statusHoldsService, studentAttributesFactory, $route, $routeParams, $scope) {
  linkService.addCurrentRouteSettings($scope);

  $scope.expectedGradTerm = academicsService.expectedGradTerm;
  $scope.academics = {
    isLoading: true,
    excludeLinksToRegistrar: true
  };
  $scope.ucAdvisingResources = {
    isLoading: true
  };
  $scope.planSemestersInfo = {
    isLoading: true
  };
  $scope.holdsInfo = {
    isLoading: true
  };
  $scope.isAdvisingStudentLookup = $route.current.isAdvisingStudentLookup;
  $scope.regStatus = {
    terms: [],
    registrations: [],
    positiveIndicators: [],
    isLoading: true
  };
  $scope.residency = {
    isLoading: true
  };
  $scope.targetUser = {
    isLoading: true
  };
  $scope.statusHoldsBlocks = {};
  $scope.highCharts = {
    dataSeries: []
  };
  $scope.studentSuccess = {
    activeCareers: null,
    gpaChart: {
      series: {
        className: 'cc-student-success-color-blue'
      },
      xAxis: {
        floor: 0,
        visible: false
      },
      yAxis: {
        min: 0,
        max: 4.0,
        visible: false
      }
    },
    showChart: true,
    isLoading: true
  };
  $scope.degreeProgress = {
    graduate: {},
    undergraduate: {},
    isLoading: true
  };

  $scope.$watchGroup(['regStatus.registrations[0].summary', 'api.user.profile.features.csHolds'], function(newValues) {
    var enabledSections = [];

    if (newValues[0] !== null && newValues[0] !== undefined) {
      enabledSections.push('Status');
    }

    if (newValues[1]) {
      enabledSections.push('Holds');
    }

    $scope.statusHoldsBlocks.enabledSections = enabledSections;
  });

  var parseAdvisingResources = function(data) {
    var resources = $scope.ucAdvisingResources;

    angular.extend(resources, _.get(data, 'data.feed'));

    if (_.get(resources, 'links')) {
      linkService.addCurrentPagePropertiesToResources(resources.links, $scope.currentPage.name, $scope.currentPage.url);
    }

    if (_.get(resources, 'csLinks')) {
      linkService.addCurrentPagePropertiesToResources(resources.csLinks, $scope.currentPage.name, $scope.currentPage.url);
    }

    resources.isLoading = false;
  };

  var defaultErrorDescription = function(status) {
    if (status === 403) {
      return 'You are not authorized to view this user\'s data.';
    } else {
      return 'Sorry, there was a problem fetching this user\'s data. Contact CalCentral support if the error persists.';
    }
  };

  var errorReport = function(status, errorDescription) {
    return {
      summary: status === 403 ? 'Access Denied' : 'Unexpected Error',
      description: errorDescription || defaultErrorDescription(status)
    };
  };

  var loadProfile = function() {
    var targetUserUid = $routeParams.uid;
    advisingFactory.getStudent({
      uid: targetUserUid
    }).success(function(data) {
      angular.extend($scope.targetUser, _.get(data, 'attributes'));
      angular.extend($scope.residency, _.get(data, 'residency.residency'));
      $scope.targetUser.ldapUid = targetUserUid;
      $scope.targetUser.addresses = apiService.profile.fixFormattedAddresses(_.get(data, 'contacts.feed.student.addresses'));
      $scope.targetUser.phones = _.get(data, 'contacts.feed.student.phones');
      $scope.targetUser.emails = _.get(data, 'contacts.feed.student.emails');
      // 'student.fullName' is expected by shared code (e.g., photo unavailable widget)
      $scope.targetUser.fullName = $scope.targetUser.defaultName;
      apiService.util.setTitle($scope.targetUser.defaultName);

      // Get links to advising resources
      advisingFactory.getAdvisingResources({
        uid: targetUserUid
      }).then(parseAdvisingResources);
    }).error(function(data, status) {
      $scope.targetUser.error = errorReport(status, data.error);
    }).finally(function() {
      $scope.residency.isLoading = false;
      $scope.targetUser.isLoading = false;
    });
  };

  var loadAcademics = function() {
    advisingFactory.getStudentAcademics({
      uid: $routeParams.uid
    }).success(function(data) {
      angular.extend($scope, data);
      _.forEach($scope.planSemesters, function(semester) {
        angular.extend(
          semester,
          {
            show: ['current', 'previous', 'next'].indexOf(semester.timeBucket) > -1
          });
      });

      // prepare schedule planner link data
      var studentPlans = _.get($scope, 'collegeAndLevel.plans');
      var uniqueCareerCodes = academicsService.getUniqueCareerCodes(studentPlans);
      var currentRegistrationTermId = _.get($scope, 'collegeAndLevel.termId');
      if (uniqueCareerCodes.length > 0 && currentRegistrationTermId) {
        $scope.schedulePlanner = {
          careerCode: _.first(uniqueCareerCodes),
          termId: currentRegistrationTermId,
          studentUid: $routeParams.uid
        };
      }
      if (!!_.get($scope, 'updatePlanUrl.url')) {
        linkService.addCurrentPagePropertiesToResources($scope.updatePlanUrl, $scope.currentPage.name, $scope.currentPage.url);
      }

      // prepare Student Success filtering of inactive careers
      $scope.studentSuccess.activeCareers = _.map(_.get($scope, 'collegeAndLevel.careers'), toLowerCase);
    }).error(function(data, status) {
      $scope.academics.error = errorReport(status, data.error);
    }).finally(function() {
      $scope.academics.isLoading = false;
      $scope.planSemestersInfo.isLoading = false;
    });
  };

  var loadHolds = function() {
    var options = {
      uid: $routeParams.uid
    };
    return academicStatusFactory.getHolds(options)
      .then(function(data) {
        $scope.holds = _.get(data, 'holds');
      })
      .finally(function() {
        $scope.holdsInfo.isLoading = false;
      });
  };

  var loadRegistrations = function() {
    advisingFactory.getStudentRegistrations({
      uid: $routeParams.uid
    }).then(function(data) {
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
    }).then(loadStudentAttributes);
  };

  var loadStudentAttributes = function() {
    studentAttributesFactory.getStudentAttributes({
      uid: $routeParams.uid
    }).success(function(data) {
      var studentAttributes = _.get(data, 'feed.student.studentAttributes.studentAttributes');
      // Strip all positive student indicators from student attributes feed.
      _.forEach(studentAttributes, function(attribute) {
        if (_.startsWith(attribute.type.code, '+')) {
          $scope.regStatus.positiveIndicators.push(attribute);
        }
      });

      statusHoldsService.matchTermIndicators($scope.regStatus.positiveIndicators, $scope.regStatus.registrations);
      $scope.hasShownRegistrations = statusHoldsService.checkShownRegistrations($scope.regStatus.registrations);
    }).finally(function() {
      $scope.regStatus.isLoading = false;
    });
  };

  var loadStudentSuccess = function() {
    advisingFactory.getStudentSuccess({
      uid: $routeParams.uid
    }).success(function(data) {
      $scope.studentSuccess.outstandingBalance = _.get(data, 'outstandingBalance');
      $scope.studentSuccess.termGpa = _.sortBy(_.get(data, 'termGpa'), ['termId']);
      parseTermGpa();
    }).finally(function() {
      $scope.studentSuccess.isLoading = false;
    });
  };

  var loadDegreeProgresses = function() {
    advisingFactory.getDegreeProgressGraduate({
      uid: $routeParams.uid
    }).then(function(data) {
      $scope.degreeProgress.graduate.progresses = _.get(data, 'data.feed.degreeProgress');
      $scope.degreeProgress.graduate.errored = _.get(data, 'errored');
    }).then(function() {
      advisingFactory.getDegreeProgressUndergrad({
        uid: $routeParams.uid
      }).then(function(data) {
        $scope.degreeProgress.undergraduate.progresses = _.get(data, 'data.feed.degreeProgress.progresses');
        $scope.degreeProgress.undergraduate.errored = _.get(data, 'errored');
      }).finally(function() {
        $scope.degreeProgress.isLoading = false;
      });
    });
  };

  var parseTermGpa = function() {
    filterInactiveCareers();
    var termGpa = [];
    _.forEach($scope.studentSuccess.termGpa, function(term) {
      if (term.termGpa) {
        termGpa.push(term.termGpa);
      }
    });
    if (termGpa.length < 2) {
      $scope.studentSuccess.showChart = false;
      return;
    }
    // The last element of the data series must also contain custom marker information to show the GPA.
    termGpa[termGpa.length - 1] = {
      y: termGpa[termGpa.length - 1],
      dataLabels: {
        color: termGpa[termGpa.length - 1] >= 2 ? '#2b6281' : '#cf1715',
        enabled: true,
        style: {
          'fontSize': '12px'
        }
      },
      marker: {
        enabled: true,
        fillColor: termGpa[termGpa.length - 1] >= 2 ? '#2b6281' : '#cf1715',
        radius: 3,
        symbol: 'circle'
      }
    };
    $scope.highCharts.dataSeries.push(termGpa);
  };

  var getRegMessages = function() {
    enrollmentVerificationFactory.getEnrollmentVerificationMessages()
      .then(function(data) {
        var messages = _.get(data, 'data.feed.root.getMessageCatDefn');
        if (messages) {
          $scope.regStatus.messages = {};
          _.merge($scope.regStatus.messages, statusHoldsService.getRegStatusMessages(messages));
        }
      });
  };

  /**
   * This should be done in back-end, but requires a refactoring of MyAcademics::FilteredForAdvisor and StudentSuccess::Merged.
   * This is a temporary fix aimed for GoLive 7.5, but should be refactored for GoLive 8.
   */
  var filterInactiveCareers = function() {
    _.remove($scope.studentSuccess.termGpa, function(term) {
      return !_.includes($scope.studentSuccess.activeCareers, toLowerCase(term.career));
    });
  };

  var toLowerCase = function(text) {
    if (text) {
      return text.toLowerCase();
    }
  };

  $scope.expireAcademicsCache = function() {
    advisingFactory.expireAcademicsCache({
      uid: $routeParams.uid
    });
  };

  $scope.showCNP = function(registration) {
    return statusHoldsService.showCNP(registration);
  };

  $scope.targetUser.actAs = function() {
    adminService.actAs($scope.targetUser);
  };

  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated) {
      // Refresh user properties because the canSeeCSLinks property is sensitive to the current route.
      apiService.user.fetch()
      .then(loadProfile)
      .then(loadAcademics)
      .then(loadStudentSuccess)
      .then(loadHolds)
      .then(loadRegistrations)
      .then(loadDegreeProgresses)
      .then(getRegMessages);
    }
  });
});
