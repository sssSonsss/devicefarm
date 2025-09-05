/**
* Copyright © 2019 code initially contributed by Orange SA, authors: Denis Barbaron - Licensed under the Apache license 2.0
**/

const oboe = require('oboe')

module.exports = function DevicesServiceFactory(
  $rootScope
, $http
, socket
, CommonService
) {
  const DevicesService = {}

  function buildQueryParameters(filters) {
    var query = ''

    if (filters.present !== 'Any') {
      query += 'present=' + filters.present.toLowerCase()
    }
    if (filters.booked !== 'Any') {
      query += (query === '' ? '' : '&') + 'booked=' + filters.booked.toLowerCase()
    }
    if (filters.annotated !== 'Any') {
      query += (query === '' ? '' : '&') + 'annotated=' + filters.annotated.toLowerCase()
    }
    if (filters.controlled !== 'Any') {
      query += (query === '' ? '' : '&') + 'controlled=' + filters.controlled.toLowerCase()
    }
    return query === '' ? query : '?' + query
  }

  DevicesService.getOboeDevices = function(target, fields, addDevice) {
    return oboe({
      url: window.STF_CONFIG.API_BASE_URL + '/api/v1/devices?target=' + target + '&fields=' + fields,
      withCredentials: true,
      headers: {
        'X-XSRF-TOKEN': document.cookie.match(/XSRF-TOKEN=([^;]+)/)?.[1] || ''
      }
    })
      .node('devices[*]', function(device) {
        addDevice(device)
      })
  }

  DevicesService.getDevices = function(target, fields) {
    return $http.get('/api/v1/devices?target=' + target + '&fields=' + fields)
  }

  DevicesService.getDevice = function(serial, fields) {
    return $http.get('/api/v1/devices/' + serial + '?fields=' + fields)
  }

  DevicesService.removeDevice = function(serial, filters) {
    return $http.delete('/api/v1/devices/' + serial + buildQueryParameters(filters))
  }

  DevicesService.removeDevices = function(filters, serials) {
    return $http({
      method: 'DELETE',
      url: '/api/v1/devices' + buildQueryParameters(filters),
      headers: {
        'Content-Type': 'application/json;charset=utf-8'
      },
      data: typeof serials === 'undefined' ? serials : JSON.stringify({serials: serials})
    })
  }

  DevicesService.addOriginGroupDevice = function(id, serial) {
    return $http.put('/api/v1/devices/' + serial + '/groups/' + id)
  }

  DevicesService.addOriginGroupDevices = function(id, serials) {
    return $http({
      method: 'PUT',
      url: '/api/v1/devices/groups/' + id + '?fields=""',
      data: typeof serials === 'undefined' ? serials : JSON.stringify({serials: serials})
    })
  }

  DevicesService.removeOriginGroupDevice = function(id, serial) {
    return $http.delete('/api/v1/devices/' + serial + '/groups/' + id)
  }

  DevicesService.removeOriginGroupDevices = function(id, serials) {
    return $http({
      method: 'DELETE',
      url: '/api/v1/devices/groups/' + id + '?fields=""',
      headers: {
        'Content-Type': 'application/json;charset=utf-8'
      },
      data: typeof serials === 'undefined' ? serials : JSON.stringify({serials: serials})
    })
  }

  socket.on('user.settings.devices.created', function(device) {
    $rootScope.$broadcast('user.settings.devices.created', device)
    $rootScope.safeApply()
  })

  socket.on('user.settings.devices.deleted', function(device) {
    $rootScope.$broadcast('user.settings.devices.deleted', device)
    $rootScope.safeApply()
  })

  socket.on('user.settings.devices.updated', function(device) {
    $rootScope.$broadcast('user.settings.devices.updated', device)
    $rootScope.safeApply()
  })

  return DevicesService
}
