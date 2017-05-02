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

  var parseAdvisingResources = function(response) {
    var resources = $scope.ucAdvisingResources;
    angular.extend(resources, _.get(response, 'data.feed'));
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
    }).then(
      function successCallback(response) {
        angular.extend($scope.targetUser, _.get(response, 'data.attributes'));
        angular.extend($scope.residency, _.get(response, 'data.residency.residency'));
        $scope.targetUser.ldapUid = targetUserUid;
        $scope.targetUser.addresses = apiService.profile.fixFormattedAddresses(_.get(response, 'data.contacts.feed.student.addresses'));
        $scope.targetUser.phones = _.get(response, 'data.contacts.feed.student.phones');
        $scope.targetUser.emails = _.get(response, 'data.contacts.feed.student.emails');
        // 'student.fullName' is expected by shared code (e.g., photo unavailable widget)
        $scope.targetUser.fullName = $scope.targetUser.defaultName;
        apiService.util.setTitle($scope.targetUser.defaultName);

        // Get links to advising resources
        advisingFactory.getAdvisingResources({
          uid: targetUserUid
        }).then(parseAdvisingResources);
      },
      function errorCallback(response) {
        $scope.targetUser.error = errorReport(_.get(response, 'data.status'), _.get(response, 'data.error'));
      }
    ).finally(function() {
      $scope.residency.isLoading = false;
      $scope.targetUser.isLoading = false;
    });
  };

  var loadAcademics = function() {
    advisingFactory.getStudentAcademics({
      uid: $routeParams.uid
    }).then(
      function successCallback(response) {
        angular.extend($scope, _.get(response, 'data'));
        _.forEach($scope.planSemesters, function(semester) {
          angular.extend(
            semester,
            {
              show: ['current', 'previous', 'next'].indexOf(semester.timeBucket) > -1
            });
        });

        // add current page properties to DB2 archived transcript link
        if (!!_.get($scope, 'legacyReportStatus.link')) {
          linkService.addCurrentPagePropertiesToLink($scope.legacyReportStatus.link, $scope.currentPage.name, $scope.currentPage.url);
        }

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
          linkService.addCurrentPagePropertiesToLink($scope.updatePlanUrl, $scope.currentPage.name, $scope.currentPage.url);
        }

        // prepare Student Success filtering of inactive careers
        $scope.studentSuccess.activeCareers = _.map(_.get($scope, 'collegeAndLevel.careers'), toLowerCase);
      },
      function errorCallback(response) {
        $scope.academics.error = errorReport(_.get(response, 'status'), _.get(response, 'data.error'));
      }
    ).finally(function() {
      $scope.academics.isLoading = false;
      $scope.planSemestersInfo.isLoading = false;
    });
  };

  var loadRegistrations = function() {
    advisingFactory.getStudentRegistrations({
      uid: $routeParams.uid
    }).then(function(response) {
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
    }).then(loadStudentAttributes);
  };

  var loadStudentAttributes = function() {
    studentAttributesFactory.getStudentAttributes({
      uid: $routeParams.uid
    }).then(
      function successCallback(response) {
        var studentAttributes = _.get(response, 'data.feed.student.studentAttributes.studentAttributes');
        // Strip all positive student indicators from student attributes feed.
        _.forEach(studentAttributes, function(attribute) {
          if (_.startsWith(attribute.type.code, '+')) {
            $scope.regStatus.positiveIndicators.push(attribute);
          }
        });

        statusHoldsService.matchTermIndicators($scope.regStatus.positiveIndicators, $scope.regStatus.registrations);
        $scope.hasShownRegistrations = statusHoldsService.checkShownRegistrations($scope.regStatus.registrations);
      }
    ).finally(function() {
      $scope.regStatus.isLoading = false;
    });
  };

  var loadStudentSuccess = function() {
    console.log('calling advisingFactory.getStudentSuccess');
    advisingFactory.getStudentSuccess({
      uid: $routeParams.uid
    }).then(
      function successCallback(response) {
        console.log('executing successCallback');
        $scope.studentSuccess.outstandingBalance = _.get(response, 'data.outstandingBalance');
        parseTermGpa(response);
      }
    ).finally(function() {
      console.log('finished parsing');
      console.dir($scope);
      $scope.studentSuccess.isLoading = false;
      console.log('All done... finally');
    });
  };

  var loadDegreeProgresses = function() {
    advisingFactory.getDegreeProgressGraduate({
      uid: $routeParams.uid
    }).then(function(response) {
      $scope.degreeProgress.graduate.progresses = _.get(response, 'data.feed.degreeProgress');
      $scope.degreeProgress.graduate.errored = _.get(response, 'errored');
    }).then(function() {
      advisingFactory.getDegreeProgressUndergrad({
        uid: $routeParams.uid
      }).then(function(response) {
        $scope.degreeProgress.undergraduate.progresses = _.get(response, 'data.feed.degreeProgress.progresses');
        $scope.degreeProgress.undergraduate.links = _.get(response, 'data.feed.links');
        $scope.degreeProgress.undergraduate.errored = _.get(response, 'errored');
      }).finally(function() {
        $scope.degreeProgress.undergraduate.showCard = apiService.user.profile.features.csDegreeProgressUgrdAdvising && ($scope.targetUser.roles.undergrad || $scope.degreeProgress.undergraduate.progresses.length);
        $scope.degreeProgress.graduate.showCard = apiService.user.profile.features.csDegreeProgressGradAdvising && ($scope.degreeProgress.graduate.progresses.length || $scope.targetUser.roles.graduate || $scope.targetUser.roles.law);
        $scope.degreeProgress.isLoading = false;
      });
    });
  };

  var chartGpaTrend = function(termGpas) {
    console.log('Building highcharts data');
    var chartData = _.map(termGpas, 'termGpa');

    // The last element of the data series must also contain custom marker information to show the GPA.
    chartData[chartData.length - 1] = {
      y: chartData[chartData.length - 1],
      dataLabels: {
        color: chartData[chartData.length - 1] >= 2 ? '#2b6281' : '#cf1715',
        enabled: true,
        style: {
          'fontSize': '12px'
        }
      },
      marker: {
        enabled: true,
        fillColor: chartData[chartData.length - 1] >= 2 ? '#2b6281' : '#cf1715',
        radius: 3,
        symbol: 'circle'
      }
    };
    console.log('Setting highcharts data into scope: ');
    $scope.highCharts.dataSeries.push(chartData);
    console.dir($scope);
  };

  var parseTermGpa = function(response) {
    console.log('Parsing term GPA');
    console.dir($scope);
    console.dir(_.get(response, 'data.termGpa'));

    var termGpas = [];
    _.forEach(_.get(response, 'data.termGpa'), function(term) {
      console.log('inside forEach... term:');
      console.dir(term);

      console.log('isActiveCareer: ' + isActiveCareer(term));

      if (term.termGpa && isActiveCareer(term)) {
        termGpas.push(term);
        console.log('added term to termGpas list:');
        console.dir(termGpas);
      }
    });
    console.log('termGpas:');
    console.dir(termGpas);
    console.log('sorted termGpas:');
    console.dir(_.sortBy(termGpas, ['termId']));
    $scope.studentSuccess.termGpa = termGpas;
    console.log('scope:');
    console.dir($scope);

    if (termGpas.length > 2) {
      chartGpaTrend(termGpas);
    } else {
      $scope.studentSuccess.showChart = false;
    }
  };

  var getRegMessages = function() {
    enrollmentVerificationFactory.getEnrollmentVerificationMessages().then(
      function(response) {
        var messages = _.get(response, 'data.feed.root.getMessageCatDefn');
        if (messages) {
          $scope.regStatus.messages = {};
          _.merge($scope.regStatus.messages, statusHoldsService.getRegStatusMessages(messages));
        }
      }
    );
  };

  /**
   * This should be done in back-end, but requires a refactoring of MyAcademics::FilteredForAdvisor and StudentSuccess::Merged.
   * This is a temporary fix aimed for GoLive 7.5, but should be refactored for GoLive 8.
   */
  var isActiveCareer = function(term) {
    console.log('active careers = ' + $scope.studentSuccess.activeCareers);
    console.log('lowercased term.career = ' + toLowerCase(term.career));
    console.log('in isActiveCareer, term.career = ' + term.career);
    var test = _.includes($scope.studentSuccess.activeCareers, toLowerCase(term.career));
    console.log(test);
    return test;
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

  /**
   * Determines if the Academic Plan card should be displayed
   * Displays if planSemester data present, or if legacy report code is present in the feed
   * @return {Boolean} boolean
   */
  $scope.showAcademicPlanCard = function() {
    var planSemestersPresent = _.get($scope, 'planSemesters.length');
    var legacyReportCode = _.get($scope, 'legacyReportStatus.code');
    if (planSemestersPresent || legacyReportCode !== 'NONE') {
      return true;
    }
    return false;
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
      .then(loadRegistrations)
      .then(loadDegreeProgresses)
      .then(getRegMessages);
    }
  });
});
