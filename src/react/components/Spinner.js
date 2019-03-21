import React from 'react';
import PropTypes from 'prop-types';

import '../stylesheets/widgets.scss';
import '../stylesheets/spinners.scss';

const propTypes = {
  isLoadingMessage: PropTypes.string
};

const renderMessage = (isLoadingMessage) => {
  if (isLoadingMessage) {
    return (
      <p className="cc-react-spinner-message">{isLoadingMessage}</p>
    );
  } else {
    return null;
  }
};

const Spinner = (props) => {
  return (
    <div className='cc-react-widget--padding'>
      <div aria-live="polite" className="cc-react-spinner" aria-busy={true}></div>
      {renderMessage(props.isLoadingMessage)}
    </div>
  );
};
Spinner.propTypes = propTypes;

export default Spinner;
