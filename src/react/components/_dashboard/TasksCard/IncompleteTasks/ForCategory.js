import React, { useState } from 'react';
import PropTypes from 'prop-types';

import { shortDateIfCurrentYear, parseDate } from 'functions/formatDate';

import Category from '../Category';
import CategoryHeader from './CategoryHeader';
import CategorySection from './CategorySection';

import Task from '../Task';
import TaskHeader from '../TaskHeader';
import TaskTitle from '../TaskTitle';
import CampusSolutionsIcon from '../Icons/CampusSolutionsIcon';

const ForCategory = ({ category }) => {
  const [expanded, setExpanded] = useState(false);
  const tasks = category.tasks;

  return (
    <Category withBottomBorder={true}>
      <CategoryHeader
        title={category.title}
        expanded={expanded}
        setExpanded={setExpanded}
        incompleteCount={category.tasks.length}
      />

      {expanded && (
        <CategorySection items={tasks}>
          {tasks.map((task, index) => (
            <Task key={index} index={index} task={task} type="">
              <TaskHeader task={task}>
                <CampusSolutionsIcon />
                <TaskTitle
                  title={task.title}
                  subtitle={`Due ${shortDateIfCurrentYear(
                    parseDate(task.dueDate)
                  )}`}
                />
              </TaskHeader>
            </Task>
          ))}
        </CategorySection>
      )}
    </Category>
  );
};

ForCategory.propTypes = {
  category: PropTypes.object,
};

export default ForCategory;
