import { createContext } from 'react';

const TasksContext = createContext({
  hasFocus: true,
  selectedItem: '',
  setSelectedItem: () => {},
});

export default TasksContext;
