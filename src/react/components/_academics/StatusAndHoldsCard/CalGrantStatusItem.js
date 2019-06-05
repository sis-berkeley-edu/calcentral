import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import APILink from 'React/components/APILink';
import RedExclamationIcon from 'React/components/Icon/RedExclamationIcon';
import GreenCheckIcon from 'React/components/Icon/GreenCheckIcon';
import { DisclosureItem, DisclosureItemTitle } from 'React/components/DisclosureItem';
import StatusDisclosure from './StatusDisclosure';

import CalGrantAcknowledgementStatus from './CalGrantAcknowledgement/Status';

import {
  isComplete,
  isIncomplete,
  findCalGrantHoldForTermId
} from 'React/helpers/calgrants';

const propTypes = {
  acknowledgement: PropTypes.object,
  holds: PropTypes.array,
  viewAllLink: PropTypes.object,
  viewCompletedCalgrantLink: PropTypes.bool
};

const CalGrantStatusItem = ({ acknowledgement, holds, viewAllLink, viewCompletedCalgrantLink }) => {
  if (acknowledgement) {
    if (isIncomplete(acknowledgement)) {
      const hold = holds.find(findCalGrantHoldForTermId(acknowledgement.termId));

      return (
        <DisclosureItem>
          <DisclosureItemTitle>
            <RedExclamationIcon />
            <span style={{ marginLeft: '4px' }}>{ acknowledgement.link.name }
            </span> <APILink {...acknowledgement.link} name='Take action' />
          </DisclosureItemTitle>
          <StatusDisclosure>
            { hold.reason && hold.reason.formalDescription &&
              <Fragment>
                { hold.reason.formalDescription } <APILink { ...viewAllLink } />
              </Fragment>
            }
          </StatusDisclosure>
        </DisclosureItem>
      );
    } else if (isComplete(acknowledgement)) {
      if (viewCompletedCalgrantLink) {
        return (
          <DisclosureItem>
            <DisclosureItemTitle>
              <GreenCheckIcon />
              { acknowledgement.link.name } Completed
            </DisclosureItemTitle>
            <StatusDisclosure>
              <APILink { ...viewAllLink } />
            </StatusDisclosure>
          </DisclosureItem>
        );
      } else {
        return (
          <CalGrantAcknowledgementStatus
            acknowledgement={acknowledgement}
            termId={acknowledgement.termId}
            holds={holds}
          />
        );
      }
    }
  } else {
    return null;
  }
};

const mapStateToProps = ({
  myHolds: { holds } = {},
  myCalGrants: { viewAllLink } = {},
  myStatus: { features: { viewCompletedCalgrantLink } = {} } = {}
}) => {
  return {
    holds: holds || [],
    viewAllLink,
    viewCompletedCalgrantLink
  };
};

CalGrantStatusItem.propTypes = propTypes;

export default connect(mapStateToProps)(CalGrantStatusItem);
