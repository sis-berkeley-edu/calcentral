'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Campus Links Factory
 */
angular.module('calcentral.factories').factory('campusLinksFactory', function(apiService, academicStatusFactory, $http) {
  // Data contains "links" and "navigation"
  var linkDataUrl = '/api/my/campuslinks';
  var academicRoles = {};

  /**
   * Add to the subcategories list if it doesn't exist yet
   * @param {String} subcategory The subcategory you want to add
   * @param {Array} subcategories The subcategories array
   */
  var addToSubcategories = function(subcategory, subcategories) {
    if (subcategories.indexOf(subcategory) === -1) {
      subcategories.push(subcategory);
    }
  };

  /**
   * Add to the top categories
   * @param {Object} link Link object
   * @param {Object} topcategories Top categories object
   */
  var addToTopCategories = function(link, topcategories) {
    for (var i = 0; i < link.categories.length; i++) {
      topcategories[link.categories[i].topcategory] = true;
    }
  };

  var hasWhitelistedRole = function(linkRoles) {
    var userRoles = apiService.user.profile.roles;
    return _.some(linkRoles, function(value, key) {
      return userRoles[key] === value;
    });
  };

  var hasBlacklistedRole = function(linkRoles) {
    return _.some(academicRoles, function(hasRole, role) {
      return hasRole && linkRoles[role] === false;
    });
  };

  var userCanView = function(link) {
    return hasWhitelistedRole(link.roles) && !hasBlacklistedRole(link.roles);
  };

  /**
   * Check whether a link is in a current category
   * @param {Object} link Link object
   * @param {String} currentTopCategory The current top category
   * @return {Boolean} Whether a link is in the current category
   */
  var isLinkInCategory = function(link, currentTopCategory) {
    link.subCategories = [];
    for (var i = 0; i < link.categories.length; i++) {
      if (link.categories[i].topcategory === currentTopCategory) {
        link.subCategories.push(link.categories[i].subcategory);
      }
    }
    return (link.subCategories.length > 0);
  };

  /**
   * Compile the campus links
   * @param {Array} links The list of links that need to be parsed
   */
  var compileLinks = function(links, currentTopCategory) {
    var response = {
      links: [],
      subcategories: [],
      topcategories: {}
    };
    angular.forEach(links, function(link) {
      if (userCanView(link)) {
        addToTopCategories(link, response.topcategories);

        if (isLinkInCategory(link, currentTopCategory)) {
          response.links.push(link);
          for (var i = 0; i < link.subCategories.length; i++) {
            addToSubcategories(link.subCategories[i], response.subcategories);
          }
        }
      }
    });
    response.subcategories.sort();
    return response;
  };

  /**
   * Get the category name, when you feed in an id
   * @param {String} categoryId A category id
   * @param {Object} navigation The navigation object
   * @return {String} The category name
   */
  var getCategoryName = function(categoryId, navigation) {
    // We want to explicitly check for undefined here
    // since other values need to result in a 404.
    if (categoryId === undefined) {
      return navigation[0].categories[0].name;
    }

    for (var i = 0; i < navigation.length; i++) {
      for (var j = 0; j < navigation[i].categories.length; j++) {
        if (navigation[i].categories[j].id === categoryId) {
          return navigation[i].categories[j].name;
        }
      }
    }
  };

  var parseCampusLinks = function(campusLinksResponse, categoryId) {
    var data = campusLinksResponse.data;

    if (!data.navigation) {
      return;
    }

    var currentTopCategory = getCategoryName(categoryId, data.navigation);
    var compileResponse = compileLinks(data.links, currentTopCategory);

    data.currentTopCategory = currentTopCategory;
    data.links = compileResponse.links;
    data.subcategories = compileResponse.subcategories;
    data.topcategories = compileResponse.topcategories;

    return data;
  };

  var getCampusLinks = function() {
    return $http.get(linkDataUrl, {
      cache: true
    });
  };

  var loadAcademicRoles = function() {
    return academicStatusFactory.getAcademicRoles().then(function(parsedAcademicRoles) {
      academicRoles = _.get(parsedAcademicRoles, 'roles');
    });
  };

  var getUserRoles = function() {
    return apiService.user.fetch();
  };

  var getLinks = function(options) {
    apiService.http.clearCache(options, linkDataUrl);

    return getUserRoles()
      .then(loadAcademicRoles)
      .then(getCampusLinks)
      .then(function(response) {
        return parseCampusLinks(response, options.category);
      });
  };

  return {
    getLinks: getLinks
  };
});
