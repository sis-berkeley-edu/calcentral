import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  value: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number
  ])
};

const ValueOrDash = (props) => (
  props.value
    ? props.value
    : <Fragment>&mdash;</Fragment>
);

ValueOrDash.propTypes = propTypes;

export default ValueOrDash;
