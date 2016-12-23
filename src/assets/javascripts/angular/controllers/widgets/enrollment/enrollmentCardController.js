'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Enrollment Card Controller
 * Main controller for the enrollment card on the My Academics and Student Overview pages
 */
angular.module('calcentral.controllers').controller('EnrollmentCardController', function(apiService, enrollmentFactory, linkService, $route, $scope) {
  $scope.accessibilityAnnounce = apiService.util.accessibilityAnnounce;

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
  var sectionsConcurrent = [
    {
      id: 'decide_concurrent',
      title: 'Enroll',
      show: true
    },
    {
      id: 'explore',
      title: 'Class Search',
      show: true
    },
    {
      id: 'adjust',
      title: 'Class Adjustment',
      show: true
    },
    {
      id: 'sites_concurrent',
      title: 'UC Extension Sites',
      show: true
    }
  ];
  var sectionsSummerVisitor = [
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

  /**
   * Groups enrolled and waitlisted classes by career description
   */
  var groupByCareer = function(data) {
    var sections = ['enrolledClasses', 'waitlistedClasses'];
    for (var i = 0; i < sections.length; i++) {
      var section = sections[i];
      data[section + 'Grouped'] = _.groupBy(data[section], 'acadCareerDescr');
    }
    return data;
  };

  /**
   * Determines the sections displayed for card by instruction type
   */
  var setSections = function(enrollmentInstruction) {
    switch (enrollmentInstruction.role) {
      case 'law': {
        enrollmentInstruction.sections = angular.copy(sectionsLaw);
        break;
      }
      case 'concurrent': {
        enrollmentInstruction.sections = angular.copy(sectionsConcurrent);
        break;
      }
      case 'summerVisitor': {
        enrollmentInstruction.sections = angular.copy(sectionsSummerVisitor);
        break;
      }
      default: {
        enrollmentInstruction.sections = angular.copy(sections);
      }
    }
    return enrollmentInstruction;
  };

  /**
   * Add aditional metadata to the links
   */
  var mapLinks = function(enrollmentInstruction) {
    if (!enrollmentInstruction.links) {
      return enrollmentInstruction;
    }

    var backToText = 'My Academics';
    if ($route.current.isAdvisingStudentLookup) {
      backToText = 'Student Overview';
    }
    enrollmentInstruction.links = linkService.addBackToTextToResources(enrollmentInstruction.links, backToText);

    return enrollmentInstruction;
  };

  /*
   * Associates term based enrollment instructions and academic plans
   * with enrollment instruction types
   */
  var parseEnrollmentInstructionDecks = function(data) {
    var enrollmentInstructionDecks = _.get(data, 'enrollmentInstructionDecks');
    enrollmentInstructionDecks = _.map(enrollmentInstructionDecks, function(deck) {
      deck.cards = _.map(deck.cards, function(enrollmentInstruction) {
        var instruction = mapLinks(enrollmentInstruction);
        instruction = setSections(instruction);
        instruction = groupByCareer(instruction);
        return instruction;
      });
      return deck;
    });
    $scope.enrollmentInstructionDecks = enrollmentInstructionDecks;
  };

  /**
   * Load the enrollment data and fire off subsequent events
   */
  var loadEnrollmentData = function() {
    enrollmentFactory.getEnrollmentInstructionDecks()
      .then(parseEnrollmentInstructionDecks)
      .then(stopMainSpinner);
  };

  /**
   * We should check the roles of the current person since we should only load
   * the enrollment card for students
   */
  var checkRoles = function(data) {
    $scope.isLoading = true;
    $scope.isAdvisingStudentLookup = $route.current.isAdvisingStudentLookup;
    if ($scope.isAdvisingStudentLookup || _.get(data, 'student')) {
      loadEnrollmentData();
    } else {
      stopMainSpinner();
    }
  };

  var stopMainSpinner = function() {
    $scope.isLoading = false;
  };

  /**
   * Changes the card currently displayed within a class enrollment card deck
   */
  $scope.switchTerm = function(index, enrollmentDeck) {
    enrollmentDeck.selectedCardIndex = index;
    var selectedCard = enrollmentDeck.cards[enrollmentDeck.selectedCardIndex];
    $scope.accessibilityAnnounce('Loaded enrollment instructions for ' + _.get(selectedCard, 'term.termName', 'selected term'));
  };

  /**
   *
   * Returns true if any of the types codes provided match the instruction type code
   * @param  {object} instruction class enrollment instruction object
   * @param  {array}  typeCodes   array of strings representing instruction types
   * @return {Boolean}            True when any type code provided matches
   */
  $scope.isInstructionType = function(instruction, typeCodes) {
    return typeCodes.indexOf(instruction.role) !== -1;
  };

  /**
   * Toggles display of section when instruction type is not concurrent
   */
  $scope.toggleSection = function($event, section, enrollmentInstruction) {
    if (!$scope.isInstructionType(enrollmentInstruction, ['concurrent'])) {
      $scope.api.widget.toggleShow($event, null, section, 'Class Enrollment Section - ' + section.title);
    }
  };

  /*
   * Runs on load and when roles are updated
   */
  $scope.$watch('api.user.profile.roles', checkRoles);
});
