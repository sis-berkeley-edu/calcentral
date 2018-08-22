'use strict';

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

<<<<<<< HEAD
=======
  var phoneActionCompleted = function(response) {
    apiService.profile.actionCompleted($scope.emergencyPhone, response, loadInformation);
  };

  var phoneDeleteCompleted = function(response) {
    $scope.emergencyPhone.isDeleting = false;
    phoneActionCompleted(response);
  };

  var phoneSaveCompleted = function(response) {
    $scope.emergencyPhone.isSaving = false;
    phoneActionCompleted(response);
  };

  $scope.emergencyPhone.cancelEdit = function() {
    var item = $scope.emergencyPhone.currentObject.data;
    $scope.emergencyPhone.isModifying = false;
    $scope.emergencyPhone.isSaving = false;
    $scope.emergencyPhone.closeEditor();

    // Code smell: manual cleanup of isModifying on parent scoped phone.
    _.each($scope.currentObject.data.emergencyPhones, function(phone) {
      if (phone.contactName === item.contactName && phone.phoneType === item.phoneType) {
        phone.isModifying = false;
      }
    });
  };

  $scope.emergencyPhone.closeEditor = function() {
    $scope.emergencyPhone.isAdding = false;
    apiService.profile.closeEditor($scope.emergencyPhone);
  };

  $scope.emergencyPhone.deletePhone = function(item) {
    return apiService.profile.delete($scope, profileFactory.deleteEmergencyPhone, {
      contactName: item.contactName,
      phoneType: item.phoneType
    }).then(phoneDeleteCompleted);
  };

  $scope.emergencyPhone.save = function(item) {
    item.contactName = item.contactName || $scope.currentObject.data.contactName;

    return apiService.profile.save($scope, profileFactory.postEmergencyPhone, {
      // Let Campus Solutions growl about any required field errors.
      contactName: item.contactName,
      phone: item.phone,
      phoneType: item.phoneType,
      extension: item.extension,
      countryCode: item.countryCode
    }).then(phoneSaveCompleted);
  };

  $scope.emergencyPhone.showAdd = function() {
    apiService.profile.showAdd($scope.emergencyPhone, $scope.emergencyPhone.emptyObject);

    // Reduce the possible phone types displayed in the select box in the Add
    // Phone case where a contact may already have at least one phone with a
    // phone type.
    var currentPhones = $scope.currentObject.data.emergencyPhones;
    var item = $scope.emergencyPhone.currentObject.data;
    var availablePhoneTypes = item.availablePhoneTypes;
    var usingTypes = [];

    item.availablePhoneTypes = _.filter(availablePhoneTypes, function(type) {
      _.forEach(currentPhones, function(phone) {
        if (type.fieldvalue === phone.phoneType) {
          usingTypes.push(type.fieldvalue);
        }
      });
      return usingTypes.indexOf(type.fieldvalue) < 0;
    });
    if (item.availablePhoneTypes.length === 1) {
      item.phoneType = item.availablePhoneTypes[0].fieldvalue;
      item.phoneTypeDescr = item.availablePhoneTypes[0].xlatlongname;
    }

    $scope.emergencyPhone.isAdding = true;
  };

  $scope.emergencyPhone.showEdit = function(item) {
    // Insert safe defaults for any null or undefined values on the item to be
    // edited.
    _.forEach(item, function(v, k) {
      item[k] = sanitizeContactData(v);
    });

    $scope.emergencyPhone.isModifying = true;
    apiService.profile.showEdit($scope.emergencyPhone, item);
  };

  /*
   * Processes each emergencyContact for any emergencyPhones listed, creates a
   * flattened one-dimensional array of all phone objects, associates the
   * contactName with each phone for later use by post and delete, and assigns
   * the flat array to the inner `emergencyPhone` scope's contents.
   */
>>>>>>> SISRP-40088 - Move from Gulp to Webpack for Front-End Build (fix ESLint errors)
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

<<<<<<< HEAD
=======
  var fixFormattedAddress = function(emergencyContact) {
    var formattedAddress = emergencyContact.formattedAddress || '';

    emergencyContact.formattedAddress = apiService.profile.fixFormattedAddress(formattedAddress);
  };

  var getTypesRelationship = profileFactory.getTypesRelationship;
  var parseTypesRelationship = function(response) {
    var relationshipTypes = apiService.profile.filterTypes(_.get(response, 'data.feed.xlatvalues.values'), $scope.items);

    $scope.relationshipTypes = sortRelationshipTypes(relationshipTypes);
  };

  /*
   * Sort relationshipTypes array in ascending order by description (text
   * displayed in select element), while pushing options representing "Other
   * Relative" (`R`), and generic "Other" (`O`) to the end of the sorted array.
   */
  var sortRelationshipTypes = function(types) {
    var OTHER_RELATIONSHIP = ['O', 'R'];

    return types.sort(function(a, b) {
      var left = a.fieldvalue;
      var right = b.fieldvalue;

      if (OTHER_RELATIONSHIP.indexOf(left) !== -1) {
        return 1;
      } else if (OTHER_RELATIONSHIP.indexOf(right) !== -1) {
        return -1;
      } else {
        return a.xlatlongname > b.xlatlongname;
      }
    });
  };

  var getCountries = profileFactory.getCountries;
  var parseCountries = function(response) {
    $scope.countries = _.sortBy(_.filter(_.get(response, 'data.feed.countries'), {
      hasAddressFields: true
    }), 'descr');
  };

  var countryWatch = function(country) {
    if (!country) {
      return;
    }

    $scope.currentObject.whileAddressFieldsLoading = true;

    profileFactory.getAddressFields({
      country: country
    })
    .then(parseAddressFields)
    .then(function() {
      // Get the states for specified country (if available)
      return profileFactory.getStates({
        country: country
      });
    })
    .then(parseStates)
    .then(function() {
      $scope.currentObject.whileAddressFieldsLoading = false;
    });
  };

  var parseAddressFields = function(response) {
    $scope.currentObject.addressFields = _.get(response, 'data.feed.labels');
  };

  var parseStates = function(response) {
    $scope.states = _.sortBy(_.get(response, 'data.feed.states'), 'descr');
  };

  /**
   * We need to watch when the country changes, if so, load the address fields
   * dynamically depending on the country.
   */
  var countryWatcher;

  var startCountryWatcher = function() {
    countryWatcher = $scope.$watch('currentObject.data.country', countryWatch);
  };

  /*
   *  If we're in the contact editor and we've updated a secondary emergency
   *  phone in the phone editor, then we need to grab the current contact being
   *  edited and match it with the updated item returned by the refreshed feed,
   *  and then pass the updated item to `showEdit` which repopulates the form
   *  with the updated information.
   */
  var refreshContactEditor = function() {
    var editingContact = $scope.currentObject.data;

    if (!editingContact) {
      return;
    }

    $scope.closeEditor();

    _.some($scope.items.content, function(contact) {
      var test = editingContact.contactName === contact.contactName && editingContact.relationship === contact.relationship;
      if (test) {
        editingContact = contact;
      }
      return test;
    });

    // Unset these so the contact editor controls are enabled.
    $scope.isSaving = false;
    $scope.isDeleting = false;

    $scope.showEdit(editingContact);
  };

>>>>>>> SISRP-40088 - Move from Gulp to Webpack for Front-End Build (fix ESLint errors)
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
