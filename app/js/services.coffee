services = angular.module('myApp.services', [])

services.factory 'deepCopyJSON', ->
  (obj) ->
    JSON.parse JSON.stringify obj

services.factory 'protect', ->
  (fn) ->
    ->
      argCopies = _(arguments).map (arg) ->
        deepCopyJSON arg
      fn.apply {}, argCopies

services.factory 'newRegex', ->
  (args...) ->
    regex = ""
    for arg in args
      if arg instanceof RegExp
        regex += arg.toString()[1..-2]
      else
        regex += arg
    new RegExp regex


services.factory 'matcher', ->
  (string, regex) ->
    buffer = []
    match = string.match regex
    if match
      {
        before: string.slice(0, match.index)
        match: string[match.index..match.index + match[0].length - 1]
        after: string[match.index + match[0].length..] || ""
      }
    else
      false

services.factory "matchAll", ['matcher', (matcher) ->
  (string, regex) ->
    buffer = []
    while matcher string, regex
      {before, match, after} = matcher string, regex
      buffer = buffer.concat [
        {contents: before}
        {match: true, contents: match}
      ]
      string = after
    buffer.push {
      type: 'rest'
      contents: string
    }
    buffer
]

services.factory 'parseNextTag', [ 'matcher', 'parseQuotes', (matcher, parseQuotes)->
  (string) ->
    unless {before, match, after} = matcher string, /\</
      return false
    beforeTag = before
    tag = match
    afterTag = ""
    tokens = parseQuotes after
    for token, i in tokens
      if token.type is 'text' and token.contents.match /\>/
        {match, before, after} = matcher token.contents, /\>/
        tag += before + match
        afterTag += after
        break
      else
        tag += token.contents
    afterTag += _(tokens[i + 1..]).pluck('contents').join('')
    {
      before: beforeTag
      tag: tag
      after: afterTag
    }
]

services.factory 'parseTags', ['parseNextTag', (parseNextTag) ->
  parseTags = (text) ->
    if {before, after, tag} = parseNextTag text
      [
        {
          type: 'text'
          contents: before
        }
        {
          type: 'tag'
          contents: tag
        }
      ].concat parseTags after
    else
      [
        {
          type: 'text'
          contents: text
        }
      ]
  (text) ->
    parseTags text
]

services.factory 'parseNextQuote', ['matcher', (matcher) ->
  (string) ->
    {before, match, after} = matcher string, /"|'/
    matchChar = match
    textBeforeQuote = before
    if match
      {before, after} = matcher after, new RegExp match
      {
        quote: matchChar + before + matchChar
        before: textBeforeQuote
        after: after
      }
    else
      false
]

services.factory 'parseQuotes', ['parseNextQuote', (parseNextQuote) ->
  parseQuotes = (string) ->
    {before, quote, after} = parseNextQuote string
    unless before
      [
        {
          type: 'text'
          contents: string
        }
      ]
    else
      [
        {
          type: 'text'
          contents: before
        }
        {
          type: 'quote'
          contents: quote
        }
      ].concat parseQuotes after

  (string) ->
    parseQuotes string
]

