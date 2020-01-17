import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { format, parseISO } from 'date-fns';

import './Dropdowns.scss';

const getSemesterList = semesters => {
  let semesterList;

  switch (semesters.length) {
    case 1:
      semesterList = semesters[0];
      break;
    case 2:
      semesterList = semesters[0] + ' and ' + semesters[1];
      break;
    case 3:
      semesterList =
        semesters[0] + ', ' + semesters[1] + ' and ' + semesters[2];
      break;
    default:
      semesterList = semesters.join(', ');
  }

  return semesterList;
};

const Dropdowns = ({
  aidYear,
  aidYears,
  onAidYearChange,
  selectedDate,
  onDateChange,
}) => {
  const [aidYearDropdown, setAidYearDropdown] = useState([]);
  const [activityDates, setActivityDates] = useState([]);

  useEffect(() => {
    const ayDropdown = aidYears.map(ay =>
      ay.activityDates.length > 0
        ? {
            id: ay.id,
            name: ay.name,
            terms: getSemesterList(
              aidYears.find(x => x.id === ay.id).availableSemesters
            ),
          }
        : ''
    );

    setAidYearDropdown(ayDropdown);
  }, [aidYears]);

  useEffect(() => {
    const activityDatesList = aidYears.find(ay => ay.id === aidYear)
      .activityDates;

    const activityDatesListFormatted = activityDatesList.map(date => ({
      value: date,
      label: format(parseISO(date), 'MMM d, y'),
    }));

    setActivityDates(activityDatesListFormatted);
  }, [aidYear]);

  return (
    <fieldset className="noBorder">
      <div className="options">
        <div className="labelValue">
          <label id="AidYearLabel" className="label">
            Aid Year
          </label>
          <select
            className="value"
            value={aidYear}
            aria-labelledby="AidYearLabel"
            onChange={e => onAidYearChange(e.target.value)}
          >
            {aidYearDropdown.map(ay =>
              ay ? (
                <option key={ay.id} value={ay.id}>
                  {ay.name} {ay.terms}
                </option>
              ) : (
                ''
              )
            )}
          </select>
        </div>
        <div className="labelValue">
          <label id="ActivityDatesLabel" className="label">
            Prior Version
          </label>
          <select
            className="value"
            value={selectedDate}
            aria-labelledby="ActivityDatesLabel"
            onChange={e => onDateChange(e.target.value)}
          >
            <option value="X" disabled>
              Select Prior Package
            </option>
            {activityDates.slice(1).map(date => (
              <option key={date.value} value={date.value}>
                {date.label}
              </option>
            ))}
          </select>
        </div>
      </div>
    </fieldset>
  );
};

Dropdowns.displayName = 'AwardComparisonDropdowns';
Dropdowns.propTypes = {
  aidYear: PropTypes.string.isRequired,
  aidYears: PropTypes.array.isRequired,
  onAidYearChange: PropTypes.func.isRequired,
  selectedDate: PropTypes.string.isRequired,
  onDateChange: PropTypes.func.isRequired,
};

export default Dropdowns;
