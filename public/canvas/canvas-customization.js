/* jshint camelcase: false */
// jscs:disable maximumNumberOfLines

(function(window, document, $) {
  'use strict';

  /* UTIL */

  /**
   * Perform a CalCentral API Get request
   *
   * @param  {String}     url                 The relative URL of the API request that should be made
   * @param  {Function}   callback            Standard callback function
   * @param  {Object}     callback.response   The API request response
   */
  var apiRequest = function(url, callback) {
    $.ajax({
      'dataType': 'json',
      'url': window.CALCENTRAL + url,
      'success': callback
    });
  };

  /**
   * Get the id for a custom LTI tool that user has access to
   *
   * @param  {String}     toolType            The classification of the LTI tool. This will be the top level property in the external tools hash
   * @param  {String}     toolName            The name of the LTI tool for which the id should be retrieved
   * @param  {Function}   callback            Standard callback function
   * @param  {String}     callback.id         The id of the requested custom LTI tool
   */
  var getExternalToolId = function(toolType, toolName, callback) {
    apiRequest('/api/academics/canvas/external_tools.json', function(externalToolsHash) {
      if (externalToolsHash && externalToolsHash[toolType]) {
        return callback(externalToolsHash[toolType][toolName]);
      } else {
        return callback(null);
      }
    });
  };

  // Keeps track of the elements to become available on the page
  var elementWaitList = [];

  /**
   * Wait until an element is available on the page
   *
   * @param  {String}     selector            The jQuery selector of the element for which presence is checked
   * @param  {Boolean}    repeat              Whether to continue checking for the existence of the element after it has been found for the first time. If `true`, the callback function will be executed every time the element is present
   * @param  {Function}   callback            Standard callback function
   * @param  {Element}    callback.element    The jQuery element that represent the element for which presence was found
   */
  var waitUntilAvailable = function(selector, repeat, callback) {
    // Add the element to the list of elements to check for existence on the page
    elementWaitList.push({
      'selector': selector,
      'repeat': repeat,
      'callback': callback
    });
  };

  /**
   * Check for the presence of elements in the waiting list on the page
   */
  var checkElements = function() {
    elementWaitList = elementWaitList.filter(function(element) {
      var $element = $(element.selector);
      if ($element.length > 0) {
        element.callback($element);
        return element.repeat ? true : false;
      } else {
        return true;
      }
    });
  };

  setInterval(checkElements, 200);

  /* CREATE A SITE */

  /**
   * Check whether the current user is allowed to create a new site
   *
   * @param  {Function}   callback                  Standard callback function
   * @param  {Element}    callback.canCreateSite    Whether the current user is allowed to create a new site
   */
  var canUserCreateSite = function(callback) {
    apiRequest('/api/academics/canvas/user_can_create_site?canvas_user_id=' + window.ENV.current_user_id, function(authResult) {
      return callback(authResult.canCreateSite);
    });
  };

  /**
   * Add the 'Create a Site' button that will provide access to the custom LTI tool
   * that allows a user to create a course site and/or a project site
   */
  var addCreateSiteButton = function() {
    // Only add the 'Create a Site' button from the dashboard or courses page
    if (['/', '/courses'].indexOf(window.location.pathname) !== -1 && window.ENV.current_user_id) {
      // Check if the user is allowed to create a new site
      canUserCreateSite(function(canCreateSite) {
        if (canCreateSite) {
          // Get the id of the Create Site LTI tool
          getExternalToolId('globalTools', 'Create a Site', function(createSiteId) {
            if (createSiteId) {
              var linkUrl = '/users/' + window.ENV.current_user_id + '/external_tools/' + createSiteId;
              var $createSiteButton = $('<a/>', {
                'href': linkUrl,
                'text': 'Create a Site',
                'class': 'btn btn-primary button-sidebar-wide'
              });

              // Add the 'Create a Site' button to the Dashboard page
              waitUntilAvailable('#right-side .rs-margin-lr', false, function($container) {
                $('#start_new_course').remove();
                $container.prepend($createSiteButton);
              });

              // Add the 'Create a Site' button to the Courses page
              waitUntilAvailable('.ic-Action-header', false, function($actionHeader) {
                $actionHeader.remove();
                // Add the button to the header
                var $headerBar = $('.header-bar');
                $('h2', $headerBar).addClass('pull-left');
                var $createSiteContainer = $('<div/>', {
                  'id': 'my-courses-create-site',
                  'class': 'text-right'
                }).append($createSiteButton);
                $headerBar.append($createSiteContainer);
              });
            }
          });
        }
      });
    }
  };

  /**
   * Remove the 'Create a Site' menu item from the 'User Settings' page
   * if the current user is not allowed to create a new site
   */
  var removeCreateSiteUserNav = function() {
    // Only attempt to remove the 'Create a Site' item on the 'User Settings' page
    if (window.location.pathname === '/profile/settings' && window.ENV.current_user_id) {
      // Remove the 'Create a Site' item if the current user is not allowed
      // to create a new site
      canUserCreateSite(function(canCreateSite) {
        if (canCreateSite) {
          waitUntilAvailable('nav ul#section-tabs li.section a:contains("Create a Site")', false, function($createSiteLink) {
            $createSiteLink.parent().remove();
          });
        }
      });
    }
  };

  addCreateSiteButton();
  removeCreateSiteUserNav();

  /* E-GRADES EXPORT */

  /**
   * Add the 'E-Grades' export option to the Canvas Gradebook
   */
  var addEGrades = function() {
    // Verify that the current context is the Gradebook tool
    if (window.ENV && window.ENV.GRADEBOOK_OPTIONS && window.ENV.GRADEBOOK_OPTIONS.context_id) {
      // Verify that the current course contains official course sections
      var courseId = window.ENV.GRADEBOOK_OPTIONS.context_id;
      apiRequest('/api/academics/canvas/egrade_export/is_official_course.json?canvas_course_id=' + courseId, function(officialCourseResponse) {
        if (officialCourseResponse.isOfficialCourse) {
          // Get the id of the E-Grades LTI tool
          getExternalToolId('officialCourseTools', 'Download E-Grades', function(gradesExportLtiId) {
            if (gradesExportLtiId) {
              var linkUrl = '/courses/' + courseId + '/external_tools/' + gradesExportLtiId;

              // Add the 'E-Grades' export option
              waitUntilAvailable('#gradebook-toolbar .gradebook_menu span.ui-buttonset', false, function($gradebookToolbarMenu) {
                var eGradesButton = [
                  '<a class="ui-button" href="' + linkUrl + '">',
                  '  <i class="icon-export"></i>',
                  '  E-Grades',
                  '</a>'
                ].join('');
                $gradebookToolbarMenu.append(eGradesButton);
              });
            }
          });
        }
      });
    }
  };

  addEGrades();

  /* ADD PEOPLE */

  /**
   * Add additional support for adding users to a course site
   */
  var addPeopleSupport = function() {
    // Verify that the current context is the People tool
    if (window.ENV && window.ENV.permissions && window.ENV.permissions.add_users) {
      // Add additional support to the first step
      waitUntilAvailable('#create-users-step-1:visible:not(.calcentral-modified)', true, function($createUserStep1) {
        $createUserStep1.addClass('calcentral-modified');
        // Replace instruction text
        var instructionText = 'Type or paste a list of email addresses or CalNet UIDs below:';
        $('p:first', $createUserStep1).text(instructionText);
        // Replace placeholder text
        var placeholderText = 'student@berkeley.edu, 323494, 1032343, guest@example.com, 11203443, gsi@berkeley.edu';
        $('#user_list_textarea', $createUserStep1).attr('placeholder', placeholderText);

        // Add a link to the help pages
        if ($('#add-people-help').length === 0) {
          var helpLink = [
            '<a href="http://ets.berkeley.edu/bcourses/faq/adding-people" id="add-people-help" target="_blank">',
            '  <i class="icon-question" aria-hidden="true"></i>',
            '  <span class="screenreader-only">Need help adding someone to your site?</span>',
            '</a>'
          ].join('');
          $('#ui-id-1').after(helpLink);
        }

        // Get the id of the Find a Person to Add LTI tool
        getExternalToolId('globalTools', 'Find a Person to Add', function(findPersonId) {
          if (findPersonId) {
            var linkUrl = window.ENV.COURSE_ROOT_URL + '/external_tools/' + findPersonId;
            var findPersonToAdd = [
              '<div class="pull-right" id="calnet-directory-link">',
              '  <a href="' + linkUrl + '">',
              '    <i class="icon-search-address-book" aria-hidden="true"></i>',
              '    Find a Person to Add',
              '  </a>',
              '</div>'
            ].join('');
            $createUserStep1.prepend(findPersonToAdd);
          }
        });
      });
    }
  };

  /**
   * Add additional information to the Add People error message
   */
  var addPeopleError = function() {
    // Verify that the current context is the People tool
    if (window.ENV && window.ENV.permissions && window.ENV.permissions.add_users) {
      // Add additional information to the Add People error message
      waitUntilAvailable('#user_email_errors:visible:not(.calcentral-modified)', true, function($userEmailErrors) {
        $userEmailErrors.addClass('calcentral-modified');
        // Set a custom error message
        var customErrorMessage = [
          '<div>These users had errors and will not be added. Please ensure they are formatted correctly.</div>',
          '<div><small>Examples: student@berkeley.edu, 323494, 1032343, guest@example.com, 11203443, gsi@berkeley.edu</small></div>'
        ].join('');
        $userEmailErrors.find('p').first().html(customErrorMessage);

        // Append a note for guest user addition
        var addGuestMessage = [
          '<div id="add-people-error-guests">',
          '  <strong>NOTE</strong>: If you are attempting to add a guest to your site who does NOT have a CalNET ID, they must first be sponsored.',
          '  For more information, see <a target="_blank" href="http://ets.berkeley.edu/bcourses/faq-page/7">Adding People to bCourses</a>.',
          '</div>'
        ].join('');
        $userEmailErrors.find('ul.createUsersErroredUsers').after(addGuestMessage);
      });
    }
  };

  addPeopleSupport();
  addPeopleError();

  /* ALTERNATIVE MEDIA PANEL */

  /**
   * Check whether the current user can manage the files tool in the current course
   *
   * @return {Boolean}                        Whether the current user can manage the files tool
   */
  var canManageFilesTool = function() {
    return window.ENV.FILES_CONTEXTS[0] && window.ENV.FILES_CONTEXTS[0].permissions && window.ENV.FILES_CONTEXTS[0].permissions.manage_files;
  };

  /**
   * Add an 'Alternative Media' information panel for instructors to the 'Files' tool
   */
  var addAltMediaPanel = function() {
    if (canManageFilesTool) {
      var altMediaPanel = [
        '<div id="alt-media-container" class="alert alert-info">',
        '  <button class="btn-link element_toggler" aria-controls="alt-media-content" aria-expanded="false" aria-label="Notice to Instructors for Making Course Materials Accessible">',
        '    <i class="icon-arrow-right"></i> <strong>Instructors: Making Course Materials Accessible</strong>',
        '  </button>',
        '  <div id="alt-media-content" class="hide" role="region" tabindex="-1">',
        '    <ul>',
        '      <li>Without course instructor assistance, the University cannot meet its mission and responsibility to <a href="http://www.ucop.edu/electronic-accessibility/index.html" target="_blank">make online content accessible to students with disabilities</a></li>',
        '      <li><a href="http://www.dsp.berkeley.edu/what-inaccessible-content" target="_blank">How to improve the accessibility of your online content</a></li>',
        '      <li><a href="https://ets.berkeley.edu/sensusaccess" target="_blank">SensusAccess</a> -- your online partner in making documents accessible</li>',
        '      <li>Need Help? <a href="mailto:Assistive-technology@berkeley.edu" target="_blank">Contact Us</a></li>',
        '    </ul>',
        '  </div>',
        '</div>'
      ].join('');

      waitUntilAvailable('header.ef-header', false, function($header) {
        $header.before(altMediaPanel);

        // Toggle icon
        $('#alt-media-container .element_toggler').on('click', function() {
          $(this).find('i[class*="icon-arrow"]').toggleClass('icon-arrow-down icon-arrow-right');
        });
      });
    }
  };

  addAltMediaPanel();

  /* 404 PAGE */

  /**
   * Customize the default Canvas 404 page with bCourses support information
   */
  var pageNotFound = function() {
    // Verify that the current context is the error page
    waitUntilAvailable('#submit_error_form', false, function() {
      // Remove the default content and replace it with bCourses specific
      // support information
      $('#content h2').nextAll('*').remove();
      var pageNotFoundHelp = [
        '<p>Oops, we couldn\'t find that page! Contact the instructor or project site owner and let them know that something is missing.</p>',
        '<p>If you\'re still having a problem, email <a href="mailto:bcourseshelp@berkeley.edu">bcourseshelp@berkeley.edu</a> for support.</p>'
      ].join('');
      $('#content h2').after(pageNotFoundHelp);
    });
  };

  pageNotFound();

  /* WEBCAST */

  /**
   * Allow full screen for WebCast videos
   */
  var enableFullScreen = function() {
    waitUntilAvailable('#tool_content', false, function($toolContent) {
      $toolContent.attr('allowfullscreen', '');
    });
  };

  enableFullScreen();

  /* FOOTER */

  /**
   * Customize the default footer with Berkeley information
   */
  var customizeFooter = function() {
    // Replace the Instructure logo with the Berkeley logo
    var $berkeleyLogo = $('<a>', {
      'class': 'footer-logo',
      'href': 'http://www.berkeley.edu',
      'title': 'University of California, Berkeley',
      'css': {
        'backgroundImage': 'url(' + window.CALCENTRAL + '/canvas/images/ucberkeley_footer.png)'
      }
    });
    $('#footer a.footer-logo').replaceWith($berkeleyLogo);

    // Replace the default footer links with the Berkeley footer links
    var footerLinks = [
      '<div>',
      '  <div>',
      '    <a href="http://www.ets.berkeley.edu/discover-services/bcourses" target="_blank">Support</a>',
      '    <a href="http://www.canvaslms.com/policies/privacy" target="_blank">Privacy Policy</a>',
      '    <a href="http://www.canvaslms.com/policies/terms-of-use-internet2" target="_blank">Terms of Service</a>',
      '    <a href="http://www.facebook.com/pages/UC-Berkeley-Educational-Technology-Services/108164709233254" target="_blank" class="icon-facebook-boxed"><span class="screenreader-only">Facebook</span></a>',
      '    <a href="http://www.twitter.com/etsberkeley" target="_blank" class="icon-twitter"><span class="screenreader-only">Twitter</span></a>',
      '  </div>',
      '  <div>',
      '    <a href="http://teaching.berkeley.edu/berkeley-honor-code" target="_blank">UC Berkeley Honor Code</a>',
      '    <a href="http://www.wellness.asuc.org" target="_blank">Student Wellness Resources</a>',
      '  </div>',
      '</div>'
    ].join('');
    $('#footer-links').html(footerLinks);
  };

  customizeFooter();

  /* IFRAME COMMUNICATION */

  /**
   * We use window events to interact between the LTI iFrame and the parent container.
   * Resizing the iFrame based on its content is handled by Instructure's `public/javascripts/tool_inline.js`
   * file, and it determines the message format we use.
   *
   * The following custom events are provided for modifying the URL of the parent container:
   *
   *  - Change the location of the parent container:
   *    ```
   *     {
   *       subject: 'changeParent',
   *       parentLocation: <newLocation>
   *     }
   *    ```
   *
   *  - Change the hash of the parent container:
   *    ```
   *     {
   *       subject: 'setParentHash',
   *       'hash': <newHash>
   *     }
   *    ```
   *
   * The following custom event is provided to retrieve the URL of the parent container:
   *
   *  - Get the location of the parent container:
   *    ```
   *     {
   *       subject: 'getParent'
   *     }
   *    ```
   *
   * The following custom events are provided to support scrolling-related interaction between
   * the LTI iFrame and the parent container:
   *
   *  - Change the height of the LTI iFrame:
   *    ```
   *     {
   *       subject: 'changeParent',
   *       height: <height>
   *     }
   *    ```
   *
   *  - Scroll the parent container to a specified position:
   *    ```
   *     {
   *       subject: 'changeParent',
   *       scrollTo: <scrollPosition>
   *     }
   *    ```
   *
   *  - Scroll the parent container to the top of the screen:
   *    ```
   *     {
   *       subject: 'changeParent',
   *       scrollToTop: true
   *     }
   *    ```
   *
   *  - Get the scroll information of the parent container:
   *    ```
   *     {
   *       subject: 'getScrollInformation'
   *     }
   *    ```
   *
   *    Each of these events will respond with a window event back to the LTI iFrame containing the scroll information
   *    for the parent container:
   *    ```
   *     {
   *       iFrameHeight: <currentIframeHeight>,
   *       parentHeight: <currentParentHeight>,
   *       scrollPosition: <currentScrollPosition>,
   *       scrollToBottom: <currentHeightBelowFold>
   *     }
   *    ```
   *
   * @param  {Object}    ev         Event that is sent over from the iframe
   * @param  {String}    ev.data    The message sent with the event. Note that this is expected to be a stringified JSON object
   */
  window.onmessage = function(ev) {
    // Parse the provided event message
    if (ev && ev.data) {
      var message;
      try {
        message = JSON.parse(ev.data);
      } catch (err) {
        // The message is not for us; ignore it
        return;
      }

      var response = null;
      // Event that will modify the URL of the parent container
      if (message.subject === 'changeParent' && message.parentLocation) {
        window.location = message.parentLocation;

      // Event that retrieves the parent container's URL
      } else if (message.subject === 'getParent') {
        response = {
          'location': window.location.href
        };
        ev.source.postMessage(JSON.stringify(response), '*');

      // Event that will modify the hash of the parent container's URL
      } else if (message.subject === 'setParentHash') {
        history.replaceState(undefined, undefined, '#' + message.hash);

      // Events related to scrolling interaction between the LTI iFrame and the parent container
      } else if (message.subject === 'changeParent' || message.subject === 'getScrollInformation') {
        // Scroll to the specified position
        if (message.scrollTo !== undefined) {
          window.scrollTo(0, message.scrollTo);
        // Scroll to the top of the current window
        } else if (message.scrollToTop) {
          window.scrollTo(0, 0);
        } else if (message.height !== undefined) {
          if (!message.height || message.height < 450) {
            message.height = 450;
          }
          $('.tool_content_wrapper').height(message.height).data('height_overridden', true);
        }

        // Respond with a window event back to the LTI iFrame containing the scroll information for the parent container
        if (ev.source) {
          var iFrameHeight = $('.tool_content_wrapper').height();
          var parentHeight = $(document).height();
          var scrollPosition = $(document).scrollTop();
          var scrollToBottom = parentHeight - $(window).height() - scrollPosition;
          response = {
            'iFrameHeight': iFrameHeight,
            'parentHeight': parentHeight,
            'scrollPosition': scrollPosition,
            'scrollToBottom': scrollToBottom
          };
          ev.source.postMessage(JSON.stringify(response), '*');
        }
      }
    }
  };

})(window, window.document, window.$);
