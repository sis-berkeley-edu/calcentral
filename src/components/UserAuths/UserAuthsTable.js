import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';

import Table from 'components/Table';
import { propTypes, propShape } from './userAuth.module.js';

const UserAuth = ({ userAuth }) => (
  <tr>
    <td>
      <Link to={`/user_auths/${userAuth.id}/edit`}>{userAuth.uid}</Link>
    </td>
    <td>{userAuth.is_active ? 'Yes' : null}</td>
    <td>{userAuth.is_viewer ? 'Yes' : null}</td>
    <td>{userAuth.is_author ? 'Yes' : null}</td>
    <td>{userAuth.is_superuser ? 'Yes' : null}</td>
  </tr>
);

UserAuth.propTypes = propTypes;

const UserAuthsTable = ({ userAuths }) => (
  <Table>
    <thead>
      <tr>
        <th>UID</th>
        <th>Active?</th>
        <th>Viewer?</th>
        <th>Author?</th>
        <th>Superuser?</th>
      </tr>
    </thead>
    <tbody>
      {userAuths.map(userAuth => (
        <UserAuth key={userAuth.id} userAuth={userAuth} />
      ))}
    </tbody>
  </Table>
);

UserAuthsTable.propTypes = {
  userAuths: PropTypes.arrayOf(propShape),
};

export default UserAuthsTable;
