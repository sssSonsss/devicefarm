// TODO: Sử dụng optional injection để ngTableParams không bắt buộc
module.exports = ['$scope', '$timeout', '$injector', function StoreAccountCtrl($scope, $timeout, $injector) {
  // Optional dependency - chỉ sử dụng nếu có
  var ngTableParams = null
  try {
    ngTableParams = $injector.get('ngTableParams')
  } catch (e) {
    // ngTableParams không có - không sao cả
    console.log('ngTableParams not available - using basic table functionality')
  }
  // TODO: This should come from the DB
  $scope.currentAppStore = 'google-play-store'
  $scope.deviceAppStores = {
    'google-play-store': {
      type: 'google-play-store',
      name: 'Google Play Store',
      package: 'com.google'
    }
  }

  $scope.addingAccount = false

  $scope.addAccount = function() {
    $scope.addingAccount = true
    var user = $scope.storeLogin.username.$modelValue
    var pass = $scope.storeLogin.password.$modelValue

    $scope.control.addAccount(user, pass).then(function() {
    }).catch(function(result) {
      throw new Error('Adding account failed', result)
    }).finally(function() {
      $scope.addingAccount = false
      $timeout(function() {
        getAccounts()
      }, 500)
    })
  }

  $scope.removeAccount = function(account) {
    var storeAccountType = $scope.deviceAppStores[$scope.currentAppStore].package
    $scope.control.removeAccount(storeAccountType, account)
      .then(function() {
        getAccounts()
      })
      .catch(function(result) {
        throw new Error('Removing account failed', result)
      })
  }

  function getAccounts() {
    var storeAccountType = $scope.deviceAppStores[$scope.currentAppStore].package
    if ($scope.control) {
      $scope.control.getAccounts(storeAccountType).then(function(result) {
        // FIX: Use $evalAsync for HTTP responses instead of safeApply
        $scope.$evalAsync(function() {
          $scope.accountsList = result.body
        })
      })
    }
  }

  getAccounts()
  
  // TODO: Optional dependency pattern - ngTableParams có thể sử dụng sau này nếu cần
  if (ngTableParams) {
    // Có thể implement table features advanced nếu cần
    console.log('ngTableParams available for advanced table features')
  }
}]
