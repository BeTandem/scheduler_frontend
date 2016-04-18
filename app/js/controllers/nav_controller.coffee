'use strict'

angular.module 'tandemApp'

.controller 'NavController', ($scope, $location, $auth, jwtHelper) ->
  $scope.isActive = (path)->
    if path == $location.path()
      return 'active'
    else
      return ''

  $scope.isAuthed = ->
    auth = $auth.isAuthenticated()
    if auth
      token = $auth.getToken()
      $scope.username = jwtHelper.decodeToken(token).name
    return auth
