#Halfsies
## Indent Based HTML Without Closing Tags

Halfsies turns this

```
<div>Hi
  <h1>Ba
  <p>
     Line one is a really long line
     Line two makes an <b>important point
```

into this
```html
<div>Hi
  <h1>Ba</h1>
  <p>
     Line one is a really long line
     Line two makes an <b>important point</b>
  </p>
</div>
```

### Installation
```bower install halfsies```
Then link/include `bower_components/halfsies/app/js/halfsies.js` in the directory.

Halfsies is currently configured as an angular module, though I hope to make it independent of angular at some point. That means you can only use it with angular and you need to include it as an angular module in addition to loading it.

```javascript
angular.module('App', ['halfsies'])
```
