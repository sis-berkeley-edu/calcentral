import PropTypes from 'prop-types';
import React from 'react';

import RedExclamationCircle from '../base/icon/RedExclamationCircle';

import '../../stylesheets/box_model.scss';
import '../../stylesheets/text.scss';

const CurrentGradeRatio = (props) => {
  const icon = props.pnpRatio.toPrecision(2) > 0.33 ? <RedExclamationCircle /> : null;
  return (
    <div>
      <h3 className='cc-react-text-normal cc-react-no-margin'>Current Passed (P) Grade Ratio</h3>
      <h2 className='cc-react-no-margin'>
        {icon} {props.pnpRatio}
      </h2>
      <h4 className='cc-react-text-normal'>
        (0.33 maximum allowed at graduation)
      </h4>
      <p className='cc-react-text-small cc-react-no-margin'>
        This ratio assumes that you will earn units for all currently enrolled classes.
      </p>
    </div>
  );
}
CurrentGradeRatio.propTypes = {
  pnpRatio: PropTypes.number
};

export default CurrentGradeRatio;
