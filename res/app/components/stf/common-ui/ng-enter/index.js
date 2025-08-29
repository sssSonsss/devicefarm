module.exports = angular.module('stf.ng-enter', [
  require('stf/common-ui/safe-apply').name
])
  .directive('ngEnter', require('./ng-enter-directive'))
