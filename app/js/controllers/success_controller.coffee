'use strict'

angular.module 'tandemApp'

.controller 'SuccessController', ($scope, $state, $stateParams) ->
  $scope.event = $stateParams.event

  if !$scope.event
    return $state.go('home')

  formatDate = (dateString) ->
    date = new Date(dateString)
    monthNames = [
      "January", "February", "March",
      "April", "May", "June", "July",
      "August", "September", "October",
      "November", "December"
    ]
    day = date.getDate()
    monthIndex = date.getMonth()
    year = date.getFullYear()
    hours = date.getHours()
    am_pm = determineAmOrPm(hours)
    hours = convertFromMilitary(hours)
    hours = addZero(hours)
    mins = addZero(date.getMinutes())
    return monthNames[monthIndex] + " " + day + ", " + year + " @ " + hours + ":" + mins + " " + am_pm

  addZero = (hours) ->
    if hours < 10
      hours = "0" + hours
    return hours

  determineAmOrPm = (hours) ->
    if hours >= 12
      return "PM"
    else
      return "AM"

  convertFromMilitary = (hours) ->
    if hours > 12
      hours -= 12
    return hours

  time = formatDate($scope.event.start.dateTime)
  $scope.event.humanStartTime  = time
  console.log $scope.event

