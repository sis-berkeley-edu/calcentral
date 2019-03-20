import React from 'react';
import PropTypes from 'prop-types';

import { react2angular } from 'react2angular';

import HoldListItem from './HoldListItem';
import { isComplete, isIncomplete } from './states';
import { forTermId } from '../../../helpers/terms';

const propTypes = {
  acknowledgements: PropTypes.array,
  termId: PropTypes.string,
  holds: PropTypes.array
};

const CALGRANT_SERVICE_INDICATOR_TYPE_CODE = 'F06';

const CalGrantAcknowledgementStatus = ({ acknowledgements, termId, holds }) => {
  const acknowledgement = forTermId(acknowledgements, termId);

  if (acknowledgement) {
    if (isComplete(acknowledgement)) {
      return (
        <HoldListItem
          title={`${acknowledgement.link.name} Complete`}
          state="green"
        />
      );
    } else if (isIncomplete(acknowledgement)) {
      const serviceIndicator = holds.filter(hold => {
        return hold.typeCode === CALGRANT_SERVICE_INDICATOR_TYPE_CODE;
      }).find(hold => hold.fromTerm.id === termId);

      if (serviceIndicator) {
        return (
          <HoldListItem
            state="red"
            title={acknowledgement.link.name}
            actionLink={acknowledgement.link}
          >
            {serviceIndicator.reason.formalDescription}
          </HoldListItem>
        );
      } else {
        return null;
      }
    }
  } else {
    return null;
  }
};

CalGrantAcknowledgementStatus.propTypes = propTypes;

angular.module('calcentral.react').component('calgrantAcknowledgementStatus', react2angular(CalGrantAcknowledgementStatus));

export default CalGrantAcknowledgementStatus;
