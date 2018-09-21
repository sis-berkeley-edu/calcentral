import React from 'react';
import PropTypes from 'prop-types';

class BulletList extends React.Component {
  render() {
    return (
      <ul className="cc-list-bullets">
        {this.props.children}
      </ul>
    );
  }
}
BulletList.propTypes = {
  children: PropTypes.node.isRequired
};

export default BulletList;
