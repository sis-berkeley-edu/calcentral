import React, { useEffect } from 'react';
import PropTypes from 'prop-types';

import { react2angular } from 'react2angular';
import { connect } from 'react-redux';

import { fetchAwardComparison } from 'Redux/actions/awardComparisonActions';

import ReduxProvider from 'react/components/ReduxProvider';

const AwardComparisonLink = ({ fetchData, awardComparison, year }) => {
  useEffect(() => fetchData(), []);

  const awardComparisonHref = '/finances/finaid/compare/' + year;

  if (
    awardComparison.loaded &&
    !awardComparison.errored &&
    /* We want to return the component only if there are activityDates for the user to select for the aid year */
    awardComparison.aidYears.filter(award => award.id === year)[0].activityDates
      .length > 0
  ) {
    return (
      <>
        <div className="cc-widget-finaid-awards-link-title cc-widget-finaid-awards-icon-compare">
          Changes to Current Awards
        </div>
        <div className="cc-widget-finaid-awards-link">
          <a href={awardComparisonHref}>View Award Comparison</a>
        </div>
      </>
    );
  }

  return null;
};

AwardComparisonLink.propTypes = {
  fetchData: PropTypes.func,
  awardComparison: PropTypes.object,
  year: PropTypes.string,
};

const mapStateToProps = ({ awardComparison = {} }) => {
  return { awardComparison: awardComparison };
};

const mapDispatchToProps = dispatch => {
  return {
    fetchData: () => {
      dispatch(fetchAwardComparison());
    },
  };
};

const ConnectedAwardComparisonLink = connect(
  mapStateToProps,
  mapDispatchToProps
)(AwardComparisonLink);

const AwardComparisonLinkContainer = ({ year }) => (
  <ReduxProvider>
    <ConnectedAwardComparisonLink year={year} />
  </ReduxProvider>
);

AwardComparisonLinkContainer.propTypes = {
  year: PropTypes.string,
};

angular
  .module('calcentral.react')
  .component(
    'awardComparisonLink',
    react2angular(AwardComparisonLinkContainer)
  );
