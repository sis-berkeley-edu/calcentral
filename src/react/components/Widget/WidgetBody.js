import PropTypes from 'prop-types';
import React from 'react';

import Spinner from '../Spinner';

import '../../stylesheets/widgets.scss';

const propTypes = {
  children: PropTypes.node.isRequired,
  widgetConfig: PropTypes.object.isRequired
};

const renderErrorMessage = (errorMessage) => {
  let messageComponent;
  if (typeof errorMessage === 'string' || errorMessage instanceof String) {
    messageComponent = (<p className="cc-react--no-margin">{errorMessage}</p>);
  } else {
    messageComponent = errorMessage;
  }
  return (
    <div className="cc-react-widget--padding">
      {messageComponent}
    </div>
  );
};

const WidgetBody = (props) => {
  const {widgetConfig, children} = props;
  if (widgetConfig.errored) {
    return renderErrorMessage(widgetConfig.errorMessage);
  } else if (widgetConfig.isLoading) {
    return <Spinner isLoadingMessage={widgetConfig.isLoadingMessage} />;
  } else {
    return (
      // if no "padding" prop is passed, default to having the widget padding
      <div className={widgetConfig.padding || !widgetConfig.hasOwnProperty('padding') ? 'cc-react-widget--padding' : ''}>
        {children}
      </div>
    );
  }
};

WidgetBody.propTypes = propTypes;

export default WidgetBody;
