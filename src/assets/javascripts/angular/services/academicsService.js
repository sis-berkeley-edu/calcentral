/* jshint camelcase: false */
'use strict';

var _ = require('lodash');
var angular = require('angular');

angular.module('calcentral.services').service('academicsService', function() {

  // Selects the semester of most pressing interest.
  // Choose the semester with grading in progress
  // Otherwise choose the current semester, if available.
  // Otherwise choose the next semester in the future, if available.
  // Otherwise choose the most recent semester.
  var chooseDefaultSemester = function(semesters) {
    var groupedSemesters = _.groupBy(semesters, 'timeBucket');
    var gradingInProgress = _.find(semesters, ['gradingInProgress', true]);

    // Create array with terms objects in preferred order
    // (grading in progress, current, most recent future, most recent past)
    var sortedSemesters = [
      gradingInProgress,
      _.head(groupedSemesters.current),
      _.last(groupedSemesters.future),
      _.head(groupedSemesters.past)
    ];

    // return first present in list
    return _.head(_.compact(sortedSemesters));
  };

  var containsLawClass = function(selectedTeachingSemester) {
    var classes = _.get(selectedTeachingSemester, 'classes');
    return !!_.find(classes, {
      dept: 'LAW'
    });
  };

  var containsMidpointClass = function(selectedTeachingSemester) {
    var classes = _.get(selectedTeachingSemester, 'classes');
    var isSummer = isSummerSemester(selectedTeachingSemester);
    if (!isSummer && classes && classes.length) {
      return !_.every(classes, function(klass) {
        return _.get(klass, 'dept') === 'LAW';
      });
    } else {
      return false;
    }
  };

  var countSectionItem = function(selectedCourse, sectionItem) {
    var count = 0;
    for (var i = 0; i < selectedCourse.sections.length; i++) {
      var section = selectedCourse.sections[i];
      // Ignore crosslistings.
      if (section.scheduledWithCcn) {
        continue;
      }
      // If called without a second argument, return a simple count of sections ignoring crosslistings.
      if (!sectionItem) {
        count += 1;
      } else {
        count += _.size(_.get(section, sectionItem));
      }
    }
    return count;
  };

  /**
   * Determines if a collection of courses have topics present to display
   * Required for table presentation on semester page
   */
  var courseCollectionHasTopics = function(courses) {
    return !!_.find(courses, function(course) {
      return course.topics.length > 0;
    });
  };

  var filterBySectionSlug = function(course, sectionSlug) {
    if (!course.multiplePrimaries) {
      return null;
    }
    var filteredSections = [];
    var siteIds = [];
    var sectionFromSlug = null;
    for (var i = 0; i < course.sections.length; i++) {
      var section = course.sections[i];
      if (section.is_primary_section && section.slug === sectionSlug) {
        sectionFromSlug = section;
      } else if (section.associatedWithPrimary !== sectionSlug) {
        continue;
      }
      filteredSections.push(section);
      if (section.siteIds) {
        siteIds = siteIds.concat(section.siteIds);
      }
    }
    course.sections = filteredSections;
    if (course.class_sites) {
      course.class_sites = course.class_sites.filter(function(classSite) {
        return (siteIds.indexOf(classSite.id) !== -1);
      });
    }
    return sectionFromSlug;
  };

  var findSemester = function(semesters, slug, selectedSemester) {
    if (selectedSemester || !semesters) {
      return selectedSemester;
    }

    for (var i = 0; i < semesters.length; i++) {
      if (semesters[i].slug === slug) {
        return semesters[i];
      }
    }
  };

  var getAllClasses = function(semesters) {
    var classes = [];
    for (var i = 0; i < semesters.length; i++) {
      for (var j = 0; j < semesters[i].classes.length; j++) {
        if (semesters[i].timeBucket !== 'future') {
          classes.push(semesters[i].classes[j]);
        }
      }
    }
    return classes;
  };

  /**
   * Returns unique set of career codes extracted from collection of student plans
   * @param  {Array} studentPlans  iHub Academic Status student plans
   * @return {Array}               career codes
   */
  var getUniqueCareerCodes = function(studentPlans) {
    var careerCodes = _.map(studentPlans, function(plan) {
      return _.get(plan, 'career.code');
    });
    return _.uniq(careerCodes);
  };

  /**
   * Returns actual or waitlisted class sections
   * @param {Array} courses courses from the 'semesters' node of the academics feed
   * @param {Boolean} findWaitlisted Boolean indicating return of waitlisted courses only
   * @param {String} courseCode Optional string representing course to filter results by
   */
  var getClassesSections = function(courses, findWaitlisted, courseCode) {
    var classes = [];

    for (var i = 0; i < courses.length; i++) {
      var course = courses[i];
      if (courseCode && course.course_code !== courseCode) {
        continue;
      }
      var sections = [];
      for (var j = 0; j < course.sections.length; j++) {
        var section = course.sections[j];
        if ((findWaitlisted && section.waitlisted) || (!findWaitlisted && !section.waitlisted)) {
          sections.push(section);
        }
      }
      if (sections.length) {
        if (findWaitlisted) {
          var courseCopy = angular.copy(course);
          courseCopy.sections = sections;
          classes.push(courseCopy);
        } else {
          var primarySections = splitMultiplePrimaries(course, sections);
          for (var ccn in primarySections) {
            if (primarySections.hasOwnProperty(ccn)) {
              classes.push(primarySections[ccn]);
            }
          }
        }
      }
    }
    return classes;
  };

  /**
   * Collects unique course sections topics for course
   */
  var getCourseTopics = function(course) {
    var topics = [];
    _.forEach(course.sections, function(section) {
      var sectionTopicString = _.trim(section.topic_description);
      if (!_.isEmpty(sectionTopicString)) {
        topics.push(section.topic_description);
      }
    });
    return _.intersection(topics);
  };

  var getPreviousClasses = function(semesters) {
    var classes = [];
    for (var i = 0; i < semesters.length; i++) {
      for (var j = 0; j < semesters[i].classes.length; j++) {
        if (semesters[i].timeBucket !== 'future' && semesters[i].timeBucket !== 'current') {
          classes.push(semesters[i].classes[j]);
        }
      }
    }
    return classes;
  };

  var hasTeachingClasses = function(teachingSemesters) {
    if (teachingSemesters) {
      for (var i = 0; i < teachingSemesters.length; i++) {
        var semester = teachingSemesters[i];
        if (semester.classes.length > 0) {
          return true;
        }
      }
    }
    return false;
  };

  var isLSStudent = function(collegeAndLevel) {
    var majors = _.get(collegeAndLevel, 'majors');
    var minors = _.get(collegeAndLevel, 'minors');
    var isLSCollege = function(career) {
      return career.college === 'College of Letters & Science';
    };
    if ((majors && _.find(majors, isLSCollege)) || (minors && _.find(minors, isLSCollege))) {
      return true;
    }
  };

  var isSummerSemester = function(selectedTeachingSemester) {
    var termCode = _.get(selectedTeachingSemester, 'termCode');
    return (termCode === 'C');
  };

  var normalizeGradingData = function(course) {
    for (var i = 0; i < course.sections.length; i++) {
      var section = course.sections[i];
      if (section.is_primary_section) {
        // Copy the first section's grading information to the course for
        // easier processing later.
        course.gradeOption = section.gradeOption;
        course.units = section.units;
        break;
      }
    }
  };

  /**
   * Converts each value given in gpaUnits to a Number type to be processed regularly.  `parseFloat` returns NaN if input value does not contain at least one digit.
   * GPAs are displayed with 4 significant digits.
   * Also sets any law career-based GPAs to 'N/A' due to law classes being P/NP
   */
  var parseGpaUnits = function(gpaUnits) {
    _.forEach(gpaUnits.gpa, function(gpa) {
      if (gpa.role === 'law') {
        gpa.cumulativeGpaFloat = 'N/A';
      } else {
        gpa.cumulativeGpaFloat = parseFloat(gpa.cumulativeGpa).toPrecision(4);
      }
    });
    gpaUnits.totalUnits = parseFloat(gpaUnits.totalUnits);
    return gpaUnits;
  };

  var showGpa = function(gpaArray) {
    return _.some(gpaArray, function(gpa) {
      return _.get(gpa, 'role') !== 'law';
    });
  };

  var showResidency = function(academicRoles) {
    var show = true;
    var blacklistedRoles = ['summerVisitor', 'haasMastersFinEng', 'haasExecMba', 'haasEveningWeekendMba'];
    _.forEach(blacklistedRoles, function(role) {
      if (_.get(academicRoles, role)) {
        show = false;
        // Break the loop if we get a hit on a blacklisted role
        return false;
      }
    });
    return show;
  };

  /**
   * Prepares course sections for display based on primary or secondary status, with support for
   * courses with multiple primary sections
   * @param {Object} originalCourse course object
   * @param {Array} enrolledSections custom sections list (i.e. might be waitlisted sections only)
   */
  var splitMultiplePrimaries = function(originalCourse, enrolledSections) {
    var classes = {};
    for (var i = 0; i < enrolledSections.length; i++) {
      var section = enrolledSections[i];
      var key;
      if (section.is_primary_section) {
        var course = angular.copy(originalCourse);
        course.gradeOption = section.gradeOption;
        course.units = section.units;
        if (course.multiplePrimaries) {
          course.url = section.url;
        }
        key = course.multiplePrimaries ? section.slug : 'default';
        course.sections = classes[key] ? classes[key].sections : [];
        course.sections.push(section);
        course.topics = section.topic_description ? [section.topic_description] : [];
        classes[key] = course;
      } else {
        key = originalCourse.multiplePrimaries ? section.associatedWithPrimary : 'default';
        if (!classes[key]) {
          classes[key] = {};
          classes[key].sections = [];
        }
        classes[key].sections.push(section);
      }
    }
    return classes;
  };

  /**
   * Collects section topics and adds to class objects
   * Required for table presentation on semester page
   *
   * Example:
   *   course.topics = {
   *     present: true,
   *     list: ["Topic 1", "Topic 2"]
   *   }
   */
  var summarizeStudentClassTopics = function(semesters) {
    _.forEach(semesters, function(semester) {
      _.forEach(semester.classes, function(course) {
        course.topics = getCourseTopics(course);
      });
    });
    return semesters;
  };

  var textbookRequestInfo = function(course, semester) {
    var primarySectionNumbers = [];
    var primaryCcns = [];
    for (var i = 0; i < course.sections.length; i++) {
      var section = course.sections[i];
      // Request textbooks for primary sections only.
      if (section.is_primary_section) {
        var sectionNumber = section.section_number;
        // We check for uniqueness on three-digit section_number. A cross-listed course
        // will have sections with different CCNs and catalog IDs, but each matching
        // section_number (such as "L & S C30T LEC 001" and "PSYCH C19 LEC 001") will fetch
        // the same bookstore list.
        if (primarySectionNumbers.indexOf(sectionNumber) === -1) {
          primarySectionNumbers.push(sectionNumber);
          if (semester.campusSolutionsTerm) {
            primaryCcns.push(section.ccn);
          }
        }
      }
    }
    // For pre-Campus Solutions terms, the textbooks API expects three-digit
    // "section_numbers" (e.g., "001"). For Campus Solutions terms, the textbooks API
    // expects five-digit course ids, called "ccn" in the academics feed.
    var sectionNumbers = semester.campusSolutionsTerm ? primaryCcns : primarySectionNumbers;
    if (sectionNumbers.length) {
      var courseInfo = {
        'sectionNumbers[]': sectionNumbers,
        'department': course.dept_code,
        'courseCatalog': course.courseCatalog,
        'slug': semester.slug
      };
      return courseInfo;
    } else {
      return null;
    }
  };

  var totalTransferUnits = function(transferUnits, testUnits) {
    var numericTransferUnits = transferUnits || 0;
    var numericTestUnits = testUnits || 0;
    return numericTransferUnits + numericTestUnits;
  };

  // Expose methods
  return {
    chooseDefaultSemester: chooseDefaultSemester,
    containsLawClass: containsLawClass,
    containsMidpointClass: containsMidpointClass,
    countSectionItem: countSectionItem,
    courseCollectionHasTopics: courseCollectionHasTopics,
    filterBySectionSlug: filterBySectionSlug,
    findSemester: findSemester,
    getAllClasses: getAllClasses,
    getUniqueCareerCodes: getUniqueCareerCodes,
    getClassesSections: getClassesSections,
    getPreviousClasses: getPreviousClasses,
    hasTeachingClasses: hasTeachingClasses,
    isLSStudent: isLSStudent,
    isSummerSemester: isSummerSemester,
    normalizeGradingData: normalizeGradingData,
    parseGpaUnits: parseGpaUnits,
    showGpa: showGpa,
    showResidency: showResidency,
    summarizeStudentClassTopics: summarizeStudentClassTopics,
    textbookRequestInfo: textbookRequestInfo,
    totalTransferUnits: totalTransferUnits
  };
});
