'use strict'

angular.module('tandemApp')
  .factory 'Meeting', ($resource, apiUrl) ->
    #This will be more fleshed out when backend API is defined
    meeting: $resource apiUrl+'meeting/:id',
        {id: '@id'},
        {
          'get': {method: 'GET'},
          'create': {method: 'GET'}
          'update': {method: 'PUT'}
          'send': {method: 'POST'}
        }
    attendee: $resource apiUrl+'meeting/:id/attendee/:email',
        {id: '@id', email: "@email"},
        {
          'add': {method: 'POST'}
          'remove': {method: 'DELETE'}
        }

