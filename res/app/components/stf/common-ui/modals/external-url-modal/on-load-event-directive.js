// TODO: Test this
module.exports = function() {
  return function(scope, element, attrs) {
    scope.$watch(attrs.pageVisible, function() {
          element.bind('load', function() {
      // FIX: Use $evalAsync for DOM load events instead of safeApply
      scope.$evalAsync(function() {
        scope.$eval(attrs.pageLoad)
      })
    })
    })
  }
}
