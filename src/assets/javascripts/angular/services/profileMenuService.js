'use strict';

var _ = require('lodash');

/**
 * Profile Menu Serives - provide all the information for the profile menu
 */
angular
  .module('calcentral.services')
  .factory('profileMenuService', function(apiService, $q) {
    var navigation = [
      {
        label: 'Profile',
        categories: [
          {
            id: 'basic',
            name: 'Basic Information',
            roles: {
              applicant: true,
              student: true,
            },
          },
          {
            id: 'basic_nonstudent',
            name: 'Basic Information',
            roles: {
              student: false,
            },
          },
          {
            id: 'contact',
            name: 'Contact Information',
            roles: {
              applicant: true,
              student: true,
            },
          },
          {
            id: 'emergency',
            name: 'Emergency Contact',
            featureFlag: 'csProfileEmergencyContacts',
            roles: {
              applicant: true,
              student: true,
            },
          },
          {
            id: 'demographic',
            name: 'Demographic Information',
            roles: {
              applicant: true,
              student: true,
            },
          },
        ],
      },
      {
        label: 'Privacy & Permissions',
        categories: [
          {
            id: 'delegate',
            name: 'Delegate Access',
            featureFlag: 'csDelegatedAccess',
            roles: {
              student: true,
            },
            hideWhenActAsModes: ['advisorActingAsUid'],
          },
          {
            id: 'information-disclosure',
            name: 'Information Disclosure (FERPA)',
            roles: {
              student: true,
            },
          },
        ],
      },
      {
        label: 'Credentials',
        categories: [
          {
            id: 'languages',
            name: 'Languages',
            featureFlag: 'csProfileLanguages',
            roles: {
              applicant: true,
              student: true,
            },
          },
          {
            id: 'work-experience',
            name: 'Work Experience',
            featureFlag: 'csProfileWorkExperience',
            roles: {
              applicant: true,
              student: true,
              summerVisitor: false,
            },
          },
        ],
      },
      {
        label: 'Alerts & Notifications',
        categories: [
          {
            id: 'bconnected',
            name: 'bConnected',
            hideWhenActAsModes: ['advisorActingAsUid'],
          },
        ],
      },
    ];

    var defer = function(navigation, callback) {
      var deferred = $q.defer();

      navigation = callback(navigation);

      deferred.resolve(navigation);
      return deferred.promise;
    };

    var filterCategories = function(navigation, callback) {
      return _.map(navigation, function(item) {
        item.categories = callback(item.categories);
        return item;
      });
    };

    var hasWhitelistedRole = function(categoryRoles) {
      var userRoles = apiService.user.profile.roles;
      return _.some(categoryRoles, function(value, key) {
        return userRoles[key] === value;
      });
    };

    var hasBlacklistedRole = function(categoryRoles) {
      var academicRoles = apiService.user.profile.academicRoles.current;
      return _.some(academicRoles, function(hasRole, role) {
        return hasRole && categoryRoles[role] === false;
      });
    };

    var filterRolesInCategory = function(categories) {
      return _.filter(categories, function(category) {
        if (!category.roles) {
          return true;
        } else {
          return (
            hasWhitelistedRole(category.roles) &&
            !hasBlacklistedRole(category.roles)
          );
        }
      });
    };

    var filterRolesInNavigation = function(navigation) {
      return filterCategories(navigation, filterRolesInCategory);
    };

    /*
     * Filter based on the roles
     * If there is no 'roles' definied, we assume everyone should see it
     */
    var filterRoles = function(navigation) {
      return defer(navigation, filterRolesInNavigation);
    };

    var filterFeatureFlagsInCategory = function(categories) {
      var featureFlags = apiService.user.profile.features;
      return _.filter(categories, function(category) {
        if (!category.featureFlag) {
          return true;
        } else {
          return !!featureFlags[category.featureFlag];
        }
      });
    };

    var filterFeatureFlagsInNavigation = function(navigation) {
      return filterCategories(navigation, filterFeatureFlagsInCategory);
    };

    var filterFeatureFlags = function(navigation) {
      return defer(navigation, filterFeatureFlagsInNavigation);
    };

    var filterActAsInCategory = function(categories) {
      var userProfile = apiService.user.profile;
      return _.filter(categories, function(category) {
        if (!_.get(category, 'hideWhenActAsModes.length')) {
          return true;
        } else {
          return !_.some(category.hideWhenActAsModes, function(
            hideWhenActAsMode
          ) {
            return userProfile[hideWhenActAsMode];
          });
        }
      });
    };

    var filterActAsInNavigation = function(navigation) {
      return filterCategories(navigation, filterActAsInCategory);
    };

    var filterActAs = function(navigation) {
      return defer(navigation, filterActAsInNavigation);
    };

    var filterEmptyInNavigation = function(navigation) {
      return _.filter(navigation, function(item) {
        return !!_.get(item, 'categories.length');
      });
    };

    /*
     * If we remove all the links in a certain section, we need to make sure we
     * don't show the heading
     */
    var filterEmpty = function(navigation) {
      return defer(navigation, filterEmptyInNavigation);
    };

    var filterSlateUsers = function(navigation) {
      return defer(navigation, filterSlateUserInNavigation);
    };

    var filterSlateUserInNavigation = function(navigation) {
      return filterCategories(navigation, filterSlateUserInCategory);
    };

    var filterSlateUserInCategory = function(categories) {
      var isSlateUser = apiService.user.profile.isSlateUser;
      return _.filter(categories, function(category) {
        if (!isSlateUser) {
          return true;
        } else {
          return category.id != 'bconnected';
        }
      });
    };

    var initialNavigation = function() {
      return $q(function(resolve) {
        resolve(navigation);
      });
    };

    var getNavigation = function() {
      return apiService.user
        .fetch()
        .then(initialNavigation)
        .then(filterRoles)
        .then(filterFeatureFlags)
        .then(filterActAs)
        .then(filterSlateUsers)
        .then(filterEmpty);
    };

    return {
      getNavigation: getNavigation,
    };
  });
