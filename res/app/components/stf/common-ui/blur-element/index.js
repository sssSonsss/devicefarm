module.exports = angular.module('stf.blur-element', [
  require('stf/common-ui/safe-apply').name
])
  .directive('blurElement', require('./blur-element-directive'))
