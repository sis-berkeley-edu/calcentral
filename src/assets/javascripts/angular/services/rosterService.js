/* jshint camelcase: false */
'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.services').factory('rosterService', function($filter) {
  /**
   * Returns link to gMail compose with TO address specified
   * @param {String} toAddress 'TO' address string
   */
  var bmailLink = function(toAddress) {
    var urlEncodedToAddress = encodeURIComponent(toAddress);
    return 'https://mail.google.com/mail/u/0/?view=cm&fs=1&tf=1&source=mailto&to=' + urlEncodedToAddress;
  };

  /**
   * Returns array with AngularJS text filter applied
   * Must use this to maintain parity with template based filter
   * Template Filter Example:
   *   <input data-ng-model="searchOptions.text.$">
   *   <li data-ng-repeat="item in list | filter:searchOptions.text">
   *
   * @param  {Array}  array             Any array of objects
   * @param  {String} textFilterString  text used for search
   * @return {Array}                    Array of filtered results
   */
  var textFilter = function(array, textFilterString) {
    if (_.isEmpty(textFilterString)) {
      return array;
    } else {
      return $filter('filter')(array, {
        $: textFilterString
      });
    }
  };

  /**
   * Returns count if object is an array, otherwise returns 0
   */
  var getCount = function(array) {
    return Array.isArray(array) ? array.length : 0;
  };

  /**
   * Returns array of students from selected section, including statistics
   * @param  {Array}    students            All students in course
   * @param  {Array}    sections            All sections for the course
   * @param  {Object}   searchOptions       Object containing search filtering arguments
   * @param  {Boolean}  useWaitlistCounts   Stats based on waitlist counts when true
   * @return {Object}                       Object containing current student view with statistics
   */
  var getFilteredStudents = function(students, sections, searchOptions, useWaitlistCounts) {
    // apply filters
    var filteredStudents = filterStudents(students, searchOptions);

    // calculate stats
    var openSeatsCount = getOpenSeatCount(sections, searchOptions.section, useWaitlistCounts);
    var shownStudentCount = getCount(filteredStudents);
    var totalStudentCount = getCount(students);
    return {
      shownStudents: filteredStudents,
      shownStudentCount: shownStudentCount,
      totalStudentCount: totalStudentCount,
      openSeatsCount: openSeatsCount
    };
  };

  var filterStudents = function(students, searchOptions) {
    if (students) {
      if (!searchOptions) {
        return students;
      } else {
        var filteredStudents = failsafeArrayFilter(students, isStudentInSection, _.get(searchOptions, 'section'));
        filteredStudents = failsafeArrayFilter(filteredStudents, doesStudentMatchEnrollStatus, _.get(searchOptions, 'enrollStatus'));
        filteredStudents = textFilter(filteredStudents, _.get(searchOptions, 'text'));
        return filteredStudents;
      }
    } else {
      return [];
    }
  };

  /**
   * Indicates if the student matches the enrollment status
   * @param  {Object} student       student object
   * @param  {String} enrollStatus  enrollment status (e.g. 'all', enrolled', 'waitlisted')
   * @return {Boolean}              true or false
   */
  var doesStudentMatchEnrollStatus = function(student, enrollStatus) {
    switch (enrollStatus) {
      case 'enrolled': {
        return (!_.get(student, 'waitlist_position'));
      }
      case 'waitlisted': {
        return (_.get(student, 'waitlist_position'));
      }
      default: {
        return true;
      }
    }
  };

  /**
   * Fail Safe Array Filter
   * @param  {Array}    array         collection being filtered
   * @param  {Function} callback      function used to determine if the item should be included in the array (boolean return)
   * @param  {mixed}    callbackArg   argument sent to the callback with the array item
   * @return {Array}                  filtered array result
   */
  var failsafeArrayFilter = function(array, callback, callbackArg) {
    if (array) {
      if (!callbackArg) {
        return array;
      }
      return _.filter(array, function(arrayItem) {
        return callback(arrayItem, callbackArg);
      });
    } else {
      return [];
    }
  };

  /**
   * Returns the number of available seats for the course, for the specified enrollment status
   * @param  {Array}   sections           all sections for the course
   * @param  {Object}  selectedSection    current selected section
   * @param  {Boolean} useWaitlistCounts  calculates open seat count based on waitlist positions open when true,
   *                                      rather than on enrollment positions open. Defaults to false
   * @return {Number}                     Number of open enrollment or waitlist seats in entire course or selected section
   */
  var getOpenSeatCount = function(sections, selectedSection, useWaitlistCounts) {
    var selectedSectionId = _.get(selectedSection, 'ccn');
    return _.reduce(sections, function(count, section) {
      if (!selectedSectionId || selectedSectionId === _.get(section, 'ccn')) {
        count += !!useWaitlistCounts ? section.waitlist_open : section.enroll_open;
      }
      return count;
    }, 0);
  };

  /**
   * Indicates if student is in a section
   * @param  {Object} student   student object containing array of section CCNs / IDs
   * @param  {Object} section   class section
   * @return {Boolean}          true or false
   */
  var isStudentInSection = function(student, section) {
    return (!section) ? true : (student.section_ccns.indexOf(section.ccn) !== -1);
  };

  return {
    bmailLink: bmailLink,
    getFilteredStudents: getFilteredStudents
  };
});

