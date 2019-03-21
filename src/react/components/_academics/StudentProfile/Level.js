import React from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  level: PropTypes.string,
  nonApLevel: PropTypes.string
};

const Level = ({ level, nonApLevel }) => (
  <tr>
    <th>Level</th>
    <td>
      {nonApLevel
        ? (
          <table>
            <tbody>
              <tr>
                <th>Including AP</th>
                <th>Not Including AP</th>
              </tr>
              <tr>
                <td>{ level }</td>
                <td>{ nonApLevel }</td>
              </tr>
            </tbody>
          </table>
          
        )
        : level
      }
    </td>
  </tr>
);

Level.propTypes = propTypes;

export default Level;
