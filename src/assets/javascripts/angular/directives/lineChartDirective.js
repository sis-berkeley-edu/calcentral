'use strict';

var angular = require('angular');
var Highcharts = require('highcharts');
var _ = require('lodash');

angular.module('calcentral.directives').directive('ccLineChartDirective', function() {
  return {
    restrict: 'E',
    template: '<div></div>',
    scope: {
      options: '=',
      data: '='
    },
    link: function(scope, element) {
      // Initialize a generic CalCentral line chart.
      var chartOptions = {
        // Removes HighChartsJS link
        credits: {
          enabled: false
        },
        // Removes ability to download chart.
        exporting: {
          enabled: false
        },
        legend: {
          enabled: false
        },
        plotOptions: {
          line: {
            marker: {
              enabled: false
            },
            states: {
              hover: {
                enabled: false
              }
            }
          }
        },
        tooltip: {
          enabled: false
        },
        title: {
          text: null
        }
      };

      // Merge any custom options defined in the Controller.
      _.merge(chartOptions, scope.options);
      // Unless there is already a set of series data defined in the controller, this will render a blank chart.
      var chart = new Highcharts.Chart(element[0], chartOptions, function() {
        // Watch for new data coming in via API, and update chart with new data series.
        scope.$watchCollection('data', function(newArray) {
          chart.addSeries({
            // Only add the latest series of the $digest cycle.
            data: newArray[newArray.length - 1]
          });
          chart.reflow();
        });
      });
    }
  };
});
