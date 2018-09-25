'use strict';

var _ = require('lodash');

/**
 * Emergency Contact controller
 */
angular.module('calcentral.controllers').controller('EmergencyContactController', function(apiService, profileFactory, $scope) {
  var defaultCountry = 'USA';

  angular.extend($scope, {
    currentObject: {},
    emptyObject: {
      country: defaultCountry,
      primaryContact: 'N',
      sameAddressEmpl: 'N',
      samePhoneEmpl: 'N'
    },
    errorMessage: '',
    isLoading: true,
    isSaving: false,
    items: {
      content: [],
      editorEnabled: false
    }
  });

  /**
   * Emergency contact editor controls.
   */

  // Helper function that returns a safe default (empty string) for Campus
  // Solutions APIs if a value is specifically `null` or `undefined`.
  var sanitizeContactData = function(value) {
    return _.isNil(value) ? '' : value;
  };

  var actionCompleted = function(response) {
    apiService.profile.actionCompleted($scope, response, loadInformation);
  };

  var deleteCompleted = function(response) {
    $scope.isDeleting = false;
    actionCompleted(response);
  };

  var saveCompleted = function(response) {
    $scope.isSaving = false;
    actionCompleted(response);
  };

  $scope.closeEditor = function() {
    apiService.profile.closeEditor($scope);
  };

  $scope.cancelEdit = function() {
    $scope.isSaving = false;
    $scope.closeEditor();
  };

  $scope.deleteContact = function(item) {
    return apiService.profile.delete($scope, profileFactory.deleteEmergencyContact, {
      contactName: item.contactName
    }).then(deleteCompleted);
  };

  $scope.saveContact = function(item) {
    // Take only the first phone in the list. Any others are handled
    // individually by the inner `emergencyPhone` scope.
    var phone = item.emergencyPhones[0];

    apiService.profile.save($scope, profileFactory.postEmergencyContact, {
      // Override these to false to allow any address changes.
      isSameAddressEmpl: 'N',
      isSamePhoneEmpl: 'N',
      // Let Campus Solutions growl about any required field errors.
      contactName: item.contactName,
      isPrimaryContact: item.primaryContact,
      relationship: item.relationship,
      addrField1: item.addrField1,
      addrField2: item.addrField2,
      addrField3: item.addrField3,
      address1: item.address1,
      address2: item.address2,
      address3: item.address3,
      address4: item.address4,
      addressType: item.addressType,
      city: item.city,
      country: item.country,
      county: item.county,
      emailAddr: item.emailAddr,
      geoCode: item.geoCode,
      houseType: item.houseType,
      inCityLimit: item.inCityLimit,
      num1: item.num1,
      num2: item.num2,
      phone: phone.phone,
      phoneType: phone.phoneType,
      extension: phone.extension,
      postal: item.postal,
      state: item.state
    }).then(saveCompleted);
  };

  $scope.showAdd = function() {
    $scope.emptyObject.emergencyPhones = [angular.copy($scope.emergencyPhone.firstEmptyObject)];

    apiService.profile.showAdd($scope, $scope.emptyObject);
  };

  $scope.showEdit = function(item) {
    // Insert safe defaults for any null or undefined values on the item to be
    // edited.
    _.forEach(item, function(v, k) {
      if (!v && k === 'country') {
        item[k] = defaultCountry;
      } else {
        item[k] = sanitizeContactData(v);
      }
    });
    apiService.profile.showEdit($scope, item);
  };

  /**
   * Emergency Phone editor acts as an "inner scope" - `emergencyPhone` - with
   * respect to the parent or `EmergencyContact` scope. That allows us to pass
   * it to the `profileService` methods for safely updating the phone editor
   * state.
   */
  angular.extend($scope, {
    emergencyPhone: {
      currentObject: {},
      firstEmptyObject: {
        phone: '',
        phoneType: '',
        extension: '',
        countryCode: ''
      },
      emptyObject: {
        availablePhoneTypes: [],
        phone: '',
        phoneType: '',
        extension: '',
        countryCode: ''
      },
      errorMessage: '',
      isAdding: false,
      isDeleting: false,
      isLoading: true,
      isModifying: false,
      isSaving: false,
      items: {
        content: [],
        editorEnabled: false
      }
    }
  });

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

  var parseEmergencyPhones = function(emergencyContacts) {
    $scope.emergencyPhone.isLoading = true;

    var phones = _.map(emergencyContacts, function(contact) {
      if (_.isEmpty(contact.emergencyPhones)) {
        // Provides an empty phone to display, if no emergency phones have been
        // added yet. This enables contact editor to show empty phone inputs.
        contact.emergencyPhones = [angular.copy($scope.emergencyPhone.firstEmptyObject)];
      }

      _.each(contact.emergencyPhones, function(phone) {
        phone.contactName = contact.contactName;
      });

      return contact.emergencyPhones;
    });

    $scope.emergencyPhone.items.content = _.flattenDeep(phones);
    $scope.emergencyPhone.isLoading = false;
  };

  var getTypesPhone = profileFactory.getTypesPhone;

  var parseTypesPhone = function(response) {
    var allowedTypes = _.get(response, 'data.feed.xlatvalues.values');
    _.forEach($scope.items.content, function(contact) {
      var phones = contact.emergencyPhones;

      // In the Campus Solutions interface, the first phone in the list for a
      // contact is never assigned a phoneType. This block creates a custom
      // property, addPhoneLimit, on each contact, in order to allow the first
      // phone to continue to have no phoneType, and allow the user to add an
      // additional phone beyond the number of "allowed" phone types for each
      // contact.
      var addPhoneLimit = allowedTypes.length;
      if (phones.length && !phones[0].phoneType) {
        addPhoneLimit += 1;
      }
      contact.addPhoneLimit = addPhoneLimit;

      // This block creates a custom property, availablePhoneTypes, on each
      // phone as a list of types available to be assigned to that phone from
      // the select box. A type is "available" if the type is _not_ used by
      // another phone in a contact's phone list, or if the type matches that of
      // the phone being examined during iteration.
      var usingTypes = _.map(phones, function(phone) {
        return phone.phoneType;
      });
      _.forEach(phones, function(phone, pos) {
        if (pos > 0) {
          phone.availablePhoneTypes = _.filter(allowedTypes, function(type) {
            return usingTypes.indexOf(type.fieldvalue) < 0 || type.fieldvalue === phone.phoneType;
          });
        }
      });
    });

    // Make allowedTypes available to the select box for the Add Contact case.
    $scope.emergencyPhone.emptyObject.availablePhoneTypes = allowedTypes;
  };

  /**
   * Sequence of functions for loading emergencyContact and emergencyPhone data.
   */
  var getEmergencyContacts = profileFactory.getEmergencyContacts;

  var parseEmergencyContacts = function(response) {
    var emergencyContacts = _.get(response, 'data.feed.students.student.emergencyContacts.emergencyContact') || [];

    parseEmergencyPhones(emergencyContacts);

    _(emergencyContacts).each(function(emergencyContact) {
      fixFormattedAddress(emergencyContact);
    });

    $scope.items.content = emergencyContacts;
  };

  var fixFormattedAddress = function(emergencyContact) {
    var formattedAddress = emergencyContact.formattedAddress || '';

    emergencyContact.formattedAddress = apiService.profile.fixFormattedAddress(formattedAddress);
  };

  var getTypesRelationship = profileFactory.getTypesRelationship;
  var parseTypesRelationship = function(response) {
    var relationshipTypes = apiService.profile.filterTypes(_.get(response, 'data.feed.xlatvalues.values'), $scope.items);

    $scope.relationshipTypes = sortRelationshipTypes(relationshipTypes);
  };

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

  var loadInformation = function() {
    $scope.isLoading = true;

    // If we were previously watching a country, we need to remove that
    if (countryWatcher) {
      countryWatcher();
    }

    getEmergencyContacts({
      refreshCache: true
    })
    .then(parseEmergencyContacts)
    .then(getTypesRelationship)
    .then(parseTypesRelationship)
    .then(getTypesPhone)
    .then(parseTypesPhone)
    .then(getCountries)
    .then(parseCountries)
    .then(startCountryWatcher)
    .then(refreshContactEditor)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
