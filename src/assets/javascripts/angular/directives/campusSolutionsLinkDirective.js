'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Directive for displaying links to Campus Solutions
 *
 * Intended for use with objects that include Campus Solutions Link API properties
 *
 * Example:
 *   {
 *     "name": "Academic Progress Report",
 *     "title": "View this student's Academic Progress Report",
 *     "ccPageName": 'My Academics',
 *     "ccPageUrl": 'http://calcentral.berkeley.edu/academics/',
 *     "ucfrom": true,
 *     "ucfromlink": true,
 *     "ucfromtext": null,
 *     "url": "https://cs-qat.berkeley.edu/psc/bcsqat/EMPLOYEE/PSFT_CS/c/SSR_ADVISEE_OVRD.SAA_SS_DPR_ADB.GBL?EMPLID=12345"
 *     "shownewwindow": true,
 *     "ccCache": 'enrollment'
 *   }
 *
 * Each of the properties are used by the directive as follows:
 *   name - Used as the body (link label) of the anchor tag
 *   title - Used as the title attribute (hover text) for the anchor tag
 *   ccPageName - String representing the name of the current CalCentral page that the user is linking from. Defaults
 *   to 'CalCentral'
 *   ccPageUrl - String representing URL of the current CalCentral page that the user is linking from
 *   ucFrom - When true, the 'ucFrom=CALCENTRAL' parameter is appended to the query string of the CS page URL,
 *     thus activating header/banner on the CS page. Defaults to false.
 *   ucFromLink - When true, the 'ucFromLink' parameter is appended to the query string of the CS page URL, with
 *     'ccPageUrl' as the value. Defaults to the current CalCentral page URL when 'null'. Defaults to false.
 *   ucFromText - When true, the 'ucFromText' parameter is appended to the query string of the CS page URL, with
 *     'ccPageName' as the value. Defaults to 'CalCentral' when 'null'. Defaults to false.
 *   showNewWindow - Allows the default behavior implemented by the outboundLinkDirective.js when true
 *     resulting in links to a non-CalCentral page opening in a new window/tab. Defaults to false.
 *   ccCache - When specified, is included as the value for the 'ucUpdateCache' parameter appended to the CS page URL
 *     query string. Is included with the return link to prompt CalCentral to clear any related caches related
 *     to actions taken by the user within the CS pages
 *
 * In most cases you can simply pass the object to the directive as follows. The page name and URL are passed to the
 * directive explicitly because these are usually set in the AngularJS controller for the page.
 *   <a data-cc-campus-solutions-link-directive="csLinkUrl"></a>
 *
 * Often the page name and URL may need to be passed as an attribute:
 *   <a data-cc-campus-solutions-link-directive="csLinkObject"
 *     data-cc-campus-solutions-link-directive-cc-page-name="{{currentPage.name}}"
 *     data-cc-campus-solutions-link-directive-cc-page-url="{{currentPage.url}}"
 *   ></a>
 *
 * If needed, any of the attributes may specified to override the property of the same name in the link object.
 * It is also possible to specify the behavior through the attributes alone. The directive
 * relies on the URL string specified in the link object (passed to data-cc-campus-solutions-link-directive),
 * or the URL specified to the data-cc-campus-solutions-link-directive-url attribute.
 *   <a
 *     data-cc-campus-solutions-link-directive
 *     data-cc-campus-solutions-link-directive-cc-cache="enrollment"
 *     data-cc-campus-solutions-link-directive-cc-page-name="My Academics"
 *     data-cc-campus-solutions-link-directive-cc-page-url="{{alternativeUrl}}"
 *     data-cc-campus-solutions-link-directive-name="Progress Report"
 *     data-cc-campus-solutions-link-directive-show-new-window="true"
 *     data-cc-campus-solutions-link-directive-title="View the AP Report"
 *     data-cc-campus-solutions-link-directive-uc-from="true"
 *     data-cc-campus-solutions-link-directive-uc-from-link="false"
 *     data-cc-campus-solutions-link-directive-uc-from-text="false"
 *     data-cc-campus-solutions-link-directive-url="csLinkUrl"
 *   ></a>
 *
 * If the HTML element using the directive has a body present, this body will not be replaced.
 *   <a data-cc-campus-solutions-link-directive="csLinkObject">My Custom Link Body</a>
 *
 */
