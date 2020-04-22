import React from 'react';

const SelectedDateContext = React.createContext({
  selectedDate: String,
});
SelectedDateContext.displayName = 'SelectedDateContext';

export default SelectedDateContext;
