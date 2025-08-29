/**
* Copyright © 2019-2024 code initially contributed by Orange SA, authors: Denis Barbaron - Licensed under the Apache license 2.0
**/

const oboe = require('oboe')

module.exports = function UsersServiceFactory(
  $rootScope
  , $http
  , socket
  , CommonService
) {
  const UsersService = {}

  function buildQueryParameters(filters) {
    var query = ''

    if (filters.groupOwner !== 'Any') {
      query += 'groupOwner=' + filters.groupOwner.toLowerCase()
    }
    return query === '' ? query : '?' + query
  }

  UsersService.getOboeUsers = function (fields, addUser) {
    return oboe({
      url: CommonService.getBaseUrl() + '/api/v1/users?fields=' + fields,
      withCredentials: true,
      headers: {
        'X-XSRF-TOKEN': document.cookie.match(/X-XSRF-TOKEN=([^;]+)/)?.[1] || ''
      }
    })
      .node('users[*]', function (user) {
        addUser(user)
      })
  }

  UsersService.getUsersAlertMessage = function () {
    return $http.get(CommonService.getBaseUrl() + '/api/v1/users/alertMessage')
  }

  UsersService.getUsers = function (fields) {
    return $http.get(CommonService.getBaseUrl() + '/api/v1/users?fields=' + fields)
  }

  UsersService.getUser = function (email, fields) {
    return $http.get(CommonService.getBaseUrl() + '/api/v1/users/' + email + '?fields=' + fields)
  }

  UsersService.removeUser = function (email, filters) {
    return $http.delete(CommonService.getBaseUrl() + '/api/v1/users/' + email + buildQueryParameters(filters))
  }

  UsersService.removeUsers = function (filters, emails) {
    return $http({
      method: 'DELETE',
      url: CommonService.getBaseUrl() + '/api/v1/users' + buildQueryParameters(filters),
      headers: {
        'Content-Type': 'application/json;charset=utf-8'
      },
      data: typeof emails === 'undefined' ? emails : JSON.stringify({ emails: emails })
    })
  }

  UsersService.updateUserGroupsQuotas = function (email, number, duration, repetitions) {
    return $http.put(
      CommonService.getBaseUrl() + '/api/v1/users/' + email +
      '/groupsQuotas?number=' + number +
      '&duration=' + duration +
      '&repetitions=' + repetitions
    )
  }

  UsersService.updateDefaultUserGroupsQuotas = function (number, duration, repetitions) {
    return $http.put(
      CommonService.getBaseUrl() + '/api/v1/users/groupsQuotas?number=' + number +
      '&duration=' + duration +
      '&repetitions=' + repetitions
    )
  }

  UsersService.createUser = function (name, email) {
    return $http.post(CommonService.getBaseUrl() + '/api/v1/users/' + email + '?name=' + name)
  }

  socket.on('user.settings.users.created', function (user) {
    $rootScope.$broadcast('user.settings.users.created', user)
    $rootScope.safeApply()
  })

  socket.on('user.settings.users.deleted', function (user) {
    $rootScope.$broadcast('user.settings.users.deleted', user)
    $rootScope.safeApply()
  })

  socket.on('user.view.users.updated', function (user) {
    $rootScope.$broadcast('user.view.users.updated', user)
    $rootScope.safeApply()
  })

  socket.on('user.settings.users.updated', function (user) {
    $rootScope.$broadcast('user.settings.users.updated', user)
    $rootScope.safeApply()
  })

  socket.on('user.menu.users.updated', function (user) {
    $rootScope.$broadcast('user.menu.users.updated', user)
    $rootScope.safeApply()
  })

  return UsersService
}