angular.module('calcentral.directives').directive('ccCampusSolutionsLinkDirective', function(linkService) {
  /* Returns link object passed to directive */
  var getLinkObject = function(scope, attrs) {
    return scope.$eval(_.get(attrs, 'ccCampusSolutionsLinkDirective'));
  };

  /**
   * Returns base URL
   */
  var getBaseUrl = function(scope, attrs) {
    var attrUrl = scope.$eval(_.get(attrs, 'ccCampusSolutionsLinkDirectiveUrl'));
    if (_.isEmpty(attrUrl)) {
      var linkObj = getLinkObject(scope, attrs);
      var linkObjUrl = _.get(linkObj, 'url');
      return linkObjUrl;
    } else {
      return attrUrl;
    }
  };

  /**
   * Sets the text for the anchor tag if not already present
   */
  var setLinkBody = function(linkBody, element) {
    if (linkBody) {
      var currentLinkBody = element.text();
      if (_.isEmpty(currentLinkBody)) {
        element.text(linkBody);
      }
    }
  };

  /**
   * Prepares object used to configure the link.
   * Provides logic for element attributes overriding link object properties
   *
   * @param  {Object} scope       AngularJS scope object
   * @param  {Object} attrs       Attributes object for the element the directive being processed is applied to
   * @return {Object}             Link configuration object
   */
  var getLinkConfig = function(scope, attrs) {
    var linkObj = getLinkObject(scope, attrs);
    var baseLinkUrl = getBaseUrl(scope, attrs);
    var ccCacheString = attrs.ccCampusSolutionsLinkDirectiveCcCache || _.get(linkObj, 'ccCache');
    var ccPageName = scope.$eval(attrs.ccCampusSolutionsLinkDirectiveCcPageName) || _.get(linkObj, 'ccPageName') || 'CalCentral';
    var ccPageUrl = scope.$eval(attrs.ccCampusSolutionsLinkDirectiveCcPageUrl) || _.get(linkObj, 'ccPageUrl');
    var ucFromParamsConfig = getUcFromParamConfig(linkObj, scope, attrs);
    var decoratedLinkUrl = decorateLink(baseLinkUrl, ucFromParamsConfig.includeUcFrom, ucFromParamsConfig.includeUcFromLink, ucFromParamsConfig.includeUcFromText, ccCacheString, ccPageName, ccPageUrl);

    // TODO: Discover why link objects either include 'showNewwindow' or 'shownewwindow' property
    var showNewWindow = scope.$eval(attrs.ccCampusSolutionsLinkDirectiveShowNewWindow) || _.get(linkObj, 'shownewwindow') || _.get(linkObj, 'showNewWindow') || false;
    var linkBody = scope.$eval(attrs.ccCampusSolutionsLinkDirectiveName) || _.get(linkObj, 'name');
    var linkHoverText = scope.$eval(attrs.ccCampusSolutionsLinkDirectiveTitle) || _.get(linkObj, 'title') || false;

    return {
      linkBody: linkBody,
      linkHoverText: linkHoverText,
      linkUrl: decoratedLinkUrl,
      showNewWindow: showNewWindow
    };
  };

  /**
   * Process ucFrom parameter configuration
   */
  var getUcFromParamConfig = function(linkObj, scope, attrs) {
    var includeUcFrom = !!(scope.$eval(attrs.ccCampusSolutionsLinkDirectiveUcFrom) || _.get(linkObj, 'ucfrom') || _.get(linkObj, 'ucFrom')) || false;
    var includeUcFromLink = !!(scope.$eval(attrs.ccCampusSolutionsLinkDirectiveUcFromLink) || _.get(linkObj, 'ucfromlink') || _.get(linkObj, 'ucFromLink')) || false;
    var includeUcFromText = !!(scope.$eval(attrs.ccCampusSolutionsLinkDirectiveUcFromText) || _.get(linkObj, 'ucfromtext') || _.get(linkObj, 'ucFromText')) || false;
    return {
      includeUcFrom: includeUcFrom,
      includeUcFromLink: includeUcFromLink,
      includeUcFromText: includeUcFromText
    };
  };

  /**
   * Applies ucFrom, ucFromLink, and ucFromText parameters to URL
   * 'ucFrom' is always 'CalCentral'
   */
  var decorateLink = function(linkUrl, includeUcFrom, includeUcFromLink, includeUcFromText, ccCacheString, ccPageName, ccPageUrl) {
    if (/^http/.test(linkUrl) && includeUcFrom === true) {
      linkUrl = linkService.fixLastQuestionMark(linkUrl);

      if (includeUcFrom) {
        linkUrl = linkService.addQueryStringParameterEncodedAmpersand(linkUrl, 'ucFrom', 'CalCentral');
      }
      if (includeUcFromText) {
        linkUrl = linkService.addQueryStringParameterEncodedAmpersand(linkUrl, 'ucFromText', ccPageName);
      }
      if (includeUcFromLink) {
        if (ccCacheString) {
          ccPageUrl = linkService.addQueryStringParameterEncodedAmpersand(ccPageUrl, 'ucUpdateCache', ccCacheString);
        }
        var urlEncodedCcPageUrl = encodeURIComponent(ccPageUrl);
        linkUrl = linkService.addQueryStringParameterEncodedAmpersand(linkUrl, 'ucFromLink', urlEncodedCcPageUrl);
      }
    }
    return linkUrl;
  };

  return {
    // It needs to run after the attributes are interpolated, and outboundLinkDirective linking is applied (for new window processing)
    priority: 99,
    restrict: 'A',
    link: function(scope, element, attrs) {
      // used to watch for changes in response of getBaseUrl
      var baseUrl = function() {
        return getBaseUrl(scope, attrs);
      };

      scope.$watch(baseUrl, function() {
        var linkConfig = getLinkConfig(scope, attrs);
        attrs.$set('href', linkConfig.linkUrl);
        if (linkConfig.linkHoverText) {
          attrs.$set('title', linkConfig.linkHoverText);
        }
        setLinkBody(linkConfig.linkBody, element);

        // respect if ccOutboundEnabled manually set
        if (_.isEmpty(attrs.ccOutboundEnabled) && linkConfig.showNewWindow) {
          linkService.makeOutboundlink(element);
        }
      });
    }
  };
});
