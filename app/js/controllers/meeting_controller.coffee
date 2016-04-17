'use strict'

angular.module 'tandemApp'

.controller 'MeetingController',
($scope, $state, Meeting, Attendee, Email, inform, SweetAlert, $analytics) ->
  $scope.formSubmitted = false
  $scope.meeting = {}
  $scope.meeting.attendees = []
  $scope.meeting.details = {}
  $scope.meeting.details.duration = 60
  $scope.meeting.calendar_hours = {}
  $scope.meeting.timeSelection = null
  $scope.meeting.schedule = [
      day_code: 'm',
      morning: true,
      afternoon: true,
      evening: true
    ,
      day_code: 't',
      morning: true,
      afternoon: true,
      evening: true
    ,
      day_code: 'w',
      morning: true,
      afternoon: true,
      evening: true
    ,
      day_code: 'th',
      morning: true,
      afternoon: true,
      evening: true
    ,
      day_code: 'f',
      morning: true,
      afternoon: true,
      evening: true
  ]

  Meeting.meeting.create().$promise.then (res) ->
    $scope.meeting.id = res.meeting_id
    $scope.meeting.schedule = res.schedule
    for key, time of res.calendar_hours
      if time > 12
        time = time - 12
      $scope.meeting.calendar_hours[key] = time
  .catch (err) ->
    console.error err
    $analytics.eventTrack('Failed Create Meeting')
    inform.add("Unable to create meeting", {type: "danger"})

  $scope.allAttendeesRegistered = ->
    for attendee in $scope.meeting.attendees
      if !attendee.isTandemUser
        return false
    return true

  $scope.addAttendee = ->
    duplicate = $scope.meeting.attendees.some (elem) ->
      elem.email == $scope.newEmail

    if $scope.newEmail and not duplicate
      emailToAdd =
        email: $scope.newEmail

      Meeting.attendee.add({id:$scope.meeting.id}, emailToAdd)
      .$promise.then (res) ->
        $analytics.eventTrack('Successfully Added Attendee')
        isTandemUser = false
        name = ''

        for attendee in res.tandem_users
          if attendee.email == $scope.newEmail
            name = attendee.name
            isTandemUser = true

        newAttendee =
          name: name,
          email: $scope.newEmail,
          isTandemUser: isTandemUser
        $scope.meeting.attendees.push newAttendee
        $scope.meeting.schedule = res.schedule
        $scope.meeting.timeSelection = null

        $scope.newEmail = ''
      .catch (err) ->
        console.error err
        $analytics.eventTrack('Failed Add Attendee')
        inform.add("Unable to add email address", {type: "danger"})

  $scope.deleteAttendee = (index) ->

    SweetAlert.swal {
      title: "Are you sure?"
      text: "This will remove this person from your meeting"
      type: "warning"
      showCancelButton: true
      confirmButtonColor: "rgba(217, 83, 79, 0.7)"
      confirmButtonText: "Remove "+$scope.meeting.attendees[index].email
      closeOnConfirm: true
    }, (confirm)->
      if confirm
        $analytics.eventTrack('Confirm Delete Attendee')
        emailToDelete =
          email: $scope.meeting.attendees[index].email

        Meeting.attendee.remove({id: $scope.meeting.id}, emailToDelete)
        .$promise.then (res) ->
          $scope.meeting.attendees.splice(index, 1)
          $scope.meeting.schedule = res.schedule
          $scope.meeting.timeSelection = null

        .catch (err) ->
          console.error err
          $analytics.eventTrack('Error deleting Attendee')
          inform.add("Unable to remove email address", {type: "danger"})
      else
        $analytics.eventTrack('Cancel Delete Attendee')

  $scope.setMeetingLength = (length_in_min) ->
    $scope.meeting.length_in_min = length_in_min
    Meeting.meeting.update($scope.meeting).$promise.then (res)->
      $scope.meeting.schedule = res.schedule
      $scope.meeting.timeSelection = null
    .catch (err) ->
      console.error err
      $analytics.eventTrack('Error Updating Meeting Length')
      inform.add("Unable to update meeting length", {type: "danger"})

  $scope.selectTime = (time) ->
    $scope.meeting.timeSelection = time

  $scope.submitMeeting = ->
    $scope.formSubmitted = true
    validateMeetingForm = (meeting) ->
      validDetails = true
      for detail of meeting.details
        if detail.length == 0
          validDetails = false

      if !validDetails
        false
      else if meeting.attendees.length == 0
        false
      else if !$scope.meeting.timeSelection
        false
      else if !$scope.meeting.length_in_min
        false
      else
        true

    getDetails = ->
      details =
        what: document.getElementById("what").value
        location: document.getElementById("location").value
      $scope.meeting.details = details

    getDetails()

    if validateMeetingForm($scope.meeting)
      console.log $scope.meeting
      Meeting.meeting.update($scope.meeting).$promise.then ->
        Meeting.meeting.send({
          id: $scope.meeting.id
          meeting_summary: $scope.meeting.details.what
          meeting_location: $scope.meeting.details.location
          meeting_time_selection: $scope.meeting.timeSelection
          meeting_length: $scope.meeting.length_in_min
        }).$promise.then (event) ->
          $analytics.eventTrack('Successfully sent meeting')
          $state.go("success", {event: event})
        .catch (err) ->
          console.error err
          $analytics.eventTrack('Failed sending meeting')
      .catch (err) ->
        console.error err
        $analytics.eventTrack('Failed Updating meeting')
    else
      $analytics.eventTrack('Form Invalidation Message')
      inform.add("You need to fill out all of the fields before your meeting \
                  can be scheduled.", {type: "danger"})
      console.log 'Form validation failed'
