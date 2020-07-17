import React from 'react';
import PropTypes from 'prop-types';

// Get finals from a list of sections, ignoring those without an exam_date or
// exam_time (those have a message indicating that "Exam Information not
// available at this time."
const extractFinals = (acc, { finalExams }) => {
  if (finalExams) {
    const exams = finalExams.filter(exam => exam.exam_date || exam.exam_time);
    return [...acc, ...exams];
  }

  return acc;
};

import styles from './FinalExams.module.scss';

export default function FinalExams({ sections }) {
  const finals = sections.reduce(extractFinals, []);

  if (finals.length == 0) {
    return null;
  }

  return (
    <div className={styles.finalExams}>
      <h2 className={styles.title}>Final Exam Schedule</h2>

      {finals.map(({ exam_date, exam_time, exam_location }) => (
        <div key={exam_date || exam_time}>
          {[exam_date, exam_time, exam_location]
            .filter(item => item)
            .join(' • ')}
        </div>
      ))}
    </div>
  );
}

FinalExams.propTypes = {
  sections: PropTypes.array,
};
