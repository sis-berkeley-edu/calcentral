import PropTypes from 'prop-types';
import React from 'react';

class ListHeader extends React.Component {
  render() {
    return (
      <h3>{this.props.header}</h3>
    );
  }
}
ListHeader.propTypes = {
  header: PropTypes.string.isRequired
};

export default ListHeader;
