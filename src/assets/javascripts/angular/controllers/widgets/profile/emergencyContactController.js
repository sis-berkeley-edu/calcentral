'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Emergency Contact controller
 */
angular.module('calcentral.controllers').controller('EmergencyContactController', function(apiService, profileFactory, $scope) {
  angular.extend($scope, {
    isLoading: true,
    items: {
      content: []
    },
    emergencyPhone: {
      isLoading: true,
      items: {
        content: []
      }
    }
  });

  var parseEmergencyPhones = function(emergencyContacts) {
    var phones = _.map(emergencyContacts, function(contact) {
      _.each(contact.emergencyPhones, function(phone) {
        phone.contactName = contact.contactName;
      });

      return contact.emergencyPhones;
    });

    $scope.emergencyPhone.items.content = _.flattenDeep(phones);
    $scope.emergencyPhone.isLoading = false;
  };

  var fixFormattedAddress = function(emergencyContact) {
    var formattedAddress = emergencyContact.formattedAddress || '';
    emergencyContact.formattedAddress = apiService.profile.fixFormattedAddress(formattedAddress);
  };

  var parseEmergencyContacts = function(response) {
    var emergencyContacts = _.get(response, 'data.feed.students.student.emergencyContacts.emergencyContact') || [];

    parseEmergencyPhones(emergencyContacts);

    _(emergencyContacts).each(function(emergencyContact) {
      fixFormattedAddress(emergencyContact);
    });

    $scope.items.content = emergencyContacts;
  };

  var loadInformation = function() {
    $scope.isLoading = true;

    profileFactory.getEmergencyContacts({
      refreshCache: true
    })
    .then(parseEmergencyContacts)
    .finally(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
