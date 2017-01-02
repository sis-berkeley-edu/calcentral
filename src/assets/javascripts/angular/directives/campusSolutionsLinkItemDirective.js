'use strict';

var angular = require('angular');

/**
 * Directive used to render a link provided by the Campus Solutions Link API (see CampusSolutions::Link)
 *
 * Usage:
 *   <div data-cc-campus-solutions-link-item-directive data-link="csLinkApiObject"></div>
 *
 *   data-link="csLinkApiObject"
 *   data-cache="finaid"
 *   data-text="Manually Overridden Link Text"
 *   data-disabled="true"
 */
angular.module('calcentral.directives').directive('ccCampusSolutionsLinkItemDirective', function() {
  return {
    templateUrl: 'directives/campus_solutions_link_item.html',
    scope: {
      cache: '@',
      link: '=',
      text: '@',
      disabled: '@'
    }
  };
});
