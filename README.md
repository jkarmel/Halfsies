#Halfsies
## Indent Based HTML Without Closing Tags

#### (Write Half As Many Tags)

Halfsies turns this

```HTML
<div>Hi
  <h1>Ba
  <p>
     Line one is a really long line
     Line two makes an <b>important point
```

into this
```HTML
<div>Hi
  <h1>Ba</h1>
  <p>
     Line one is a really long line
     Line two makes an <b>important point</b>
  </p>
</div>
```

### Installation
#### Inlude haflsies.js
##### For bower users:

`bower install halfsies`

Then link/include `bower_components/halfsies/app/js/halfsies.js` in the directory.

##### For everyone else:

[Download Halfsies](https://raw.githubusercontent.com/jkarmel/Halfsies/master/app/js/halfsies.js)

And link/include it in your project.

#### Load Angular Module

Halfsies is currently configured as an angular module, though I hope to make it independent of angular at some point. That means you can only use it with angular and you need to include it as an angular module in addition to loading it.

```javascript
angular.module('App', ['halfsies'])
```

### Usage
The halfsies services is simply a function that takes in a string of halfsies templates and returns the corresponding html.

This is how it would work in a controller.

```javascript
function AppController ($scope, halfsies) {
  $scope.renderHalfsiesTemplate = function (templateString) {
    return halfsies(templateString)
  }
}
```
