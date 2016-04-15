'use strict'

angular.module 'tandemApp', [
  'ui.router'
  'ngResource'
  'ngAnimate'
  'ui.bootstrap'
  'satellizer'
  'oitozero.ngSweetAlert'
  'inform'
  'inform-exception'
  'inform-http-exception'
  'angular-jwt'
  'angulartics'
  'angulartics.mixpanel'
]

.config ($stateProvider, $urlRouterProvider) ->
  skipIfLoggedIn = ($q, $auth, $location) ->
    deferred = $q.defer()
    if ($auth.isAuthenticated())
      $location.path('/create-meeting')
    else
      deferred.resolve()
    return deferred.promise

  loginRequired = ($q, $auth, $location) ->
    deferred = $q.defer()
    if ($auth.isAuthenticated())
      deferred.resolve()
    else
      $location.path('/login')
    return deferred.promise

  $stateProvider
    .state "home",
      url: "/"
      templateUrl: "./views/login.html",
      controller: "LoginController"
      resolve:
        skipIfLoggedIn: skipIfLoggedIn
    .state "meeting",
      url: '/create-meeting'
      templateUrl: "./views/make-meeting.html",
      controller: "MeetingController"
      resolve:
        loginRequired: loginRequired
    .state "success",
      url: "/success"
      templateUrl: "./views/success.html",
      controller: ""
      resolve:
        loginRequired: loginRequired
    .state "logout",
      url: "/logout"
      template: "",
      controller: "LogoutController"

  $urlRouterProvider.otherwise '/'


.config ($locationProvider) ->
  # Enable pretty urls (without '/#')
  $locationProvider.html5Mode(true)

.config ($analyticsProvider) ->
  $analyticsProvider.firstPageview(true)
  $analyticsProvider.withAutoBase(true)

.config ($authProvider, apiUrl, googleConfig) ->
  # Satelizer Settings
  $authProvider.storageType = 'localStorage'

  # Auth Providers
  $authProvider.google
    url: apiUrl + "user/login"
    optionalUrlParams: ['access_type']
    accessType: "offline"
    scope: [
      'profile'
      'email'
      'https://www.googleapis.com/auth/calendar'
    ]
    clientId: googleConfig.clientId


