import React, { useState } from 'react';
import PropTypes from 'prop-types';

import BCoursesTask from './BCoursesTask';

import Category from '../Category';
import CategorySection from './CategorySection';
import CategoryHeader from './CategoryHeader';

const BCoursesTasks = ({ tasks }) => {
  const [expanded, setExpanded] = useState(false);

  return (
    <Category withBottomBorder={true}>
      <CategoryHeader
        tasks={tasks}
        title="bCourses Tasks"
        expanded={expanded}
        setExpanded={setExpanded}
        incompleteCount={tasks.length}
      />

      {expanded && (
        <CategorySection items={tasks}>
          {tasks.map(task => (
            <BCoursesTask key={task.id} index={task.id} task={task} />
          ))}
        </CategorySection>
      )}
    </Category>
  );
};

BCoursesTasks.propTypes = {
  tasks: PropTypes.array,
};

export default BCoursesTasks;
