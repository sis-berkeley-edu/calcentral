import React from 'react';
import PropTypes from 'prop-types';

const Spinner = (props) => (
  <div className="cc-spinner" aria-live="polite" aria-busy={true}>
    {props.children && <p className="cc-spinner-message">{props.children}</p>}
  </div>
);

Spinner.propTypes = {
  children: PropTypes.node
};

export default Spinner;
