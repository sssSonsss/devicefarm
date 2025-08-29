module.exports = function focusElementDirective($parse, $timeout) {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      var model = $parse(attrs.focusElement)

      scope.$watch(model, function(value) {
        if (value === true) {
          $timeout(function() {
            element[0].focus()
          })
        }
      })

      element.bind('blur', function() {
        if (model && model.assign) {
          // FIX: Use $evalAsync instead of safeApply for proper digest cycle management
          scope.$evalAsync(function() {
            model.assign(scope, false)
          })
        }
      })
    }
  }
}
