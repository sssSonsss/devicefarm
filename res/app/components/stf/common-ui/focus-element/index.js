module.exports = angular.module('stf.focus-element', [
  require('stf/common-ui/safe-apply').name
])
  .directive('focusElement', require('./focus-element-directive'))
