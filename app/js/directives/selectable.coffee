'use strict'

###*
# @ngdoc directive
# @name tandemApp.directive:selectable
# @description
# # login
# Directive for selectable elements.
###
angular.module 'tandemApp'

.directive 'selectable', (SweetAlert)->
  TOGGLE_CLASS = 'selected'
  items = []

#  restrict: 'A'


  addElement = (elem) ->
    if items.indexOf(elem) == -1
      items.push(elem)

  rmElement = (elem) ->
    idx = items.indexOf(elem)
    if idx != -1
      items.splice idx, 1

  buildTimesHtml = (scope) ->
    html = "<div class='times'>"
    angular.forEach scope.data, (time) ->
      html += "<a class='sweet-alert-button'"
      html += 'onclick=\'$("#current-selection").removeData();'
      html += '$("#current-selection").attr("data-start", "' + time.start + '");'
      html += '$("#current-selection").attr("data-end", "' + time.end + '");'
      html += '$(".confirm").trigger("click")\' >'
      html += formatDate(time.start)
      html += "</a>"
    html += "</div>"

  formatDate = (dateString) ->
    date = new Date(dateString)
    hours = date.getHours()
    am_pm = determineAmOrPm(hours)
    hours = convertFromMilitary(hours)
    hours = addZero(hours)
    mins = addZero(date.getMinutes())
    return  hours + ":" + mins + " " + am_pm

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

  toggleActive = (elem, scope) ->
    if elem.hasClass TOGGLE_CLASS
      scope.callback null
      elem.removeClass TOGGLE_CLASS

    else if !elem.hasClass 'unavailable'
      # Comment to allow selecting multiple times
      SweetAlert.swal {
        title: "What time?"
        html: true
        text: buildTimesHtml(scope)
        type: ""
        showCancelButton: true
        showConfirmButton: false
        closeOnConfirm: true
      }, (confirm) ->
        if confirm
          selection =
            start: $('#current-selection').data("start")
            end:$('#current-selection').data("end")
          scope.callback selection
          angular.forEach items, (el) ->
            el.removeClass TOGGLE_CLASS
          elem.addClass TOGGLE_CLASS



  selectLink = (scope, elem) ->
    onClick = ->
      toggleActive elem, scope

    onDestroy = ->
      rmElement elem

    addElement elem
    elem.on 'click', onClick
    scope.$on '$destroy', onDestroy

  return {
    scope:
      data: "="
      callback: "="

    link: selectLink
  }