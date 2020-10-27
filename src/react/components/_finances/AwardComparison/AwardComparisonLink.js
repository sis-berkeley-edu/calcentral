import React, { useEffect } from 'react';
import PropTypes from 'prop-types';

import { connect } from 'react-redux';

import { fetchAwardComparison } from 'Redux/actions/awardComparisonActions';

const AwardComparisonLink = ({ fetchData, awardComparison, year }) => {
  useEffect(() => fetchData(), []);

  const awardComparisonHref = '/finances/finaid/compare/' + year;

  if (
    awardComparison.loaded &&
    !awardComparison.errored &&
    /* We want to return the component only if there are activityDates for the user to select for the aid year */
    awardComparison.aidYears.filter(award => award.id === year)[0].activityDates
      .length > 1
  ) {
    return (
      <>
        <div className="cc-widget-finaid-awards-link-title cc-widget-finaid-awards-icon-compare">
          Award Comparison
        </div>
        <div className="cc-widget-finaid-awards-link">
          <a href={awardComparisonHref}>View Changes to Current Awards</a>
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

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(AwardComparisonLink);
