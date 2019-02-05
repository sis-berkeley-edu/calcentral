import React from 'react';
import PropTypes from 'prop-types';

import '../../../stylesheets/widgets.scss';

const WidgetHeader = (props) => {
  return (
    <div className="cc-react-widget__title">
      <h2>{props.title}</h2>
    </div>
  );
};
WidgetHeader.propTypes = {
  title: PropTypes.string.isRequired
};

export default WidgetHeader;
