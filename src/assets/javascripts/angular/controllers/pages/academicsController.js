'use strict';

var _ = require('lodash');

/**
 * Academics controller
 */
angular.module('calcentral.controllers').controller('AcademicsController', function(
  academicsFactory,
  academicsService,
  academicStandingsFactory,
  holdsFactory,
  apiService,
  linkService,
  registrationsFactory,
  $q,
  $routeParams,
  $scope,
  $location,
  $ngRedux
) {
  $ngRedux.subscribe(() => {
    const {
      myStatusAndHolds: {
        termRegistrations = []
      }
    } = $ngRedux.getState();

    const shownRegistrations = termRegistrations.find(reg => reg.isShown);
    $scope.showStatusAndBlocks = !$scope.filteredForDelegate && ($scope.hasRegStatus || $scope.numberOfHolds || $scope.hasStandingAlert || shownRegistrations);
  });

  linkService.addCurrentRouteSettings($scope);
  apiService.util.setTitle($scope.currentPage.name);

  $scope.academics = {
    isLoading: true
  };

  $scope.gotoGrading = function(slug) {
    $location.path('/academics/semester/' + slug);
  };

  $scope.redirectToHome = function() {
    apiService.util.redirectToHome();
    return false;
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
    if ($routeParams.category) {
      $scope.currentCategory = _.find($scope.classInfoCategories, {
        'path': $routeParams.category
      });
    } else {
      $scope.currentCategory = $scope.classInfoCategories[0];
    }
  };

  var setGradingFlags = function(selectedTeachingSemester) {
    if (!selectedTeachingSemester) {
      return false;
    }
    var teachingCourses = academicsService.getClassesSections(selectedTeachingSemester.classes, false);
    $scope.containsMidpointClass = academicsService.containsMidpointClass(selectedTeachingSemester);
    $scope.containsLawClass = academicsService.containsLawClass(selectedTeachingSemester);
    $scope.isSummerSemester = academicsService.isSummerSemester(selectedTeachingSemester);
    $scope.teachingCoursesHaveTopics = academicsService.courseCollectionHasTopics(teachingCourses);
  };

  var fillSemesterSpecificPage = function(semesterSlug, data) {
    var isOnlyInstructor = !!$routeParams.teachingSemesterSlug;
    var selectedStudentSemester = academicsService.findSemester(data.semesters, semesterSlug, selectedStudentSemester);
    var selectedTeachingSemester = academicsService.findSemester(data.teachingSemesters, semesterSlug, selectedTeachingSemester);
    var selectedSemester = (selectedStudentSemester || selectedTeachingSemester);
    var enrolledCourses;
    var waitlistedCourses;
    if (!checkPageExists(selectedSemester)) {
      return;
    }
    updatePrevNextSemester([data.semesters, data.teachingSemesters], selectedSemester);

    $scope.selectedSemester = selectedSemester;
    if (selectedStudentSemester && !$routeParams.classId) {
      $scope.selectedCourses = selectedStudentSemester.classes;
      if (!isOnlyInstructor) {
        enrolledCourses = academicsService.getClassesSections(selectedStudentSemester.classes, false);
        waitlistedCourses = academicsService.getClassesSections(selectedStudentSemester.classes, true);
        $scope.swapClassList = academicsService.getSwapClasses(enrolledCourses, waitlistedCourses);
        $scope.swapCount = $scope.swapClassList.length;
        $scope.allCourses = academicsService.getAllClasses(data.semesters);
        $scope.previousCourses = academicsService.getPreviousClasses(data.semesters);
        $scope.enrolledCourses = enrolledCourses;
        $scope.waitlisted = {
          lawOnly: _.every(waitlistedCourses, {'courseCareerCode': 'LAW'}),
          courses: waitlistedCourses,
          haveTopics: academicsService.courseCollectionHasTopics(waitlistedCourses)
        };
        $scope.enrolledCoursesHaveTopics = academicsService.courseCollectionHasTopics(enrolledCourses);
      }
    }
    $scope.selectedStudentSemester = selectedStudentSemester;
    $scope.selectedTeachingSemester = selectedTeachingSemester;
    setGradingFlags(selectedTeachingSemester);

    // Get selected course from URL params and extract data from selected semester schedule
    if ($routeParams.classId) {
      var classSemester = isOnlyInstructor ? selectedTeachingSemester : selectedStudentSemester;
      $scope.isInstructorOrGsi = isOnlyInstructor;

      for (var i = 0; i < classSemester.classes.length; i++) {
        var course = classSemester.classes[i];
        if (course.course_id === $routeParams.classId) {
          if ($routeParams.sectionSlug) {
            $scope.selectedSection = academicsService.filterBySectionSlug(course, $routeParams.sectionSlug);
          }
          academicsService.normalizeGradingData(course);
          course.topics = academicsService.collectTopics(course);
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
    return holdsFactory.getHolds().then(
      function(response) {
        $scope.numberOfHolds = _.get(response, 'data.feed.holds.length');
      }
    );
  };

  var loadHasStanding = function() {
    return academicStandingsFactory.getStandings().then(
      function(response) {
        var currentStandings = _.get(response, 'data.feed.currentStandings');
        if (currentStandings.length !== 0 && currentStandings[0].acadStandingStatus !== 'GST') {
          $scope.hasStandingAlert = true;
        }
        $scope.standingIsVisible = true;
      }
    );
  };

  var loadRegistrations = function(response) {
    var registrations = _.get(response, 'data.registrations');
    $scope.hasRegStatus = !_.isEmpty(registrations);
  };

  var parseAcademics = function(response) {
    angular.extend($scope, _.get(response, 'data'));

    $scope.isLSStudent = academicsService.isLSStudent($scope.collegeAndLevel);
    $scope.isUndergraduate = _.includes(_.get($scope.collegeAndLevel, 'careers'), 'Undergraduate');
    $scope.hasTeachingClasses = academicsService.hasTeachingClasses(_.get(response, 'data.teachingSemesters'));
    $scope.canViewFinalExamSchedule = apiService.user.profile.roles.student && !apiService.user.profile.delegateActingAsUid && !apiService.user.profile.academicRoles.current.summerVisitor;

    // summarize section topics for courses
    if ($scope.semesters) {
      academicsService.summarizeStudentClassTopics($scope.semesters);
    }

    // Get selected semester from URL params and extract data from semesters array
    var semesterSlug = ($routeParams.semesterSlug || $routeParams.teachingSemesterSlug);
    if (semesterSlug) {
      fillSemesterSpecificPage(semesterSlug, _.get(response, 'data'));
    } else {
      if ($scope.hasTeachingClasses && (!response.data || !response.data.semesters || (response.data.semesters.length === 0))) {
        // Show the current semester, or the most recent semester, since otherwise the instructor
        // landing page will be grimly bare.
        $scope.selectedTeachingSemester = academicsService.chooseDefaultSemester(response.data.teachingSemesters);
        setGradingFlags($scope.selectedTeachingSemester);
        $scope.widgetSemesterName = $scope.selectedTeachingSemester.name;
      }
    }
    $scope.gpaUnits = academicsService.parseGpaUnits($scope.gpaUnits);
  };

  var filterWidgets = function() {
    var isNonDegreeSeekingSummerVisitor = academicsService.isNonDegreeSeekingSummerVisitor(apiService.user.profile.academicRoles);

    $scope.isAcademicInfoAvailable = !!($scope.hasRegStatus ||
                                       ($scope.semesters && $scope.semesters.length));
    $scope.isNonDegreeSeekingSummerVisitor = isNonDegreeSeekingSummerVisitor;
    $scope.showAdvising = !$scope.filteredForDelegate && apiService.user.profile.features.advising && apiService.user.profile.roles.student && isMbaJdOrNotLaw() && !isNonDegreeSeekingSummerVisitor;
    $scope.showProfileMessage = (!$scope.isAcademicInfoAvailable || !$scope.collegeAndLevel || _.isEmpty($scope.collegeAndLevel.careers));
    $scope.showResidency = apiService.user.profile.roles.student && academicsService.showResidency(apiService.user.profile.academicRoles.current);
    $scope.showGpaSection = academicsService.showGpa($scope.gpaUnits.gpa);
  };

  /**
   * Determines if student is either a MBA/JD, or not a Law Student at all
   * @return {Boolean} Returns true when student is MBA/JD or Not a Law Student
   */
  var isMbaJdOrNotLaw = function() {
    return !apiService.user.profile.academicRoles.current.law || apiService.user.profile.academicRoles.current.haasMbaJurisDoctor;
  };

  // Wait until user profile is fully loaded before hitting academics data
  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated) {
      $scope.canViewAcademics = apiService.user.profile.hasAcademicsTab;
      $scope.withdrawnAdmit = apiService.user.profile.roles.withdrawnAdmit;
      if (!$scope.canViewAcademics) {
        apiService.user.redirectToHome();
      }
      var getAcademics = academicsFactory.getAcademics().then(parseAcademics);
      var getRegistrations = registrationsFactory.getRegistrations().then(loadRegistrations);
      var requests = [getAcademics, getRegistrations];

      if (apiService.user.profile.roles.student || apiService.user.profile.roles.applicant || apiService.user.profile.roles.exStudent || apiService.user.profile.roles.concurrentEnrollmentStudent) {
        requests.push(loadNumberOfHolds());
      }
      if (apiService.user.profile.academicRoles.current.ugrd && !apiService.user.profile.academicRoles.current.ugrdNonDegree) {
        requests.push(loadHasStanding());
      }
      $q.all(requests).then(filterWidgets);
    }
    $scope.academics.isLoading = false;
  });
});
