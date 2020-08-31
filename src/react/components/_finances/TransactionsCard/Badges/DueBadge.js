import React from 'react';
import PropTypes from 'prop-types';

import 'icons/due-now.svg';
import 'icons/not-yet-due.svg';
import 'icons/exclamation-circle.svg';

import './Badges.scss';

import badgeStatusClassName from './badgeStatusClassName';

const DueBadge = ({ status }) => {
  const className = `Badge Badge--icon ${badgeStatusClassName(status)}`;
  return <div className={className}>{status}</div>;
};

DueBadge.propTypes = {
  status: PropTypes.string,
};

export default DueBadge;
