module.exports = function ngEnterDirective() {
  return function(scope, element, attrs) {
    element.bind('keydown keypress', function(event) {
      if (event.which === 13) {
        // FIX: Use $evalAsync for DOM events instead of safeApply
        scope.$evalAsync(function() {
          scope.$eval(attrs.ngEnter, {event: event})
        })
        event.preventDefault()
      }
    })
  }
}
