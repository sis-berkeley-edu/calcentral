import PropTypes from 'prop-types';
import React from 'react';

import '../../../stylesheets/widgets.scss';

const WidgetBody = (props) => {
  return (
    <div className={props.padding ? 'cc-react-widget--padding' : ''}>
      {props.children}
    </div>
  );
};
WidgetBody.defaultProps = {
  padding: true
};
WidgetBody.propTypes = {
  children: PropTypes.node.isRequired,
  padding: PropTypes.bool
};

export default WidgetBody;
