import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { react2angular } from 'react2angular';

import ReduxProvider from 'react/components/ReduxProvider';

import styles from './COVIDEnrollmentNotice.module.scss';
import 'icons/bullhorn-solid.svg';

const propTypes = {
  termId: PropTypes.string.isRequired,
  enrollmentTerms: PropTypes.array,
};

const COVIDEnrollmentNotice = ({ termId, enrollmentTerms }) => {
  const enrollmentTerm = enrollmentTerms.find(et => et.termId === termId);

  if (enrollmentTerm.message === null) {
    return null;
  }

  const message = enrollmentTerm.message.descrlong;

  return (
    <div className={styles.COVIDEnrollmentNotice}>
      <div
        className={styles.messageContainer}
        dangerouslySetInnerHTML={{ __html: message }}
      />
    </div>
  );
};

COVIDEnrollmentNotice.propTypes = propTypes;

const mapStateToProps = ({ myEnrollments: { enrollmentTerms = [] } = {} }) => {
  return { enrollmentTerms };
};

const ConnectedCOVIDEnrollmentNotice = connect(mapStateToProps)(
  COVIDEnrollmentNotice
);

const COVIDEnrollmentNoticeContainer = ({ termId }) => (
  <ReduxProvider>
    <ConnectedCOVIDEnrollmentNotice termId={termId} />
  </ReduxProvider>
);

COVIDEnrollmentNoticeContainer.propTypes = {
  termId: PropTypes.string.isRequired,
};

angular
  .module('calcentral.react')
  .component(
    'covidEnrollmentNotice',
    react2angular(COVIDEnrollmentNoticeContainer)
  );
