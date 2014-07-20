# anison.js [![Build Status](https://secure.travis-ci.org/hdemon/anison.js.png?branch=master)](http://travis-ci.org/hdemon/anison.js)

The scraper of anison.info

## Getting Started
Install the module with: `npm install anison`

## Documentation
_(Coming soon)_

## Examples
```javascript
var anison = require('anison');
anison.get("未確認で進行形").then(function(songs) {
  console.log(songs[0].title); // とまどい→レシピ
  console.log(songs[0].category); // OP
  console.log(songs[0].artists); // みかくにんぐッ!
  console.log(songs[0].composer); // Junky
})
```

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## License
Copyright (c) 2014 Masami Yonehara
Licensed under the MIT license.
