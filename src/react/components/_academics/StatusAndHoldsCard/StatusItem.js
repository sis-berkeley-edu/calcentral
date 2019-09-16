import React from 'react';
import PropTypes from 'prop-types';
import { DisclosureItem, DisclosureItemTitle } from 'React/components/DisclosureItem';
import StatusDisclosure from './StatusDisclosure';
import RegistrationStatusIcon from '../RegistrationStatusIcon';

const StatusItem = ({ status = {} }) => {
  const { message, severity, detailedMessageHTML } = status || {};

  if (message === null) {
    return null;
  }

  if (detailedMessageHTML === null || detailedMessageHTML === '') {
    return (
      <div className='StatusItem'>
        <RegistrationStatusIcon severity={severity} />
        {message}
      </div>
    );
  }

  return (
    <DisclosureItem>
      <DisclosureItemTitle>
        <RegistrationStatusIcon severity={severity} />
        {message}
      </DisclosureItemTitle>
      <StatusDisclosure>
        { typeof detailedMessageHTML === 'object'
          ? detailedMessageHTML
          : <div dangerouslySetInnerHTML={{__html: detailedMessageHTML }} />
        }
      </StatusDisclosure>
    </DisclosureItem>
  );
};

StatusItem.propTypes = {
  status: PropTypes.object
};

export default StatusItem;
