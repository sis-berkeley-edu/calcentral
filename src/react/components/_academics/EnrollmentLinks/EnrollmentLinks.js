import React from 'react';
import PropTypes from 'prop-types';
import { react2angular } from 'react2angular';
import { connect } from 'react-redux';
import ReduxProvider from 'components/ReduxProvider';

import { activeRoles } from '../../../helpers/roles';

import './EnrollmentLinks.scss';

import Add from './Add';
import Drop from './Drop';
import ConcurrentDrop from './ConcurrentDrop';
import ConcurrentOptions from './ConcurrentOptions';
import Swap from './Swap';
import Options from './Options';
import OptionsGradingEnd from './OptionsGradingEnd';
import Withdraw from './Withdraw';

const EnrollmentLinks = ({ currentRole, instruction, enrollmentTerms }) => {
  const enrollmentTerm = enrollmentTerms.find(
    reg => reg.termId === instruction.termId
  );

  const { requiresCalgrantAcknowledgement: disabled = false } =
    enrollmentTerm || {};

  return (
    <div className="EnrollmentLinks">
      <div className="EnrollmentLinks__link-container">
        <Add instruction={instruction} disabled={disabled} />
        <Drop instruction={instruction} disabled={disabled} />
        <Swap
          instruction={instruction}
          currentRoles={activeRoles(currentRole)}
          disabled={disabled}
        />
        <Options instruction={instruction} disabled={disabled} />
        <OptionsGradingEnd instruction={instruction} disabled={disabled} />
        <Withdraw instruction={instruction} />
        <ConcurrentDrop instruction={instruction} disabled={disabled} />
        <ConcurrentOptions instruction={instruction} disabled={disabled} />
      </div>
      {disabled && (
        <p style={{ marginTop: `15px` }}>
          Complete the California Enrollment Acknowledgment to enable
          enrollment. To complete this requirement, see the{' '}
          <a href="/dashboard">Tasks section</a> of your Dashboard. Look for the
          task titled &quot;CA Enrollment Acknowledgment&quot; under your
          Finances tasks.
        </p>
      )}
    </div>
  );
};

EnrollmentLinks.propTypes = {
  instruction: PropTypes.object,
  fromPage: PropTypes.object,
  currentRole: PropTypes.object,
  enrollmentTerms: PropTypes.array,
};

const mapStateToProps = ({ myEnrollments: { enrollmentTerms = [] } = {} }) => {
  return { enrollmentTerms };
};

const ConnectedEnrollmentLinks = connect(mapStateToProps)(EnrollmentLinks);

// The EnrollmentLinksConainer defines the interface to angular, it receives
// its properties from the angular view and passes them to the connected
// component.
const EnrollmentLinksContainer = props => {
  return (
    <ReduxProvider>
      <ConnectedEnrollmentLinks {...props} />
    </ReduxProvider>
  );
};

EnrollmentLinksContainer.propTypes = {
  instruction: PropTypes.object,
  fromPage: PropTypes.object,
  currentRole: PropTypes.object,
};

angular
  .module('calcentral.react')
  .component(
    'enrollmentInstructionLinks',
    react2angular(EnrollmentLinksContainer)
  );
