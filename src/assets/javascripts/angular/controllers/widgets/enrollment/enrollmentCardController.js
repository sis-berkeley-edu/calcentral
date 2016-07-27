'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Enrollment Card Controller
 * Main controller for the enrollment card on the My Academics page
 */
angular.module('calcentral.controllers').controller('EnrollmentCardController', function(apiService, enrollmentFactory, academicStatusFactory, $route, $scope, $q) {
  var backToText = 'Class Enrollment';
  var sections = [
    {
      id: 'plan',
      title: 'Multi-year Planner'
    },
    {
      id: 'explore',
      title: 'Schedule of Classes'
    },
    {
      id: 'schedule',
      title: 'Schedule Planner'
    },
    {
      id: 'decide',
      title: 'Class Enrollment',
      show: true
    },
    {
      id: 'adjust',
      title: 'Class Adjustment',
      show: true
    }
  ];
  var sectionsLaw = [
    {
      id: 'plan_law',
      title: 'Plan',
      show: true
    },
    {
      id: 'decide',
      title: 'Appointment Start Times',
      show: true
    },
    {
      id: 'adjust',
      title: 'Enroll',
      show: true
    }
  ];
  $scope.enrollment = {
    holds: {
      isLoading: true,
      hasHolds: false
    },
    academicPlan: {
      isLoading: true
    },
    isLoading: true,
    terms: []
  };

  /**
   * Stop the main spinner.
   * This happens when
   * - the terms data has loaded
   * - or when there is no term data
   */
  var stopMainSpinner = function() {
    $scope.enrollment.isLoading = false;
  };

  /**
   * Set the data for a specific term
   */
  var setTermData = function(data, termId) {
    var term = _.find($scope.enrollment.terms, {
      termId: termId
    });

    if (term) {
      angular.extend(term, data);
    }
    return term;
  };

  /**
   * Add aditional metadata to the links
   */
  var mapLinks = function(data) {
    if (!data.links) {
      return data;
    }

    data.links = _.mapValues(data.links, function(link) {
      link.backToText = backToText;
      return link;
    });

    return data;
  };

  var setSections = function(data) {
    if (data.isLawStudent) {
      data.sections = angular.copy(sectionsLaw);
    } else {
      data.sections = angular.copy(sections);
    }
    return data;
  };

  var groupByCareer = function(data) {
    var sections = ['enrolledClasses', 'waitlistedClasses'];
    for (var i = 0; i < sections.length; i++) {
      var section = sections[i];
      data[section + 'Grouped'] = _.groupBy(data[section], 'acadCareerDescr');
    }

    return data;
  };

  /**
   * Parse a certain enrollment term
   */
  var parseEnrollmentTerm = function(data) {
    var termData = _.get(data, 'data.feed.enrollmentTerm');
    if (!termData) {
      return;
    }

    termData = mapLinks(termData);
    termData = setTermData(termData, termData.term);
    termData = setSections(termData);
    groupByCareer(termData);
  };

  /**
   * Create a promise for a specific enrollment term
   */
  var createEnrollmentPromise = function(enrollmentTerm) {
    return enrollmentFactory.getEnrollmentTerm({
      termId: enrollmentTerm.termId
    }).then(parseEnrollmentTerm);
  };

  /**
   * Create promises for all the enrollment terms
   */
  var createEnrollmentPromises = function(enrollmentTerms) {
    var promiseArray = _.map(enrollmentTerms, createEnrollmentPromise);
    return $q.all(promiseArray);
  };

  /**
   * Parse all the terms and create an array of promises for each
   */
  var parseEnrollmentTerms = function(data) {
    if (!_.get(data, 'data.feed.enrollmentTerms.length')) {
      return;
    }

    var enrollmentTerms = _.get(data, 'data.feed.enrollmentTerms');
    _.forEach(enrollmentTerms, function(term) {
      term.isLawStudent = (term.acadCareer === 'LAW');
    });
    $scope.enrollment.terms = enrollmentTerms;
    return createEnrollmentPromises(enrollmentTerms);
  };

  /**
   * Load the enrollment data and fire off subsequent events
   */
  var getEnrollmentData = enrollmentFactory.getEnrollmentTerms()
      .then(parseEnrollmentTerms)
      .finally(stopMainSpinner);

  /**
   * Load the holds information for this student.
   * If they do have a hold, we need to show a message to the student.
   */
  var loadHolds = function() {
    return academicStatusFactory.getAcademicStatus().then(function(data) {
      $scope.enrollment.holds.isLoading = false;
      $scope.enrollment.holds.hasHolds = !!(_.get(data, 'data.feed.student.holds')).length;
    });
  };

  /**
   * Parse the academic plan information
   */
  var parseAcademicPlan = function(data) {
    var feedData = _.get(data, 'data.feed');

    if (_.get(feedData, 'updateAcademicPlanner')) {
      $scope.enrollment.academicPlan.updateLink = feedData.updateAcademicPlanner;
      _.each(feedData.academicplanner, function(academicPlan) {
        setTermData({
          academicPlan: academicPlan
        }, academicPlan.term);
      });
    }

    $scope.enrollment.academicPlan.isLoading = false;
  };

  /**
   * Load the academic plan URL and information
   */
  var loadAcademicPlan = function() {
    if (!apiService.user.profile.features.csAcademicPlanner) {
      $scope.enrollment.academicPlan.isLoading = false;
      return true;
    }
    return enrollmentFactory.getAcademicPlan().then(parseAcademicPlan);
  };

  /**
   * We should check the roles of the current person since we should only load
   * the enrollment card for students
   */
  var checkRoles = function(data) {
    $scope.isAdvisingStudentLookup = $route.current.isAdvisingStudentLookup;
    if ($scope.isAdvisingStudentLookup || _.get(data, 'student')) {
      getEnrollmentData.then(loadAcademicPlan);
      loadHolds();
    } else {
      stopMainSpinner();
    }
  };

  $scope.$watch('api.user.profile.roles', checkRoles);
});
