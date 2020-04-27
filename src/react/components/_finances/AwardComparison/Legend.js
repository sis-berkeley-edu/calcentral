import React from 'react';
import PropTypes from 'prop-types';
import { format, parseISO } from 'date-fns';
import OrangeChangedIcon from '../../Icon/OrangeChangedIcon';
import './AwardComparison.scss';

const Legend = ({ asOfCurrentDate, selectedDate }) => {
  return (
    <div className="legend container">
      {/* <div className="container"> */}
      <table>
        <tbody>
          <tr className="legendBorder">
            <th scope="col">
              <div className="indicatesChangeColumn">
                <OrangeChangedIcon className="hideSmallFormFactor icon" />
                <div className="hideSmallFormFactor">Indicates Change</div>
              </div>
            </th>
            <th scope="col">
              <div className="justifiedRightColumn">
                <div className="textStrong">Prior</div>
                <div className="direction">
                  {selectedDate == 'X' ? (
                    <>
                      <div>Not</div>
                      <div> Selected</div>
                    </>
                  ) : (
                    <>
                      <div className="dimGrey">As of</div>
                      <div className="dimGrey">
                        {' '}
                        {format(parseISO(selectedDate), 'MMM d, y')}
                      </div>
                    </>
                  )}
                </div>
              </div>
            </th>
            <th scope="col">
              <div className="justifiedRightColumn">
                <div className="textStrong">Current</div>
                <div className="direction">
                  <div className="dimGrey">As of</div>
                  <div className="dimGrey">
                    {' '}
                    {format(parseISO(asOfCurrentDate), 'MMM d, y')}
                  </div>
                </div>
              </div>
            </th>
          </tr>
        </tbody>
      </table>
    </div>
  );
};

Legend.propTypes = {
  asOfCurrentDate: PropTypes.string.isRequired,
  selectedDate: PropTypes.string,
};

export default Legend;
