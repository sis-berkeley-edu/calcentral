import { react2angular } from 'react2angular';
import DegreeProgressNotice from 'react/components/_academics/DegreeProgress/DegreeProgressNotice';

angular
  .module('calcentral.react')
  .component('degreeProgressNotice', react2angular(DegreeProgressNotice));
