import React from 'react';
import { PropTypes } from 'prop-types';
import { connect } from 'react-redux';

import ProfilePicture from './ProfilePicture';

const propTypes = {
  name: PropTypes.string.isRequired,
  isDelegate: PropTypes.bool
};

const NameAndPhoto = ({ name, isDelegate }) => {
  return (
    <tr className="NameAndPhoto">
      <th>
        <ProfilePicture isDelegate={isDelegate} />
      </th>
      <td>{ name }</td>
    </tr>
  );
};

NameAndPhoto.propTypes = propTypes;

const mapStateToProps = ({
  myStatus: { fullName: name, delegateActingAsUid } = {}
}) => {
  const isDelegate = !!delegateActingAsUid;
  return { name, isDelegate };
};

export default connect(mapStateToProps)(NameAndPhoto);
