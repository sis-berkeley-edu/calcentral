'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Preview of user profile prior to viewing-as
 */
angular.module('calcentral.controllers').controller('UserOverviewController', function(academicsService, adminService, advisingFactory, academicStatusFactory, apiService, enrollmentVerificationFactory, statusHoldsService, studentAttributesFactory, $route, $routeParams, $scope) {
  $scope.expectedGradTerm = academicsService.expectedGradTerm;
  $scope.academics = {
    isLoading: true,
    excludeLinksToRegistrar: true
  };
  $scope.ucAdvisingResources = {
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
    isLoading: true
  };
  $scope.degreeProgressGraduate = {
    isLoading: true
  };
  $scope.degreeProgressUndergrad = {
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

  var backToText = 'Student Overview';

  /**
   * Add the back to text (used for Campus Solutions) to the link
   */
  var addBackToTextLink = function(link) {
    link.backToText = backToText;
    return link;
  };

  /**
   * Add the back to text
   */
  var addBackToText = function(resources) {
    _.mapValues(resources, addBackToTextLink);
  };

  var parseAdvisingResources = function(data) {
    var resources = $scope.ucAdvisingResources;

    angular.extend(resources, _.get(data, 'data.feed'));

    if (_.get(resources, 'links')) {
      addBackToText(resources.links);
    }

    if (_.get(resources, 'csLinks')) {
      addBackToText(resources.csLinks);
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
      // We use aliases in scope because the user overview page has cards that are shared with My Academics, etc.
      $scope.academics.universityRequirements = $scope.requirements;
    }).error(function(data, status) {
      $scope.academics.error = errorReport(status, data.error);
    }).finally(function() {
      $scope.academics.isLoading = false;
    });
  };

  var loadHolds = function() {
    academicStatusFactory.getAcademicStatus({
      uid: $routeParams.uid
    }).success(function(data) {
      $scope.holds = _.get(data, 'data.feed.student.holds');
    }).finally(function() {
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
    }).finally(function() {
      $scope.regStatus.isLoading = false;
    });
  };

  var loadStudentSuccess = function() {
    advisingFactory.getStudentSuccess({
      uid: $routeParams.uid
    }).success(function(data) {
      $scope.studentSuccess.outstandingBalance = _.get(data, 'outstandingBalance');
      $scope.studentSuccess.termGpa = _.sortBy(data.termGpa, ['termId']);
      parseTermGpa();
    }).finally(function() {
      $scope.studentSuccess.isLoading = false;
    });
  };

  var loadDegreeProgressGraduate = function() {
    advisingFactory.getDegreeProgressGraduate({
      uid: $routeParams.uid
    }).success(function(data) {
      $scope.degreeProgressGraduate.progresses = _.get(data, 'feed.degreeProgress');
      $scope.degreeProgressGraduate.errored = _.get(data, 'errored');
    }).finally(function() {
      $scope.degreeProgressGraduate.isLoading = false;
    });
  };

  var loadDegreeProgressUndergrad = function() {
    advisingFactory.getDegreeProgressUndergrad({
      uid: $routeParams.uid
    }).success(function(data) {
      $scope.degreeProgressUndergrad.progresses = _.get(data, 'feed.degreeProgress.progresses');
      $scope.degreeProgressUndergrad.errored = _.get(data, 'errored');
    }).finally(function() {
      $scope.degreeProgressUndergrad.isLoading = false;
    });
  };

  var parseTermGpa = function() {
    var termGpa = [];
    _.forEach($scope.studentSuccess.termGpa, function(term) {
      if (term.termCumGpa) {
        termGpa.push(term.termCumGpa);
      }
    });
    if (termGpa.length < 2) {
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
      .then(loadDegreeProgressGraduate)
      .then(loadDegreeProgressUndergrad)
      .then(getRegMessages);
    }
  });
});
