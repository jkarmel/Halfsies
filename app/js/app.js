'use strict';

angular.module("myApp.controllers", [])
.controller("Halfsies", [
  "$scope", "compile", '$sce', function($scope, compile, $sce) {
    $scope.html = function() {
      return $sce.trustAsHtml(compile($scope.half))
    }
  }
]);


// Declare app level module which depends on filters, and services
angular.module('myApp', [
  'myApp.controllers',
  'myApp.services'
]);
