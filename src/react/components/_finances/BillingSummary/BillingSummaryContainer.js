import PropTypes from 'prop-types';
import React from 'react';
import { react2angular } from 'react2angular';
import { updateStateProperty } from '../../../helpers/state';

import BillingSummary from './BillingSummary';

import Icon from '../../Icon/Icon';
import { ICON_EXCLAMATION_TRIANGLE } from '../../Icon/IconTypes';

const propTypes = {
  analyticsService: PropTypes.object.isRequired,
  billingDetails: PropTypes.bool.isRequired,
  financesFactory: PropTypes.object.isRequired,
  userService: PropTypes.object.isRequired
};

class BillingSummaryContainer extends React.Component {
  constructor(props) {
    super(props);
    this.errorMessage = (
      <React.Fragment>
        <Icon name={ICON_EXCLAMATION_TRIANGLE} />{`There's a problem displaying your billing information. Please try again soon.`}
      </React.Fragment>
    );
    this.handleShowMore = this.handleShowMore.bind(this);
    this.headerLink = {
      url: '/billing/details',
      text: 'View Transactions'
    };
    this.learnMoreErrorMessage = (
      <React.Fragment>
        <Icon name={ICON_EXCLAMATION_TRIANGLE} />{`There's a problem displaying billing information. Please try again soon.`}
      </React.Fragment>
    );

    this.state = {
      finances: {},
      higherOneUrl: '/higher_one/higher_one_url',
      learnMoreConfig: {
        errored: false,
        errorMessage: this.learnMoreErrorMessage,
        isLoading: true,
        padding: false
      },
      learnMoreLinks: {},
      showMore: false,
      widgetConfig: {
        errored: false,
        errorMessage: this.errorMessage,
        link: {},
        isLoading: true,
        padding: false,
        title: 'Billing Summary',
        visible: true
      }
    };
  }
  componentDidMount() {
    this.props.financesFactory.getCsFinances()
    .then((response) => {
      return updateStateProperty(this, {
        finances: { $set: response.data.feed.summary },
        widgetConfig: {
          link: { $set:  this.headerLink}
        }
      });
    }).catch(() => {
      return updateStateProperty(this, {widgetConfig: {errored: {$set: true}}});
    }).finally(() => {
      return updateStateProperty(this, {widgetConfig: {isLoading: {$set: false}}});
    });
  }
  fetchLearnMoreLinks() {
    this.props.financesFactory.getCsFinancesLinks()
    .then((response) => {
      return updateStateProperty(this, {learnMoreLinks: {$set: response.data.feed.links} });
    }).catch(() => {
      return updateStateProperty(this, {learnMoreConfig: {errored: {$set: true}}});
    }).finally(() => {
      return updateStateProperty(this, {learnMoreConfig: {isLoading: {$set: false}}});
    });
  }
  handleShowMore(event) {
    event.preventDefault();
    let newState = !this.state.showMore;
    updateStateProperty(this, {showMore: {$set: newState}});

    if (Object.keys({...this.state.learnMoreLinks}).length || this.state.learnMoreConfig.errored) {
      return;
    } else {
      this.fetchLearnMoreLinks();
    }

    this.props.analyticsService.sendEvent('Content expansion', 'Click', 'Learn more about billing expansion');
  }
  render() {
    return (
      <BillingSummary
        billingDetails={this.props.billingDetails}
        canActOnFinances={this.props.userService.profile.canActOnFinances}
        finances={{...this.state.finances}} 
        handleShowMore={this.handleShowMore}
        higherOneUrl={this.state.higherOneUrl}
        learnMoreConfig={{...this.state.learnMoreConfig}}
        learnMoreLinks={{...this.state.learnMoreLinks}}
        showMore={this.state.showMore}
        trackAnalytics={this.props.analyticsService.sendEvent}
        widgetConfig={{...this.state.widgetConfig}} 
      />
    );
  }
}
BillingSummaryContainer.propTypes = propTypes;

angular.module('calcentral.react').component('billingSummaryContainer', react2angular(BillingSummaryContainer, ['billingDetails'], ['analyticsService', 'financesFactory', 'userService']));
