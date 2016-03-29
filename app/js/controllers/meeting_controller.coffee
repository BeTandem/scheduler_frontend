'use strict'

angular.module 'tandemApp'

.controller 'MeetingController',
($scope, $location, Meeting, Attendee, Email, inform, SweetAlert, $analytics) ->
  $scope.meeting = {}
  $scope.meeting.attendees = []
  $scope.meeting.details = {}
  $scope.meeting.details.duration = 60
  $scope.meeting.calendar_hours = {}
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

  Meeting.addMeeting().$promise.then (res) ->
    $scope.meeting.id = res.meeting_id
    $scope.meeting.schedule = res.schedule

    for key, time of res.calendar_hours
      if time > 12
        time = time - 12
      $scope.meeting.calendar_hours[key] = time

  $scope.allAttendeesRegistered = ->
    for attendee in $scope.meeting.attendees
      if !attendee.isTandemUser
        return false
    return true

  $scope.addAttendee = ->
    duplicate = $scope.meeting.attendees.some (elem) ->
      elem.email == $scope.newEmail

    if $scope.newEmail and not duplicate
      email =
        meeting_id: $scope.meeting.id,
        email: $scope.newEmail

      Attendee.addAttendee(email).$promise.then (res) ->
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

        $scope.newEmail = ''
      .catch ->
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
        delObject =
          meeting_id: $scope.meeting.id
          email: $scope.meeting.attendees[index].email

        Attendee.deleteAttendee(delObject).$promise.then (res) ->
          $scope.meeting.attendees.splice(index, 1)
          $scope.meeting.schedule = res.schedule

        .catch ->
          console.log 'err'
          $analytics.eventTrack('Error deleting Attendee')
          inform.add("Unable to remove email address", {type: "danger"})
      else
        $analytics.eventTrack('Cancel Delete Attendee')

  $scope.setMeetingLength = (length_in_min) ->
    $scope.meeting.length_in_min = length_in_min
    Meeting.updateMeeting($scope.meeting).$promise.then (res)->
      $scope.meeting.schedule = res.schedule
      console.log 'Meeting Length Updated!'
    .catch ->
      $analytics.eventTrack('Error Updating Meeting Length')
      inform.add("Unable to update meeting length", {type: "danger"})

  $scope.submitMeeting = ->
    validateMeetingForm = (meeting) ->
      validDetails = true
      for detail of meeting.details
        if detail.length == 0
          validDetails = false

      if !validDetails
        false
      else if meeting.attendees.length == 0
        false
      else if meeting.timeSelections.length == 0
        false
      else if !$scope.meeting.length_in_min
        false
      else
        true

    getDetails = ->
      details =
        what: document.getElementById("what").value
        location: document.getElementById("location").value
        duration: document.getElementById("duration").value
      $scope.meeting.details = details

    getTimeSelection = ->
      times = []
      for selection in document.getElementsByClassName("selected")
        time_selection = selection.id.split(".")
        for day in $scope.meeting.schedule
          if day['day_code'] == time_selection[0]
            times.push slot for slot in day[time_selection[1]]
      $scope.meeting.timeSelections = times

    getDetails()
    getTimeSelection()

    if validateMeetingForm($scope.meeting)
      console.log $scope.meeting
      Meeting.updateMeeting($scope.meeting).$promise.then ->
        Email.sendMeetingInvite({
          meeting_id: $scope.meeting.id
          meeting_summary: $scope.meeting.details.what
          meeting_location: $scope.meeting.details.location
          meeting_time_selection: $scope.meeting.timeSelections
          meeting_length: $scope.meeting.length_in_min
        })
        console.log 'Meeting submitted'
        $location.path('/success')
      .catch ->
        console.log 'Submission error'
    else
      $analytics.eventTrack('Form Invalidation Message')
      inform.add("You need to fill out all of the fields before your meeting \
                  can be scheduled.", {type: "danger"})
      console.log 'Form validation failed'
