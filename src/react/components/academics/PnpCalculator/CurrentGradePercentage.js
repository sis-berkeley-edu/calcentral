import PropTypes from 'prop-types';
import React from 'react';

import Icon from '../../Icon/Icon';
import { ICON_EXCLAMATION } from '../../Icon/IconTypes';

import '../../../stylesheets/box_model.scss';
import '../../../stylesheets/text.scss';

const propTypes = {
  hasExcessNoGpaUnits: PropTypes.bool,
  pnpPercentage: PropTypes.number
};

const renderExcessUnitsMessage = (hasExcessNoGpaUnits) => {
  if (hasExcessNoGpaUnits) {
    return (
      <p className="cc-react-text--small">{`Since you've reached 120 units, excess P/NP units are not factored in this percentage.`}</p>
    );
  } else {
    return null;
  }
};

const CurrentGradePercentage = (props) => {
  const icon = props.pnpPercentage > 33 ? <Icon name={ICON_EXCLAMATION} /> : null;
  return (
    <div>
      <h3 className='cc-react-text--normal cc-react--no-margin'>Your current Passed (P) grade percentage:</h3>
      <h2 className='cc-react--no-margin'>
        {icon} {`${Math.round(props.pnpPercentage)}%`}
      </h2>
      <h4 className='cc-react-text--normal'>
        (33% maximum allowed at graduation)
      </h4>
      {renderExcessUnitsMessage(props.hasExcessNoGpaUnits)}
      <p className='cc-react-text--small cc-react--no-margin'>
        This percentage includes all in progress classes and assumes you will earn units for these classes.
      </p>
    </div>
  );
};
CurrentGradePercentage.propTypes = propTypes;

export default CurrentGradePercentage;
