angular.module('myApp.filters', []).
  filter('appendHey', [ ->
    (text) ->
      text + '  heyy'
  ])
