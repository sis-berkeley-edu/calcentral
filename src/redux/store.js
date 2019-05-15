/* eslint no-underscore-dangle: 0 */

import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';

import AppReducer from './reducers/AppReducer';


const store = window.__REDUX_DEVTOOLS_EXTENSION__
  ? createStore(AppReducer, compose(applyMiddleware(thunk), window.__REDUX_DEVTOOLS_EXTENSION__()))
  : createStore(AppReducer, applyMiddleware(thunk));

export default store;
