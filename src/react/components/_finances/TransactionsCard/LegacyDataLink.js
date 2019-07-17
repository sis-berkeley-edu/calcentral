import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import './LegacyDataLink.scss';

const LegacyDataLink = ({
  carsActivity,
  unappliedBalance
}) => {
  if (unappliedBalance) {
    return null;
  }

  if (carsActivity.length > 0) {
    return (
      <div className="LegacyTransactions">
        <a href="/finances/details">View Transactions Prior to Fall 2016</a>
      </div>
    );
  }

  return null;
};
LegacyDataLink.propTypes = {
  carsActivity: PropTypes.array,
  unappliedBalance: PropTypes.number
};

const mapStateToProps = ({ carsData: { activity: carsActivity = [] } = {} }) => ({ carsActivity });

export default connect(mapStateToProps)(LegacyDataLink);
