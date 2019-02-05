import React from 'react';
import PropTypes from 'prop-types';

import '../../../stylesheets/widgets.scss';

const WidgetSectionHeader = (props) => {
  return (
    <div className="cc-react-widget__section-title">
      <h2>{props.title}</h2>
    </div>
  );
};
WidgetSectionHeader.propTypes = {
  title: PropTypes.string.isRequired
};

export default WidgetSectionHeader;
