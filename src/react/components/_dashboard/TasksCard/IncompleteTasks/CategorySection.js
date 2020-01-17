import React from 'react';
import PropTypes from 'prop-types';

import { shortDateIfCurrentYear, parseDate } from 'functions/formatDate';

import CampusSolutionsIcon from '../Icons/CampusSolutionsIcon';
import SectionHeader from '../SectionHeader';

import Task from '../Task';
import TaskHeader from '../TaskHeader';
import TaskTitle from '../TaskTitle';

import styles from './CategorySection.module.scss';

const CategorySection = ({ categorySection, items, columns, children }) => {
  return (
    <div className={styles.categorySection}>
      {categorySection === 'beingProcessed' && (
        <div className={styles.beingProcessedDivider}>
          <span>Being processed</span>{' '}
          <span className={styles.Badge}>{items.length}</span>
        </div>
      )}

      <SectionHeader
        columns={columns}
        leftBorder={categorySection === 'beingProcessed'}
      />

      <div className={styles.tasks}>
        {children
          ? children
          : items.map((task, index) => (
              <Task
                key={index}
                index={index}
                task={task}
                type={categorySection}
              >
                <TaskHeader task={task}>
                  <CampusSolutionsIcon />
                  <TaskTitle
                    title={task.title}
                    subtitle={`${task.status} ${shortDateIfCurrentYear(
                      parseDate(task.assignedDate)
                    )}`}
                  />
                </TaskHeader>
              </Task>
            ))}
      </div>
    </div>
  );
};

CategorySection.propTypes = {
  items: PropTypes.array,
  children: PropTypes.node,
  columns: PropTypes.array,
  categorySection: PropTypes.string,
};

CategorySection.defaultProps = {
  columns: [],
};

export default CategorySection;
