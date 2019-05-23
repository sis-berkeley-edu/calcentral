import React from 'react';
import PropTypes from 'prop-types';

import CampusSolutionsLinkContainer from '../../CampusSolutionsLink/CampusSolutionsLinkContainer';
import ShowMore from '../../ShowMore';
import WidgetBody from '../../Widget/WidgetBody';

import '../../../stylesheets/billing_summary.scss';
import '../../../stylesheets/widgets.scss';

const propTypes = {
  handleShowMore: PropTypes.func.isRequired,
  learnMoreConfig: PropTypes.object.isRequired,
  learnMoreLinks: PropTypes.object.isRequired,
  showMore: PropTypes.bool.isRequired
};

const learnMoreLink = (link) => {
  if (link) {
    return (
      <span>
        Learn more about <CampusSolutionsLinkContainer linkObj={link} />.
      </span>
    );
  } else {
    return null;
  }
};

const expandedView = (config, links) => {
  return (
    <WidgetBody widgetConfig={config}>
      <div className="cc-react-widget--padding-sides learn-more">
        <strong>Due Now</strong>
        <p>
          All charges currently due. Due Now also includes Overdue charges. {learnMoreLink(links.studentBilling)}
        </p>

        <strong>Not Yet Due</strong>
        <p>
          All charges with a due date in the future. {learnMoreLink(links.studentBilling)}
        </p>

        <strong>Overdue</strong>
        <p>All charges with a due date before today. Overdue charges can result in late fees and enrollment cancellation. {learnMoreLink(links.delinquentAccounts)}</p>
        <strong>Making Payments</strong>
        <p>Make Payment links to the student payment portal where you can pay your bill. {learnMoreLink(links.makingPayments)}</p>
        <strong>View PDF Statement</strong>
        <p>Links to PDF statements that are easy to download or print.</p>
      </div>
    </WidgetBody>
  );
};

const LearnMore = (props) => {
  return (
    <ShowMore 
      clickHandler={props.handleShowMore}
      expanded={props.showMore}
      text='Learn more about Billing'
      view={expandedView(props.learnMoreConfig, props.learnMoreLinks)} />
  );
};
LearnMore.propTypes = propTypes;

export default LearnMore;
