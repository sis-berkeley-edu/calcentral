'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('AcademicRecordsController', function(academicRecordsFactory, apiService, csLinkFactory, userService, $scope, $window) {

  $scope.officialTranscript = {
    postParams: {},
    postUrl: '',
    postUrlHover: 'Request your Official Transcript',
    isLoading: true,
    defaultRequestLink: 'http://registrar.berkeley.edu/academic-records/transcripts-diplomas'
  };
  $scope.lawTranscriptLink = {
    link: 'http://www.law.berkeley.edu/php-programs/registrar/forms/transcriptrequestform.php',
    title: 'Request your official Law Transcript'
  };
  $scope.ucbxTranscriptLink = {
    link: 'http://extension.berkeley.edu/static/studentservices/transcripts/#ordertranscripts',
    title: 'Request your University Extension Transcript'
  };
  $scope.lawUnofficialTranscriptLink = {};

  /**
   * Constructs a post request to Credentials Solutions, as outlined by the Credentials Solutions documentation seen in
   * https://confluence.ets.berkeley.edu/confluence/display/MYB/Academic+Records.
   */
  var postRequest = function(url, data) {
    var html = document.implementation.createDocument(null, 'HTML');
    var head = document.createElement('HEAD');
    var body = document.createElement('BODY');
    var form = document.createElement('FORM');
    form.setAttribute('name', 'transcriptRequestForm');
    form.action = url;
    form.method = 'post';
    if (data) {
      _.forOwn(data, function(value, key) {
        var input = document.createElement('INPUT');
        input.type = 'hidden';
        input.name = key.toUpperCase();
        input.value = value;
        form.appendChild(input);
      });
    }
    body.appendChild(form);
    html.documentElement.appendChild(head);
    html.documentElement.appendChild(body);
    var parser = new XMLSerializer();
    var newWindow = $window.open('');
    newWindow.document.write(parser.serializeToString(html));
    newWindow.document.getElementsByName('transcriptRequestForm')[0].submit();
  };

  var parseData = function(data) {
    var transcriptData = _.get(data, 'data.feed.transcriptOrder');
    $scope.officialTranscript.postUrl = _.get(transcriptData, 'credSolLink');
    _.forOwn(transcriptData, function(value, key) {
      if (key !== 'credSolLink' && key !== 'debugDbname') {
        _.set($scope.officialTranscript.postParams, key, value);
      }
    });
  };

  var fetchLawUnofficialTranscriptLink = function() {
    csLinkFactory.getLink({
      urlId: 'UC_CX_RQST_UNOFF_LAW_TRANSCRPT',
      placeholders: {
        EMPLID: userService.profile.sid
      }
    })
    .then(function(data) {
      $scope.lawUnofficialTranscriptLink = _.get(data, 'data.link');
    });
  };

  var loadTranscriptData = function() {
    academicRecordsFactory.getTranscriptData()
      .then(function(data) {
        parseData(data);
      })
      .then(fetchLawUnofficialTranscriptLink)
      .finally(function() {
        $scope.officialTranscript.isLoading = false;
      });
  };

  $scope.requestTranscript = function() {
    if (userService.profile.features.transcriptRequestLinkCredSolutions) {
      postRequest($scope.officialTranscript.postUrl, $scope.officialTranscript.postParams);
    } else {
      $window.open($scope.officialTranscript.defaultRequestLink, '_blank');
    }
  };

  loadTranscriptData();
});
