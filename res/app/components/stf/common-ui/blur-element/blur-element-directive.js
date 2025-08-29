module.exports = function blurElementDirective($parse, $timeout) {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      var model = $parse(attrs.blurElement)

      scope.$watch(model, function(value) {
        if (value === true) {
          $timeout(function() {
            element[0].blur()
          })
        }
      })

      element.bind('blur', function() {
        // FIX: Use $evalAsync instead of safeApply for proper digest cycle management
        scope.$evalAsync(function() {
          model.assign(scope, false)
        })
      })
    }
  }
}
