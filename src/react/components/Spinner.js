import React from 'react';
import PropTypes from 'prop-types';

import '../stylesheets/widgets.scss';
import '../stylesheets/spinners.scss';

const Spinner = ({ isLoadingMessage, padded }) => {
  const paddingClass = padded === false ? null : 'cc-react-widget--padding';

  return (
    <div className={paddingClass}>
      <div
        aria-live="polite"
        className="cc-react-spinner"
        aria-busy={true}
      ></div>
      {isLoadingMessage && (
        <p className="cc-react-spinner-message">{isLoadingMessage}</p>
      )}
    </div>
  );
};

Spinner.propTypes = {
  isLoadingMessage: PropTypes.string,
  padded: PropTypes.bool,
};

export default Spinner;
