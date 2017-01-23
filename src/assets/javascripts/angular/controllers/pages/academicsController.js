/* jshint camelcase: false */
'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Academics controller
 */
angular.module('calcentral.controllers').controller('AcademicsController', function(academicsFactory, academicsService, academicStatusFactory, apiService, badgesFactory, linkService, registrationsFactory, userService, $q, $routeParams, $scope, $location) {
  linkService.addCurrentRouteSettings($scope);
  apiService.util.setTitle($scope.currentPage.name);

  $scope.academicStatus = {
    roles: {}
  };

  $scope.academics = {
    isLoading: true
  };

  $scope.gotoGrading = function(slug) {
    $location.path('/academics/semester/' + slug);
  };

  var checkPageExists = function(page) {
    if (!page) {
      apiService.util.redirect('404');
      return false;
    } else {
      return true;
    }
  };

  var updatePrevNextSemester = function(semestersLists, selectedSemester) {
    var nextSemester = {};
    var nextSemesterCompare = false;
    var previousSemester = {};
    var previousSemesterCompare = false;
    var selectedSemesterCompare = selectedSemester.termYear + selectedSemester.termCode;
    for (var i = 0; i < semestersLists.length; i++) {
      var semesterList = semestersLists[i];
      if (!semesterList) {
        continue;
      }
      var isStudentSemesterList = (i === 0);
      for (var j = 0; j < semesterList.length; j++) {
        var semester = semesterList[j];
        if (isStudentSemesterList && !semester.hasEnrollmentData) {
          continue;
        }
        var cmp = semester.termYear + semester.termCode;
        if ((cmp < selectedSemesterCompare) && (!previousSemesterCompare || (cmp > previousSemesterCompare))) {
          previousSemesterCompare = cmp;
          previousSemester.slug = semester.slug;
        } else if ((cmp > selectedSemesterCompare) && (!nextSemesterCompare || (cmp < nextSemesterCompare))) {
          nextSemesterCompare = cmp;
          nextSemester.slug = semester.slug;
        }
      }
    }
    $scope.nextSemester = nextSemester;
    $scope.previousSemester = previousSemester;
    $scope.previousNextSemesterShow = (nextSemesterCompare || previousSemesterCompare);
  };

  var setClassInfoCategories = function(teachingSemester) {
    $scope.classInfoCategories = [
      {
        'title': 'Class Info',
        'path': null
      }
    ];
    if (teachingSemester) {
      if (apiService.user.profile.features.classInfoEnrollmentTab && teachingSemester.campusSolutionsTerm) {
        $scope.classInfoCategories.push({
          'title': 'Enrollment',
          'path': 'enrollment'
        });
      }
      $scope.classInfoCategories.push({
        'title': 'Roster',
        'path': 'roster'
      });
    }
    $scope.classInfoCategories.push({
          'title': 'Grading',
          'path': 'grading'
        });
    if ($routeParams.category) {
      $scope.currentCategory = _.find($scope.classInfoCategories, {
        'path': $routeParams.category
      });
    } else {
      $scope.currentCategory = $scope.classInfoCategories[0];
    }
  };

  var fillSemesterSpecificPage = function(semesterSlug, data) {
    var isOnlyInstructor = !!$routeParams.teachingSemesterSlug;
    var selectedStudentSemester = academicsService.findSemester(data.semesters, semesterSlug, selectedStudentSemester);
    var selectedTeachingSemester = academicsService.findSemester(data.teachingSemesters, semesterSlug, selectedTeachingSemester);
    var selectedSemester = (selectedStudentSemester || selectedTeachingSemester);
    if (!checkPageExists(selectedSemester)) {
      return;
    }
    updatePrevNextSemester([data.semesters, data.teachingSemesters], selectedSemester);

    $scope.selectedSemester = selectedSemester;
    if (selectedStudentSemester && !$routeParams.classSlug) {
      $scope.selectedCourses = selectedStudentSemester.classes;
      if (!isOnlyInstructor) {
        $scope.allCourses = academicsService.getAllClasses(data.semesters);
        $scope.previousCourses = academicsService.getPreviousClasses(data.semesters);
        $scope.enrolledCourses = academicsService.getClassesSections(selectedStudentSemester.classes, false);
        $scope.waitlistedCourses = academicsService.getClassesSections(selectedStudentSemester.classes, true);
      }
    }
    $scope.selectedStudentSemester = selectedStudentSemester;
    $scope.selectedTeachingSemester = selectedTeachingSemester;
    $scope.containsMidpointClass = academicsService.containsMidpointClass(selectedTeachingSemester);

    // Get selected course from URL params and extract data from selected semester schedule
    if ($routeParams.classSlug) {
      $scope.isInstructorOrGsi = isOnlyInstructor;
      var classSemester = selectedStudentSemester;
      if (isOnlyInstructor) {
        classSemester = selectedTeachingSemester;
      }
      for (var i = 0; i < classSemester.classes.length; i++) {
        var course = classSemester.classes[i];
        if (course.slug === $routeParams.classSlug) {
          if ($routeParams.sectionSlug) {
            $scope.selectedSection = academicsService.filterBySectionSlug(course, $routeParams.sectionSlug);
          }
          academicsService.normalizeGradingData(course);
          $scope.selectedCourse = (course.sections.length) ? course : null;
          if (isOnlyInstructor) {
            $scope.campusCourseId = course.listings[0].course_id;
          }
          break;
        }
      }
      if (!checkPageExists($scope.selectedCourse)) {
        return;
      }
      if ($routeParams.sectionSlug && !checkPageExists($scope.selectedSection)) {
        return;
      }
      $scope.selectedCourseCountInstructors = academicsService.countSectionItem($scope.selectedCourse, 'instructors');
      $scope.selectedCourseCountScheduledSections = academicsService.countSectionItem($scope.selectedCourse);
      $scope.selectedCourseLongInstructorsList = ($scope.selectedCourseCountScheduledSections > 5) || ($scope.selectedCourseCountInstructors > 10);

      var recurringCount = academicsService.countSectionItem($scope.selectedCourse, 'schedules.recurring');
      var oneTimeCount = academicsService.countSectionItem($scope.selectedCourse, 'schedules.oneTime');
      $scope.classScheduleCount = {
        oneTime: oneTimeCount,
        recurring: recurringCount,
        total: oneTimeCount + recurringCount
      };
      setClassInfoCategories(selectedTeachingSemester);
    }
  };

  var loadNumberOfHolds = function() {
    return academicStatusFactory.getHolds()
      .then(function(data) {
        $scope.numberOfHolds = _.get(data, 'holds.length');
      });
  };

  var loadRegistrations = function(data) {
    var registrations = _.get(data, 'registrations');
    $scope.hasRegStatus = !_.isEmpty(registrations);
  };

  var parseAcademics = function(data) {
    angular.extend($scope, data);

    $scope.isLSStudent = academicsService.isLSStudent($scope.collegeAndLevel);
    $scope.isUndergraduate = _.includes(_.get($scope.collegeAndLevel, 'careers'), 'Undergraduate');
    $scope.hasTeachingClasses = academicsService.hasTeachingClasses(data.teachingSemesters);
    $scope.canViewFinalExamSchedule = $scope.api.user.profile.roles.student && !$scope.api.user.profile.delegateActingAsUid && !$scope.academicStatus.roles.summerVisitor;

    // Get selected semester from URL params and extract data from semesters array
    var semesterSlug = ($routeParams.semesterSlug || $routeParams.teachingSemesterSlug);
    if (semesterSlug) {
      fillSemesterSpecificPage(semesterSlug, data);
    } else {
      if ($scope.hasTeachingClasses && (!data.semesters || (data.semesters.length === 0))) {
        // Show the current semester, or the most recent semester, since otherwise the instructor
        // landing page will be grimly bare.
        $scope.selectedTeachingSemester = academicsService.chooseDefaultSemester(data.teachingSemesters);
        $scope.widgetSemesterName = $scope.selectedTeachingSemester.name;
      }
    }
    // cumulativeGpa is passed as a string to maintain two significant digits
    $scope.gpaUnits.cumulativeGpaFloat = $scope.gpaUnits.cumulativeGpa;
    // Convert these to Number types to be processed regularly. `parseFloat` returns NaN if the input value does not contain at least one digit.
    $scope.gpaUnits.cumulativeGpa = parseFloat($scope.gpaUnits.cumulativeGpa);
    $scope.gpaUnits.totalUnits = parseFloat($scope.gpaUnits.totalUnits);
  };

  var filterWidgets = function() {
    $scope.isAcademicInfoAvailable = !!($scope.hasRegStatus ||
                                       ($scope.semesters && $scope.semesters.length));
    $scope.showStatusAndBlocks = !$scope.filteredForDelegate &&
                                 ($scope.hasRegStatus ||
                                 ($scope.numberOfHolds));
    $scope.showLegacyAdvising = !$scope.filteredForDelegate && $scope.api.user.profile.features.legacyAdvising && $scope.isLSStudent;
    $scope.showAdvising = !$scope.filteredForDelegate && apiService.user.profile.features.advising && apiService.user.profile.roles.student && isMbaJdOrNotLaw();
    $scope.showProfileMessage = (!$scope.isAcademicInfoAvailable || !$scope.collegeAndLevel || _.isEmpty($scope.collegeAndLevel.careers));
    $scope.showResidency = apiService.user.profile.roles.student && !$scope.academicStatus.roles.summerVisitor && hasResidency();
  };

  /**
   * Determines if student is either a MBA/JD, or not a Law Student at all
   * @return {Boolean} Returns true when student is MBA/JD or Not a Law Student
   */
  var isMbaJdOrNotLaw = function() {
    if (!$scope.academicStatus.roles.law || ($scope.academicStatus.roles.law && $scope.academicStatus.roles.haasMbaJurisDoctor)) {
      return true;
    }
    return false;
  };

  var hasResidency = function() {
    return (!$scope.academicStatus.roles.haasMastersFinEng && !$scope.academicStatus.roles.haasExecMba && !$scope.academicStatus.roles.haasEveningWeekendMba);
  };

  var loadAcademicRoles = function() {
    return academicStatusFactory.getAcademicRoles()
      .then(function(data) {
        $scope.academicStatus.roles = _.get(data, 'roles');
      });
  };

  // Wait until user profile is fully loaded before hitting academics data
  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated) {
      $scope.canViewAcademics = $scope.api.user.profile.hasAcademicsTab;
      var getAcademics = academicsFactory.getAcademics().success(parseAcademics);
      var getRegistrations = registrationsFactory.getRegistrations().success(loadRegistrations);
      var requests = [loadAcademicRoles(), getAcademics, getRegistrations];

      if ($scope.api.user.profile.features.csHolds &&
        ($scope.api.user.profile.roles.student || $scope.api.user.profile.roles.applicant)) {
        requests.push(loadNumberOfHolds());
      }
      $q.all(requests).then(filterWidgets);
    }
    $scope.academics.isLoading = false;
  });
});
