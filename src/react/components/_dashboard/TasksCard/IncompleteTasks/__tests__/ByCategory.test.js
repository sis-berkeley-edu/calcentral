import { mapStateToProps } from '../ByCategory';

describe('Incomplete items', () => {
  describe('past their due date', () => {
    const findCategory = category => item => item.key === category;
    const overdueTask = {
      assignedDate: '2020-02-24',
      displayCategory: 'admissions',
      dueDate: '2019-07-15',
      status: 'Active',
      title: 'Fall Transcript',
    };

    test('sorted into the "Overdue" category', () => {
      const { categories } = mapStateToProps({
        myAgreements: {
          incompleteAgreements: [overdueTask],
        },
      });

      const overdueTasks = categories.find(findCategory('overdue')).tasks;
      const admissionsTasks = categories.find(findCategory('admissions')).tasks;

      expect(overdueTasks.length).toBe(1);
      expect(admissionsTasks.length).toBe(0);
    });

    test('sorted into displayCategory if "isBeingProcessed"', () => {
      const { categories } = mapStateToProps({
        myAgreements: {
          incompleteAgreements: [
            { ...overdueTask, isBeingProcessed: true, status: 'Received' },
          ],
        },
      });

      const overdueTasks = categories.find(findCategory('overdue')).tasks;
      const admissionsTasks = categories.find(findCategory('admissions')).tasks;

      expect(overdueTasks.length).toBe(0);
      expect(admissionsTasks.length).toBe(1);
    });

    test('sorted into overdue if "isBeingProcessed" and "isSir"', () => {
      const { categories } = mapStateToProps({
        myAgreements: {
          incompleteAgreements: [
            {
              ...overdueTask,
              isBeingProcessed: true,
              isSir: true,
              status: 'Received',
            },
          ],
        },
      });

      const overdueTasks = categories.find(findCategory('overdue')).tasks;
      const admissionsTasks = categories.find(findCategory('admissions')).tasks;

      expect(overdueTasks.length).toBe(1);
      expect(admissionsTasks.length).toBe(0);
    });
  });
});
