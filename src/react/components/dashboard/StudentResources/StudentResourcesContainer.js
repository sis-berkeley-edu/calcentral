/* eslint complexity: ["error", 30] */
import _ from 'lodash';
import PropTypes from 'prop-types';
import React from 'react';
import { react2angular } from 'react2angular';
import { updateStateProperty } from '../../../helpers/state';

import StudentResources from './StudentResources';

const propTypes = {
  $location: PropTypes.object.isRequired,
  $route: PropTypes.object.isRequired,
  academicsService: PropTypes.object.isRequired,
  apiService: PropTypes.object.isRequired,
  linkService: PropTypes.object.isRequired,
  studentResourcesFactory: PropTypes.object.isRequired
};

class StudentResourcesContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      resources: [],
      widgetConfig: {
        errored: false,
        errorMessage: 'Resource links unavailable.',
        isLoading: true,
        title: 'Student Resources',
        visible: false
      }
    };
    this.getStudentResources = this.getStudentResources.bind(this);
    this.getStudentRoles = this.getStudentRoles.bind(this);
    this.parseStudentResources = this.parseStudentResources.bind(this);
    this.getWidgetVisibility = this.getWidgetVisibility.bind(this);
  }
  componentDidMount() {
    this.getWidgetVisibility()
    .then(visible => {
      return updateStateProperty(this, {widgetConfig: {visible: {$set: visible}}});
    });
  }
  componentDidUpdate(prevProps, prevState) {
    if (!prevState.widgetConfig.visible && this.state.widgetConfig.visible) {
      this.getStudentResources()
      .then(this.parseStudentResources)
      .then(resources => {
        return updateStateProperty(this, {resources: {$set: resources}});
      })
      .catch(() => {
        return updateStateProperty(this, {widgetConfig: {errored: {$set: true}}});
      })
      .finally(() => {
        return updateStateProperty(this, {widgetConfig: {isLoading: {$set: false}}});
      });
    }
  }
  getStudentRoles() {
    return new Promise(resolve => {
      const userRoles = this.props.apiService.user.profile.roles;
      resolve(userRoles);
    });
  }
  getStudentResources() {
    return new Promise(resolve => {
      this.props.studentResourcesFactory.getStudentResources()
      .then(response => {
        const resources = _.get(response, 'data.feed.resources');
        resolve(resources);
      });
    });
  }
  getWidgetVisibility() {
    return new Promise(resolve => {
      this.getStudentRoles()
      .then(userRoles => {
        resolve(userRoles.student && (userRoles.undergrad || userRoles.graduate || userRoles.law || userRoles.concurrentEnrollmentStudent));
      });
    });
  }
  parseStudentResources(resources) {
    return new Promise(resolve => {
      const decoratedResources = _.each(resources, resource => {
        if (!_.isEmpty(resource.links)) {
          const currentPage = {
            name: this.props.$route.current.pageName,
            url: this.props.$location.absUrl()
          };
          this.props.linkService.addCurrentPagePropertiesToResources(resource.links, currentPage.name, currentPage.url);
        }
      });
      resolve(decoratedResources);
    });
  }
  render() {
    return (
      <div>
        <StudentResources resources={[...this.state.resources]} widgetConfig={{...this.state.widgetConfig}} />
      </div>
    );
  }
}
StudentResourcesContainer.propTypes = propTypes;

angular.module('calcentral.react').component('studentResourcesContainer', react2angular(StudentResourcesContainer, [], ['$route', '$location', 'academicsService', 'apiService', 'linkService', 'studentResourcesFactory']));
