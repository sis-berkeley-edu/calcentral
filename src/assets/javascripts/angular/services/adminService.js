'use strict';

angular.module('calcentral.services').service('adminService', function(adminFactory, apiService) {
  var actAs = function(user) {
    var isAdvisorOnly = apiService.user.profile.roles.advisor &&
      !apiService.user.profile.isSuperuser &&
      !apiService.user.profile.isViewer;
    var actAs = isAdvisorOnly ? adminFactory.advisorActAs : adminFactory.actAs;
    return actAs({
      uid: getLdapUid(user)
    }).then(apiService.util.redirectToHome);
  };

  var getLdapUid = function(user) {
    return user && (user.ldap_uid || user.ldapUid || user.campusUid);
  };

  return {
    actAs: actAs,
    getLdapUid: getLdapUid
  };
});