services.factory 'isCloseTag', ->
  (tagString) ->
    tagString.match(/^\<\//) isnt null

services.factory "tagContents", ['isCloseTag', (isCloseTag) ->
  (tagString) ->
    if isCloseTag tagString
      tagString[2..tagString.length - 2]
    else
      tagString[1..tagString.length - 2]
]

services.factory "tagType", ['tagContents', (tagContents) ->
  (tagString) ->
    contents = tagContents tagString
    contents.split(" ")[0]
]

services.factory 'processTags', ['tagType', 'isCloseTag',
  (tagType, isCloseTag) ->
    (tokens) ->
      for token in tokens
        if token.type == 'tag'
          token.tag = tagType token.contents
          if isCloseTag token.contents
            token.close = true
      tokens
]

services.factory "insertNewlines", ['matchAll',(matchAll) ->
  (tokens) ->
    res = _.map tokens, (token) ->
      if token.type is 'text'
        newTokens = matchAll token.contents, /\n/
        _.map newTokens, (newToken) ->
          if newToken.match
            type: 'newline'
            contents: '\n'
          else
            type: 'text'
            contents: newToken.contents
      else
        token
    _.flatten res
]

services.factory "groupByLines" , ['deepCopyJSON', (deepCopyJSON) ->
  (tokens) ->
    tokens = deepCopyJSON tokens
    lines = []
    currentLine = []
    while token = tokens.shift()
      if token.type is 'newline'
        lines.push currentLine
        currentLine = []
      else
        currentLine.push token
    lines.push currentLine
    lines
]

services.factory 'spacesToIndent', ->
  (num) ->
    parseInt num / 2

services.factory 'indents', [ 'spacesToIndent', (spacesToIndent) ->
  (text) ->
    numSpaces = text.match(/^ */)[0].length
    spacesToIndent numSpaces
]

services.factory 'indentLine', ['deepCopyJSON','indents', (deepCopy, indents) ->
  (line) ->
    firstToken = line[0]
    if firstToken.type isnt 'text'
      line.indent = 0
    else # first token is type text
      line.indent = indents firstToken.contents
      firstToken.contents = _.string.lstrip firstToken.contents
    line
]

services.factory "indentLines", ['indentLines', (line) ->
  (lines) ->
    lines.map (line) indentLine line
]

###
#   groupByIndent tranform lines with indent and token properties
#   into nodes with children. Each node has properties:
#   line: the nodes line
#   children: the nodes children
###
#services.factory 'groupByIndent', ['deepCopyJSON', (deepCopyJSON) ->
  #transform = (lines, level, current) ->
    #current.children = [] unless current.children
    #while lines[0]
      #if lines[0].indent == level
        #line = lines.shift()
        #line.children = []
        #current.children.push line
      #else if lines[0].indent > level
        #transform(lines, lines[0].indent, line)
      #else
        #return
    #current

  #transform = (rest, level) ->
    #while lines[0]
  #(lines) ->
    #aboveTop = []
    #aboveTop.indent = -1
    #transform(lines, 0, aboveTop)
#]
#
services.factory 'groupByIndent', ['deepCopyJSON', (deepCopyJSON) ->
  transform = (lines, level, current) ->
    current.children = [] unless current.children
    while lines[0]
      if lines[0].indent == level
        line = lines.shift()
        line.children = []
        current.children.push line
      else if lines[0].indent > level
        transform(lines, lines[0].indent, line)
      else
        return
    current

  transform = (rest, level) ->
    copy = (line for line in rest)
    res = []
    while copy[0]
      if copy[0].indent == level
        current = copy.shift()
        res.push current
      else if copy[0].indent > level
        nested = []
        while copy[0] and copy[0].indent > level
          nested.push copy.shift()
        current.children = transform nested, level + 1
      else
        return
    res

  (lines) ->
    transform(lines, 0)
]

services.factory 'openTags', ->
  fn =
    (line) ->
      openTags = []
      for token in line
        if token.type == 'tag'
          unless token.close
            openTags.push token.tag
          else
            expected = _(openTags).last()
            if expected is token.tag
              openTags.pop()
            else
              throw new fn.UnmatchedTagError expected, token.tag
      openTags

  class fn.UnmatchedTagError
    constructor: (@expected, @found) ->
    toString: ->
      "Found #{@found} but was expecting #{@expected}"

  fn

services.factory 'processLines', ['openTags', (openTags) ->
  (lines) ->
    for line in lines
      line.openTags = openTags line
    lines
]

services.factory 'render', ->
  indent = (indentLevel) ->
    numSpaces = indentLevel * 2 # this should probably be connected to spaceToIndent in a configuration file
    _.str.repeat(" ", numSpaces)

  closeTag = (tagName) ->
    "</#{tagName}>"
  renderLine = (line) ->
    html =_(line).pluck('contents').join('')

    if line.children
      html += '\n'
      html += renderLines line.children

    closingTags = _(line.openTags).chain()
      .reverse()
      .map(closeTag)
      .value()
      .join('')

    if line.children and closingTags isnt ''
      html += '\n' + indent(line.indent)
    html += closingTags
    html

  renderLines = (lines) ->
    html = ""
    for line in lines
      html += indent line.indent
      html += renderLine line
      html += '\n' unless line is _.last lines
    html

  (arg) ->
    if (arg[0].contents)
      line = arg
      renderLine line
    else
      lines = arg
      renderLines lines

services.factory 'compile', [
  'parseTags'
  'insertNewlines'
  'processTags'
  'groupByLines'
  'processLines'
  'indentLine'
  'groupByIndent'
  'render'
, (
  parseTags
  insertNewlines
  processTags
  groupByLines
  processLines
  indentLine
  groupByIndent
  render
)  ->
  (text) ->
    tokens = parseTags text
    tokens = insertNewlines tokens
    tokens = processTags tokens
    lines  = groupByLines tokens
    lines  = processLines lines
    lines  = _(lines).map indentLine
    topLines = groupByIndent lines
    html = render topLines
]
