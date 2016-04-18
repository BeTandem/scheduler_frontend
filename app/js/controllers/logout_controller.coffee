'use strict'

###*
# @ngdoc controller
# @name tandemApp.controller:LogoutController
# @description
# # logout
# Controller for logging out of the Tandem frontend app.
###
angular.module 'tandemApp'

.controller 'LogoutController', ($location, $auth) ->
  # Remove auth token and redirect to login
  $auth.removeToken()
  $location.path '/login'
