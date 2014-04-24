'use strict';

angular.module("myApp.controllers", [])
.controller("Halfsies", [
  "$scope", "halfsies", '$sce', function($scope, halfsies, $sce) {
    $scope.html = function() {
      return $sce.trustAsHtml(halfsies($scope.half))
    }
  }
]);


// Declare app level module which depends on filters, and services
angular.module('myApp', [
  'myApp.controllers',
  'halfsies'
]);
