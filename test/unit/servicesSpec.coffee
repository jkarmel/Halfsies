describe "service", ->
  beforeEach ->
    module "myApp.services"

  describe 'ulilities', ->
    describe 'deepCopyJSON', ->
      it 'should deep copy objects, copying values not references',
        inject (deepCopyJSON) ->
          obj = {
            sub:
              key: 'val'
          }
          copy = deepCopyJSON(obj)
          expect(copy.sub.key).toBe 'val'
          expect(copy.sub == obj.sub).not.toBeTruthy()
          expect(copy == obj).not.toBeTruthy()

    describe "newRegex", ->
      it "should create a new regex by combining strings",
        inject (newRegex) ->
          expect("face".match (newRegex "fa", "ce")).toContain 'face'
      it "should create a new regex by combining strings and regexes",
        inject (newRegex) ->
          expect("face".match (newRegex "fa", /ce/ )).toContain 'face'

    describe 'matchers', ->
      describe 'matcher', ->
        it "should split the contents into before after and match tokens",
          inject (matcher) ->
            string = "facebook is not a real book"
            {before, match, after} = matcher string, /book/
            expect(before).toBe string[0..3]
            expect(match).toBe 'book'
            expect(before + match + after).toBe string

        it 'should return false if there is no match in the string',
          inject (matcher) ->
            expect(matcher 'no match here', /dont/).toBe false

      describe 'matchAll', ->
        it 'should spilt a string into match tokens and no match tokens',
          inject (matchAll) ->
            string = "facebook is not a real book"
            all = matchAll(string, /book/)
            expect(_.pluck(all, 'contents').join("")).toBe string
            string = "\n    b\n  "
            all = matchAll(string, /\n/)
            expect(_.pluck(all, 'contents').join("")).toBe string

  describe 'Parsing', ->
    describe 'Quote', ->
      beforeQuotes = 'before quotes'
      firstQuote = '"first quote"'
      betweenQuotes = 'between quotes'
      secondQuote = "'second quote'"
      afterQuotes = 'after quotes'
      stringWithTwoQuotes =
          beforeQuotes + firstQuote + betweenQuotes + secondQuote + afterQuotes
      stringWithoutQuotes = 'no quotes'

      describe 'parseNextQuote', ->
        it """should find the next piece of text in quotes,
          and the text that came before and after""" ,
          inject (parseNextQuote) ->
            {quote, before, after} = parseNextQuote stringWithTwoQuotes
            expect(quote).toBe firstQuote
            expect(before).toBe beforeQuotes
            expect(after).toBe betweenQuotes + secondQuote + afterQuotes
            expect(before + quote + after).toBe stringWithTwoQuotes
        it 'should return false if there are not quotes in the text string',
          inject (parseNextQuote) ->
            {quote, before, after} = parseNextQuote stringWithoutQuotes
            expect(before).toBe undefined
            expect(quote).toBe undefined
            expect(after).toBe undefined

      describe 'parseQuotes', ->
        it 'should split text into text and quoted tokens',
          inject (parseQuotes) ->
            tokens = parseQuotes stringWithTwoQuotes
            expect(tokens[0].type).toBe 'text'
            expect(tokens[0].contents).toBe beforeQuotes
            expect(tokens[1].type).toBe 'quote'
            expect(tokens[1].contents).toBe firstQuote
            expect(tokens[2].type).toBe 'text'
            expect(tokens[2].contents).toBe betweenQuotes
            expect(tokens[3].type).toBe 'quote'
            expect(tokens[3].contents).toBe secondQuote
            expect(tokens[4].type).toBe 'text'
            expect(tokens[4].contents).toBe afterQuotes
            expect(_(tokens).pluck('contents').join("")).toBe stringWithTwoQuotes

    describe 'Tag', ->
      beforeTags = "before tags"
      firstTag = "<a tag>"
      betweenTags = "between tags"
      tagWithQuotedGreaterThan = '<a tag="with > in the quotes">'
      secondTag = tagWithQuotedGreaterThan
      afterTags = "after tags"
      textWithTags = beforeTags + firstTag + betweenTags + secondTag + afterTags
      afterFirstTag = betweenTags + secondTag + afterTags

      textWithoutTags = "no tags here!"
      describe 'parseNextTag', ->
        it 'should return the the contents of the next tag',
          inject (parseNextTag) ->
            {before, tag, after} = parseNextTag textWithTags
            expect(before).toBe beforeTags
            expect(tag).toBe firstTag
            expect(after).toBe afterFirstTag
            # deal with 'a <p attr="greater than sign > inside quote">
            textWithTagWithQuotedGreaterThan = beforeTags + tagWithQuotedGreaterThan + afterTags
            {before, tag, after} = parseNextTag textWithTagWithQuotedGreaterThan
            expect(tag).toBe tagWithQuotedGreaterThan
            expect(before).toBe beforeTags
            expect(after).toBe afterTags
            expect(before + tag + after).toBe textWithTagWithQuotedGreaterThan

        it 'should return false if text has no tags', inject (parseNextTag) ->
          expect(parseNextTag textWithoutTags).toBe false

      describe 'parseTags', ->
        it 'should return an array with a single text token if passed text without tags',
          inject (parseTags) ->
            tokens = parseTags textWithoutTags
            expect(tokens.length).toBe 1
            expect(tokens[0].type).toBe 'text'
            expect(tokens[0].contents).toBe textWithoutTags

        it 'should tokenize a textWithTags into tag and non tag tokens',
          inject (parseTags) ->
            tokens = parseTags textWithTags
            $tags = _(tokens).where {type: 'tag'}
            expect($tags[0].contents).toBe firstTag
            expect($tags[1].contents).toBe secondTag
            expect(_(tokens).pluck('contents').join("")).toBe textWithTags

  describe 'transform pipeline', ->
    openTagType = 'h1'
    openTagContents = "#{openTagType} attr='val'"
    open =  "<#{openTagContents}>"
    closeTagType = 'a'
    closeTagContents = "#{closeTagType} attr2='val2'"
    close = "</#{closeTagContents}>"

    $token = (type, contents) ->
      {type, contents}
    $newline = ->
      $token 'newline', '\n'

    $text = (text) ->
      $token 'text', text

    $tag = (tagName, close) ->
      token = $token 'tag'
      token.tag = tagName
      token.contents = (if close then "</" else "<") + "#{tagName}>"
      token.close = true if close
      token


    $line = (indent, tokens...) ->
      tokens = tokens[0] if tokens[0].contents is undefined
      line = tokens
      line.indent = indent
      line

    describe 'tag helpers', ->

      describe 'closeTag', ->
        it 'should return true if tag is a closing tag', inject (isCloseTag) ->
          expect(isCloseTag close).toBe true
        it 'should return true if tag is a closing tag', inject (isCloseTag) ->
          expect(isCloseTag open).toBe false

      describe 'tagContents', ->
        it 'should return text between the tag open and tag close', inject (tagContents) ->
          expect(tagContents open).toBe openTagContents
          expect(tagContents close).toBe closeTagContents

      describe 'tagType', ->
        it 'should return the type of the tag', inject (tagType) ->
          expect(tagType open).toBe openTagType
          expect(tagType close).toBe closeTagType

    describe 'processTags', ->
      it 'should add a tag property to all tag tokens', inject (processTags) ->
        tokens = processTags [
          $token 'tag', open
          $token 'tag', close
        ]
        expect(tokens[0].tag).toBe openTagType
        expect(tokens[1].tag).toBe closeTagType

      it 'should add a close proptery to tag that should be closed', inject (processTags) ->
        tokens = processTags [
          $token 'tag', open
          $token 'tag', close
        ]
        expect(tokens[0].close).toBe undefined
        expect(tokens[1].close).toBe true


    describe 'insertNewlines', ->
      it 'should split up text nodes into text and newline nodes',
        inject (insertNewlines) ->
          tokens = insertNewlines [
            $text """
            before newline
            after newline
            """
          ]
          expect(tokens.length).toBe 3
          expect(tokens[0].contents).toBe 'before newline'
          expect(tokens[0].type).toBe 'text'
          expect(tokens[1].contents).toBe '\n'
          expect(tokens[1].type).toBe 'newline'
          expect(tokens[2].contents).toBe 'after newline'
          expect(tokens[2].type).toBe 'text'

    describe 'groupByLines', ->
      it 'should group tokens into lines', inject (groupByLines) ->
        tokens = [ ]
        lines = groupByLines tokens
        expect(lines.length).toBe 1
        tokens = [
          $text 'text on line 1'
        ]
        lines = groupByLines tokens
        expect(lines.length).toBe 1
        expect(lines[0][0].contents).toBe tokens[0].contents
        tokens = [
          $text 'text on line 1'
          $newline()
          $text 'text on line 2'
        ]
        lines = groupByLines tokens
        expect(lines.length).toBe 2
        tokens = [
          $text 'text on line 1'
          $newline()
          $newline()
          $text 'text on line 2'
          $newline()
        ]
        lines = groupByLines tokens
        expect(lines.length).toBe 4

    describe 'processLines', ->
      it 'should add an openTags property to the line objects with the open tags',
        inject (processLines) ->
          lines = [
            [
              $tag 'h1'
              $text 'some text'
              $tag 'h2'
              $tag 'h2', 'close'
            ]
          ]
          expect(processLines(lines)[0].openTags[0]).toBe 'h1'


    describe 'indent', ->
      describe 'indentLine', ->
        it 'returns 0 if the line starts with anything but a text token', inject (indentLine) ->
          line = [$token 'tag', '<a tag>']
          expect(indentLine(line).indent).toBe 0
        it 'return the line indent', inject (indentLine) ->
          line = [$text '  a 2 space indent']
          indentedLine = indentLine(line)
          expect(indentedLine.indent).toBe 1
          expect(indentedLine[0].contents).toBe 'a 2 space indent'
          line = [$text '    ']
          expect(indentLine(line).indent).toBe 2

      describe 'groupByIndent', ->
        it 'should group tokens by indent level', inject (groupByIndent) ->
          lines = [
            $line 0, $text 'grandpa'
            $line 1, $text 'old maid'
            $line 1, $text 'dad'
            $line 2, $text 'only child'
            $line 1, $text 'aunt'
            $line 2, $text 'cousin 1'
            $line 2, $text 'cousin 2'
          ]
          topLines = groupByIndent lines
          expect(topLines.length).toBe 1
          grandpa = topLines[0]
          expect(grandpa[0].contents).toBe 'grandpa'
          expect(grandpa.children.length).toBe 3
          oldMaid = grandpa.children[0]
          dad     = grandpa.children[1]
          aunt    = grandpa.children[2]

          expect(oldMaid[0].contents).toBe 'old maid'
          expect(dad[0].contents).toBe 'dad'
          expect(aunt[0].contents).toBe 'aunt'

          expect(oldMaid.children).toBe undefined
          expect(dad.children.length).toBe 1
          expect(dad.children[0][0].contents).toBe 'only child'

          expect(aunt.children.length).toBe 2
          expect(aunt.children[0][0].contents).toBe 'cousin 1'
          expect(aunt.children[1][0].contents).toBe 'cousin 2'

      describe 'flatten', ->
        describe 'openTags', ->
        it 'should should find all the open tags on a line', inject (openTags) ->
          line =  [ $tag 'h1' ]
          expect(openTags(line)[0]).toBe 'h1'
          line = [
            $tag 'h1'
            $tag 'h2'
          ]
          expect(_(openTags(line)).contains('h1')).toBe true
          expect(_(openTags(line)).contains('h2')).toBe true
          line = [
            $tag 'h1'
            $tag 'h2'
            $tag 'h2', 'close'
          ]
          expect(_(openTags(line)).contains('h1')).toBe true
          expect(_(openTags(line)).contains('h2')).toBe false
          line = [
            $tag 'h1'
            $tag 'h2'
            $tag 'h1', 'close'
          ]
          expect( ->
            openTags(line)
          ).toThrow( new openTags.UnmatchedTagError('h2', 'h1'))


      describe 'render', ->
        it 'should render a line with no children by appending closing tags to the line',
          inject (render) ->
            line = [
              $tag 'h1'
              $text 'some text'
            ]
            line.openTags = ['h1']
            expect(render(line)).toBe '<h1>some text</h1>'
            line = [
              $tag 'h1'
              $text 'after h1 before h2'
              $tag 'h2'
              $text 'after h2'
            ]
            line.openTags = ['h1', 'h2']
            expect(render(line)).toBe """
            <h1>after h1 before h2<h2>after h2</h2></h1>
            """

        it 'should render a line with children by appending closing
        tags after the child lines',
          inject (render) ->
            line = [
              $tag 'body'
              $tag 'div'
            ]
            line.indent = 0
            line.openTags = ['body', 'div']
            child1 = $line 1, [
              $tag 'h1'
              $text 'AWESOME PAGE HEADER'
              $tag 'h1', 'close'
            ]
            child1.openTags = []
            child2 = $line 1, [
              $tag 'p'
              $text 'sweet paragraph text'
            ]
            child2.openTags = ['p']
            line.children = [child1, child2]
            html = render line
            expect(html).toBe """
            <body><div>
              <h1>AWESOME PAGE HEADER</h1>
              <p>sweet paragraph text</p>
            </div></body>
            """

  describe 'compile', ->
    it 'should be awesome', inject (compile) ->
      html = compile """
      <body>
        <div>
          <h1>A HEADER
          <p> Two lines of text
            another two lines of text
      """
