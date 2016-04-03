'use strict'

###*
# @ngdoc controller
# @name tandemApp.controller:LoginController
# @description
# # login
# Controller for logging into the Tandem frontend app.
###
angular.module 'tandemApp'

.controller 'LoginController', ($scope, $location, $auth) ->

  $scope.authenticate = (provider) ->
    $auth.authenticate(provider)
    .then (response)->
      # Auth automatically stored in localStorage vi $auth
      $location.path "/create-meeting"
    .catch (error)->
      # Handle error
      alert(error)
      console.log(error)
