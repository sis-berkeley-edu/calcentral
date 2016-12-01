/* jshint camelcase: false */
'use strict';

var _ = require('lodash');
var angular = require('angular');

angular.module('calcentral.directives').directive('ccAcademicsClassInfoEnrollmentDirective', function(apiService, rosterService) {
  return {
    scope: true,
    link: function(scope, elem, attrs) {
      scope.bmailLink = rosterService.bmailLink;

      /*
       * Returns true if student is in the selected section
       * @returns {Boolean}
       */
      var isStudentInSection = function(student) {
        return (student.section_ccns.indexOf(scope.selectedSection.ccn) !== -1);
      };

      /*
       * Returns object containing message intended for request
       * @return {object}
       */
      var requestMessages = function() {
        var sortingNote = '';
        var action = scope.displayedSection;
        var role = scope.studentRole;
        var semesterName = scope.semesterName;
        var subjectEnd = scope.className + ' class for ' + semesterName;
        if (role === 'waitlisted') {
          sortingNote = 'The above students are listed by waitlist priority. ';
        }
        if (role === 'enrolled') {
          sortingNote = 'The above students are listed alphabetically by last name. ';
        }

        var messages = {
          action: scope.displayedSection,
          subjectRequest: '',
          bodyRequest: '',
          sortingNote: sortingNote
        };

        switch (action) {
          case 'promote': {
            messages.subjectRequest = 'Request to promote waitlisted students in ' + subjectEnd;
            messages.bodyRequest = 'PROMOTE the following waitlisted students to the top of the wait list:\n';
            break;
          }
          case 'enroll': {
            messages.subjectRequest = 'Request to enroll waitlisted students in ' + subjectEnd;
            messages.bodyRequest = 'ENROLL the following waitlisted students into the class:\n';
            break;
          }
          case 'remove': {
            messages.subjectRequest = 'Request to remove waitlisted students from ' + subjectEnd;
            messages.bodyRequest = 'REMOVE the following waitlisted students from the wait list:\n';
            break;
          }
          case 'drop': {
            messages.subjectRequest = 'Request to drop enrolled students from ' + subjectEnd;
            messages.bodyRequest = 'DROP the following enrolled students from any enrolled sections:\n';
            break;
          }
        }
        return messages;
      };

      /*
       * Returns section list string
       * @param {Array} array of students sections
       * @returns {String}
       */
      var sectionNameList = function(sections) {
        if (typeof(sections) === 'undefined' || sections.length === 0) {
          return '';
        } else {
          return _.map(sections, 'name').join(', ');
        }
      };

      /*
       * Returns true if a section is not selected
       * @returns {Boolean}
       */
      var sectionNotSelected = function() {
        return !scope.selectedSection;
      };

      /*
       * Returns array of selected students
       * @returns {Array} selected students
       */
      var selectedStudents = function() {
        return _.filter(scope.students, function(student) {
          return student.selected === true;
        });
      };

      /*
       * Converts array of students to array containing sections with applicable students
       * @param {Array} student list
       * @return {object}
       */
      var studentsGroupedBySections = function(students) {
        var groupedStudents = {};
        _.forEach(students, function(student) {
          if (typeof(student.sections) === 'object') {
            _.forEach(student.sections, function(section) {
              if (section.ccn) {
                if (typeof(groupedStudents[section.ccn]) === 'undefined') {
                  groupedStudents[section.ccn] = {};
                  groupedStudents[section.ccn].name = section.name;
                  groupedStudents[section.ccn].ccn = section.ccn;
                  groupedStudents[section.ccn].students = [];
                }
                groupedStudents[section.ccn].students.push(student);
              }
            });
          }
        });
        return groupedStudents;
      };

      /*
       * Returns students in selected section
       * @returns {Array} students in selected section
       */
      var studentsInSelectedSection = function() {
        if (scope.students) {
          if (sectionNotSelected()) {
            return scope.students;
          }
          return _.filter(scope.students, isStudentInSection);
        } else {
          return [];
        }
      };

      /*
       * Returns string containing formatted list of students grouped by sections
       * @param {Array} student list
       * @return {String}
       */
      var sectionGroupedTextStudentList = function(students) {
        var list = '';
        var line = '------------------------------\n\n';
        var sections = studentsGroupedBySections(students);
        var sectionKeys = Object.keys(sections);
        _.forEach(sectionKeys, function(key) {
          var currentSection = sections[key];
          list = list.concat(line);
          list = list.concat('Section: ' + currentSection.name + '\n');
          list = list.concat('Class Number: ' + currentSection.ccn + '\n\n');
          list = list.concat(textStudentList(currentSection.students));
        });
        list = list.concat(line);
        return list;
      };

      /*
       * Returns tab spaced table of students. Sorted by waitlist position when studentRole is 'waitlisted'
       * @return {String}
       */
      var textStudentList = function(students, includeSections) {
        var includeSectionsList = (typeof includeSections !== 'undefined') ? includeSections : false;
        var list = '';
        var isWaitlist = scope.studentRole === 'waitlisted';
        var sortMethod = 'last_name';
        if (isWaitlist) {
          sortMethod = 'waitlist_position';
        }
        students = _.sortBy(students, sortMethod);
        _.forEach(students, function(student) {
          if (isWaitlist) {
            list = list.concat('Waitlist Position: ' + student.waitlist_position + '\n');
          }
          list = list.concat('Student ID: ' + student.student_id + '\n');
          list = list.concat('Last Name: ' + student.last_name + '\n');
          list = list.concat('First Name: ' + student.first_name + '\n');
          if (includeSectionsList) {
            list = list.concat('Sections: ' + sectionNameList(student.sections) + '\n');
          }
          list = list.concat('Career: ' + student.academic_career + '\n');
          list = list.concat('\n');
        });
        return list;
      };

      /*
       * Deselects all selected students
       */
      scope.clearSelected = function() {
        if (scope.students) {
          _.forEach(scope.students, function(student) {
            student.selected = false;
          });
        }
      };

      /*
       * Switches display to section specified
       * @param {String} sectionName - Name of the section to be displayed. Valid section names include 'addresses', 'promote', 'enroll', 'remove', and 'drop'
       */
      scope.displaySection = function(sectionName) {
        scope.displayedSection = sectionName;
      };

      /*
       * Returns true if message section displayed
       * @returns {Boolean}
       */
      scope.isMessageDisplay = function() {
        if (['promote', 'enroll', 'remove', 'drop'].indexOf(scope.displayedSection) !== -1) {
          return true;
        }
        return false;
      };

      /*
       * Provides message including information for selected students based
       * on the current displayedSection value
       * @return {String}
       */
      scope.messageForSelectedStudents = function() {
        var currentlySelectedStudents = selectedStudents();
        var messages = requestMessages();
        var bodyLines = [
          'BODY\n',
          'Schedule or enrollment manager,\n',
          'Within the constraints of pre-requisites (if normally enforced for this class), reserve capacity, overall class capacity and any other relevant concerns, please fulfill the following request for students enrolled or on the wait list for ' + scope.className + ' for ' + scope.semesterName + '.\n',
          'REQUEST: ' + messages.bodyRequest,
          textStudentList(currentlySelectedStudents, true) + messages.sortingNote + 'The students are also broken out by individual section and Class Number below.',
          'If this request cannot be fulfilled in a reasonable amount of time, please let me know.\n',
          'Thank you',
          scope.instructorName,
          '\n' + sectionGroupedTextStudentList(currentlySelectedStudents)
        ];
        var message = 'SUBJECT\n\n' + messages.subjectRequest + '\n\n' + bodyLines.join('\n');
        return message;
      };

      /*
       * Returns true if no students are selected
       * @returns {Boolean}
       */
      scope.noStudentsSelected = function() {
        return selectedStudents().length === 0;
      };

      /*
       * Performs accessibility announcement and deselects all students
       */
      scope.sectionChangeActions = function() {
        apiService.util.accessibilityAnnounce('Enrollment filtered by section');
        scope.clearSelected();
      };

      /*
       * Returns true if no section selected, or if student is in the selected section
       * @param {object} student - A student object
       * @returns {Boolean}
       */
      scope.studentInSectionFilter = function(student) {
        return (sectionNotSelected() || isStudentInSection(student));
      };

      /*
       * Returns list of student email addresses that are selected
       * @returns {string}
       */
      scope.selectedStudentsEmailList = function() {
        var students = selectedStudents();
        if (students) {
          return _.map(students, function(student) {
            return student.email;
          }).join(',');
        } else {
          return '';
        }
      };

      /*
       * Selects all students in selected section, or deselects all students entirely
       */
      scope.toggleSelected = function() {
        if (selectedStudents().length === 0) {
          _.forEach(studentsInSelectedSection(), function(student) {
            student.selected = true;
          });
        } else {
          scope.clearSelected();
        }
      };

      scope.$watch(
        function() {
          return scope.$eval(attrs.students);
        },
        function(newValue) {
          scope.students = newValue;
          var studentCount = Array.isArray(newValue) ? newValue.length : 0;
          scope.seatsAvailable = scope.seatsLimit - studentCount;
        }
      );

      scope.displaySection('default');
      scope.className = scope.$eval(attrs.className);
      scope.instructorName = scope.$eval(attrs.instructorName);
      scope.seatsLimit = scope.$eval(attrs.seatsLimit);
      scope.semesterName = scope.$eval(attrs.semesterName);
      scope.showPosition = scope.$eval(attrs.showPosition);
      scope.studentRole = (attrs.title === 'Wait List') ? 'waitlisted' : 'enrolled';
      scope.tableSort = {
        'column': (scope.showPosition ? 'waitlist_position' : ['last_name', 'first_name']),
        'reverse': false
      };
      scope.title = attrs.title;
    },
    templateUrl: 'directives/academics_class_info_enrollment.html'
  };
});
