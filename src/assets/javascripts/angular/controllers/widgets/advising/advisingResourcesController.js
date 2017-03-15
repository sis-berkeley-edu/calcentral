'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Advising Resources Controller
 * Show Campus Solutions links and favorite reports
 */
angular.module('calcentral.controllers').controller('AdvisingResourcesController', function(advisingFactory, apiService, linkService, $scope) {
  $scope.advisingResources = {
    isLoading: true
  };

  /**
   * Configuration for the sections displayed
   * @type {Array}
   */
  var sections = [
    {
      sectionTitle: 'Tools',
      linkIds: [
        'ucAppointmentSystem',
        'ucClassSearch',
        'ucEformsActionCenter',
        'ucEformsWorkCenter',
        'ucReportingCenter'
      ],
      links: []
    },
    {
      sectionTitle: 'Student Specific Links',
      linkIds: [
        'ucAcademicProgressReport',
        'ucAdministrativeTranscript',
        'ucAdvisingAssignments',
        'ucArchivedTranscripts',
        'ucChangeCourseLoad',
        'ucMilestones',
        'ucMultiYearAcademicPlannerGeneric',
        'ucServiceIndicators',
        'ucTransferCreditReport',
        'ucWhatIfReports',
        'webNowDocuments'
      ],
      links: []
    }
  ];

  /**
   * Sorts section links alphabetically by the 'name' property
   */
  var alphabetizeSectionLinks = function() {
    _.forEach(sections, function(section) {
      if (section.links.length > 0) {
        section.links = _.orderBy(section.links, function(link) {
          return _.toString(link.name).toLowerCase();
        });
      }
    });
  };

  /**
   * Adds page name and url to link resource sets
   */
  var addPagePropertiesToLinks = function(resources) {
    linkService.addCurrentPagePropertiesToResources(resources, $scope.currentPage.name, $scope.currentPage.url);
  };

  /**
   * Populates the configured sections array with resource links
   */
  var populateSections = function(resources) {
    _.forEach(sections, function(section) {
      _.forEach(section.linkIds, function(linkId) {
        var link = _.get(resources, linkId);
        if (link) {
          section.links.push(link);
        }
      });
    });
  };

  /**
   * Parse the advising resources
   */
  var parseResources = function(data) {
    var resources = _.get(data, 'data.feed.csLinks');
    if (resources) {
      addPagePropertiesToLinks(resources);
      populateSections(resources);
      alphabetizeSectionLinks();
      $scope.sections = sections;
    }
    $scope.advisingResources.isLoading = false;
  };

  /**
   * Load the advising resources
   */
  var loadResources = function() {
    advisingFactory.getResources().then(parseResources);
  };

  loadResources();
});
