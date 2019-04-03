import React from 'react';
import PropTypes from 'prop-types';
import { react2angular } from 'react2angular';

import APILink from '../../APILink';
import { isIncomplete } from '../CalGrantAcknowledgement/states';
import { activeRoles } from '../../../helpers/roles';
import { forTermId } from '../../../helpers/terms';

import './EnrollmentLinks.scss';

import Add from './Add';
import Drop from './Drop';
import ConcurrentDrop from './ConcurrentDrop';
import ConcurrentOptions from './ConcurrentOptions';
import Swap from './Swap';
import Options from './Options';
import OptionsGradingEnd from './OptionsGradingEnd';
import Withdraw from './Withdraw';

const propTypes = {
  instruction: PropTypes.object,
  fromPage: PropTypes.object,
  currentRole: PropTypes.object,
  calgrantAcknowledgements: PropTypes.array,
  links: PropTypes.object
};

const EnrollmentInstructionLinks = (props) => {
  const currentTermId = props.instruction.termId;
  const acknowledgement = forTermId(props.calgrantAcknowledgements, currentTermId);
  const acknowledgementRequired = acknowledgement && isIncomplete(acknowledgement);
  const disabled = acknowledgementRequired || false;

  return (
    <div className="EnrollmentLinks">
      <div className="EnrollmentLinks__link-container">
        <Add instruction={props.instruction} disabled={disabled} />
        <Drop instruction={props.instruction} disabled={disabled} />
        <Swap instruction={props.instruction} currentRoles={activeRoles(props.currentRole)} disabled={disabled} />
        <Options instruction={props.instruction} disabled={disabled} />
        <OptionsGradingEnd instruction={props.instruction} disabled={disabled} />
        <Withdraw instruction={props.instruction} />
        <ConcurrentDrop instruction={props.instruction} disabled={disabled} />
        <ConcurrentOptions instruction={props.instruction} disabled={disabled} />
      </div>

      {acknowledgementRequired &&
        <p className="EnrollmentLinks__calgrant-notice">
          Complete the <APILink {...acknowledgement.link} /> to enable enrollment
        </p>
      }
    </div>
  );
};

EnrollmentInstructionLinks.propTypes = propTypes;

angular.module('calcentral.react').component('enrollmentInstructionLinks', react2angular(EnrollmentInstructionLinks));

export default EnrollmentInstructionLinks;
