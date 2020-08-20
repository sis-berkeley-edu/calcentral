import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { useLocation } from 'react-router-dom';
import axios from 'axios';

import ClassInformationCard from './ClassInformationCard';

const fetchCourseSections = async (termId, courseId, sectionIds) => {
  const response = await axios.get(
    `/api/my/academics/terms/${termId}/courses/${courseId}/sections`,
    {
      params: {
        ids: sectionIds.join(','),
      },
    }
  );

  return response.data;
};

function ClassInformationContainer({ semesters, teachingSemesters }) {
  const [sections, setSections] = useState([]);
  const location = useLocation();
  const pathname = location.pathname;
  const pathComponents = pathname.split('/');

  const semesterSlug = pathComponents[3];
  const courseId = pathComponents[5];
  const isInstructor = pathComponents[2] === 'teaching-semester';

  const semester = (isInstructor ? teachingSemesters : semesters).find(
    semester => semester.slug === semesterSlug
  );

  const termId = semester.termId;
  const course = semester.classes.find(course => course.course_id === courseId);
  const { cs_course_id: csCourseId } = course;

  useEffect(() => {
    const catalogNumbers = course.sections.map(section => section.ccn);

    fetchCourseSections(termId, csCourseId, catalogNumbers).then(data => {
      setSections(
        course.sections.map(section => ({
          ...section,
          ...data.find(sec => sec.ccn === section.ccn),
        }))
      );
    });
  }, [termId, csCourseId]);

  return (
    <ClassInformationCard
      loaded={sections.length > 0}
      termId={termId}
      course={{ ...course, sections: sections, semesterSlug: semesterSlug }}
      isInstructor={isInstructor}
    />
  );
}

ClassInformationContainer.propTypes = {
  semesters: PropTypes.array,
  teachingSemesters: PropTypes.array,
};

const mapStateToProps = ({
  myAcademics: { semesters = [], teachingSemesters = [] },
}) => {
  return {
    semesters,
    teachingSemesters,
  };
};

const mapDispatchToProps = () => {
  return {};
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(ClassInformationContainer);
