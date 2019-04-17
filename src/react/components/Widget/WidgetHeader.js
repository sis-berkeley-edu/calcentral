import React from 'react';
import PropTypes from 'prop-types';

import Icon from '../Icon/Icon';
import { ICON_ARROW_RIGHT } from '../Icon/IconTypes';

import '../../stylesheets/box_model.scss';
import '../../stylesheets/widgets.scss';

const propTypes = {
  link: PropTypes.shape({
    url: PropTypes.string,
    text: PropTypes.string
  }),
  title: PropTypes.string.isRequired
};

const renderHeaderLink = (link) => {
  if (link && link.hasOwnProperty('url') && link.hasOwnProperty('text')) {
    return (
      <div className="cc-react-widget__title-link cc-react--float-right">
        <a href={link.url}>
          {link.text} <Icon name={ICON_ARROW_RIGHT} />
        </a>
      </div>
    );
  }
};

const WidgetHeader = (props) => {
  return (
    <div className="cc-react-widget__title">
      <h2 className="cc-react--float-left cc-react-widget__title-text">{props.title}</h2>
      {renderHeaderLink(props.link)}
    </div>
  );
};
WidgetHeader.propTypes = propTypes;

export default WidgetHeader;
