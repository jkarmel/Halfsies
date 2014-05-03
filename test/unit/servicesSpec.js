// Generated by CoffeeScript 1.6.2
(function() {
  var __slice = [].slice;

  describe("service", function() {
    beforeEach(function() {
      return module("myApp.services");
    });
    describe('ulilities', function() {
      describe('deepCopyJSON', function() {
        return it('should deep copy objects, copying values not references', inject(function(deepCopyJSON) {
          var copy, obj;

          obj = {
            sub: {
              key: 'val'
            }
          };
          copy = deepCopyJSON(obj);
          expect(copy.sub.key).toBe('val');
          expect(copy.sub === obj.sub).not.toBeTruthy();
          return expect(copy === obj).not.toBeTruthy();
        }));
      });
      describe("newRegex", function() {
        it("should create a new regex by combining strings", inject(function(newRegex) {
          return expect("face".match(newRegex("fa", "ce"))).toContain('face');
        }));
        return it("should create a new regex by combining strings and regexes", inject(function(newRegex) {
          return expect("face".match(newRegex("fa", /ce/))).toContain('face');
        }));
      });
      return describe('matchers', function() {
        describe('matcher', function() {
          it("should split the contents into before after and match tokens", inject(function(matcher) {
            var after, before, match, string, _ref;

            string = "facebook is not a real book";
            _ref = matcher(string, /book/), before = _ref.before, match = _ref.match, after = _ref.after;
            expect(before).toBe(string.slice(0, 4));
            expect(match).toBe('book');
            return expect(before + match + after).toBe(string);
          }));
          return it('should return false if there is no match in the string', inject(function(matcher) {
            return expect(matcher('no match here', /dont/)).toBe(false);
          }));
        });
        return describe('matchAll', function() {
          return it('should spilt a string into match tokens and no match tokens', inject(function(matchAll) {
            var all, string;

            string = "facebook is not a real book";
            all = matchAll(string, /book/);
            expect(_.pluck(all, 'contents').join("")).toBe(string);
            string = "\n    b\n  ";
            all = matchAll(string, /\n/);
            return expect(_.pluck(all, 'contents').join("")).toBe(string);
          }));
        });
      });
    });
    describe('Parsing', function() {
      describe('Quote', function() {
        var afterQuotes, beforeQuotes, betweenQuotes, firstQuote, secondQuote, stringWithTwoQuotes, stringWithoutQuotes;

        beforeQuotes = 'before quotes';
        firstQuote = '"first quote"';
        betweenQuotes = 'between quotes';
        secondQuote = "'second quote'";
        afterQuotes = 'after quotes';
        stringWithTwoQuotes = beforeQuotes + firstQuote + betweenQuotes + secondQuote + afterQuotes;
        stringWithoutQuotes = 'no quotes';
        describe('parseNextQuote', function() {
          it("should find the next piece of text in quotes,\nand the text that came before and after", inject(function(parseNextQuote) {
            var after, before, quote, _ref;

            _ref = parseNextQuote(stringWithTwoQuotes), quote = _ref.quote, before = _ref.before, after = _ref.after;
            expect(quote).toBe(firstQuote);
            expect(before).toBe(beforeQuotes);
            expect(after).toBe(betweenQuotes + secondQuote + afterQuotes);
            return expect(before + quote + after).toBe(stringWithTwoQuotes);
          }));
          return it('should return false if there are not quotes in the text string', inject(function(parseNextQuote) {
            var after, before, quote, _ref;

            _ref = parseNextQuote(stringWithoutQuotes), quote = _ref.quote, before = _ref.before, after = _ref.after;
            expect(before).toBe(void 0);
            expect(quote).toBe(void 0);
            return expect(after).toBe(void 0);
          }));
        });
        return describe('parseQuotes', function() {
          return it('should split text into text and quoted tokens', inject(function(parseQuotes) {
            var tokens;

            tokens = parseQuotes(stringWithTwoQuotes);
            expect(tokens[0].type).toBe('text');
            expect(tokens[0].contents).toBe(beforeQuotes);
            expect(tokens[1].type).toBe('quote');
            expect(tokens[1].contents).toBe(firstQuote);
            expect(tokens[2].type).toBe('text');
            expect(tokens[2].contents).toBe(betweenQuotes);
            expect(tokens[3].type).toBe('quote');
            expect(tokens[3].contents).toBe(secondQuote);
            expect(tokens[4].type).toBe('text');
            expect(tokens[4].contents).toBe(afterQuotes);
            return expect(_(tokens).pluck('contents').join("")).toBe(stringWithTwoQuotes);
          }));
        });
      });
      return describe('Tag', function() {
        var afterFirstTag, afterTags, beforeTags, betweenTags, firstTag, secondTag, tagWithQuotedGreaterThan, textWithTags, textWithoutTags;

        beforeTags = "before tags";
        firstTag = "<a tag>";
        betweenTags = "between tags";
        tagWithQuotedGreaterThan = '<a tag="with > in the quotes">';
        secondTag = tagWithQuotedGreaterThan;
        afterTags = "after tags";
        textWithTags = beforeTags + firstTag + betweenTags + secondTag + afterTags;
        afterFirstTag = betweenTags + secondTag + afterTags;
        textWithoutTags = "no tags here!";
        describe('parseNextTag', function() {
          it('should return the the contents of the next tag', inject(function(parseNextTag) {
            var after, before, tag, textWithTagWithQuotedGreaterThan, _ref, _ref1;

            _ref = parseNextTag(textWithTags), before = _ref.before, tag = _ref.tag, after = _ref.after;
            expect(before).toBe(beforeTags);
            expect(tag).toBe(firstTag);
            expect(after).toBe(afterFirstTag);
            textWithTagWithQuotedGreaterThan = beforeTags + tagWithQuotedGreaterThan + afterTags;
            _ref1 = parseNextTag(textWithTagWithQuotedGreaterThan), before = _ref1.before, tag = _ref1.tag, after = _ref1.after;
            expect(tag).toBe(tagWithQuotedGreaterThan);
            expect(before).toBe(beforeTags);
            expect(after).toBe(afterTags);
            return expect(before + tag + after).toBe(textWithTagWithQuotedGreaterThan);
          }));
          return it('should return false if text has no tags', inject(function(parseNextTag) {
            return expect(parseNextTag(textWithoutTags)).toBe(false);
          }));
        });
        return describe('parseTags', function() {
          it('should return an array with a single text token if passed text without tags', inject(function(parseTags) {
            var tokens;

            tokens = parseTags(textWithoutTags);
            expect(tokens.length).toBe(1);
            expect(tokens[0].type).toBe('text');
            return expect(tokens[0].contents).toBe(textWithoutTags);
          }));
          return it('should tokenize a textWithTags into tag and non tag tokens', inject(function(parseTags) {
            var $tags, tokens;

            tokens = parseTags(textWithTags);
            $tags = _(tokens).where({
              type: 'tag'
            });
            expect($tags[0].contents).toBe(firstTag);
            expect($tags[1].contents).toBe(secondTag);
            return expect(_(tokens).pluck('contents').join("")).toBe(textWithTags);
          }));
        });
      });
    });
    describe('transform pipeline', function() {
      var $line, $newline, $tag, $text, $token, close, closeTagContents, closeTagType, open, openTagContents, openTagType;

      openTagType = 'h1';
      openTagContents = "" + openTagType + " attr='val'";
      open = "<" + openTagContents + ">";
      closeTagType = 'a';
      closeTagContents = "" + closeTagType + " attr2='val2'";
      close = "</" + closeTagContents + ">";
      $token = function(type, contents) {
        return {
          type: type,
          contents: contents
        };
      };
      $newline = function() {
        return $token('newline', '\n');
      };
      $text = function(text) {
        return $token('text', text);
      };
      $tag = function(tagName, close) {
        var token;

        token = $token('tag');
        token.tag = tagName;
        token.contents = (close ? "</" : "<") + ("" + tagName + ">");
        if (close) {
          token.close = true;
        }
        return token;
      };
      $line = function() {
        var indent, line, tokens;

        indent = arguments[0], tokens = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        if (tokens[0].contents === void 0) {
          tokens = tokens[0];
        }
        line = tokens;
        line.indent = indent;
        return line;
      };
      describe('tag helpers', function() {
        describe('closeTag', function() {
          it('should return true if tag is a closing tag', inject(function(isCloseTag) {
            return expect(isCloseTag(close)).toBe(true);
          }));
          return it('should return true if tag is a closing tag', inject(function(isCloseTag) {
            return expect(isCloseTag(open)).toBe(false);
          }));
        });
        describe('tagContents', function() {
          return it('should return text between the tag open and tag close', inject(function(tagContents) {
            expect(tagContents(open)).toBe(openTagContents);
            return expect(tagContents(close)).toBe(closeTagContents);
          }));
        });
        return describe('tagType', function() {
          return it('should return the type of the tag', inject(function(tagType) {
            expect(tagType(open)).toBe(openTagType);
            return expect(tagType(close)).toBe(closeTagType);
          }));
        });
      });
      describe('processTags', function() {
        it('should add a tag property to all tag tokens', inject(function(processTags) {
          var tokens;

          tokens = processTags([$token('tag', open), $token('tag', close)]);
          expect(tokens[0].tag).toBe(openTagType);
          return expect(tokens[1].tag).toBe(closeTagType);
        }));
        return it('should add a close proptery to tag that should be closed', inject(function(processTags) {
          var tokens;

          tokens = processTags([$token('tag', open), $token('tag', close)]);
          expect(tokens[0].close).toBe(void 0);
          return expect(tokens[1].close).toBe(true);
        }));
      });
      describe('insertNewlines', function() {
        return it('should split up text nodes into text and newline nodes', inject(function(insertNewlines) {
          var tokens;

          tokens = insertNewlines([$text("before newline\nafter newline")]);
          expect(tokens.length).toBe(3);
          expect(tokens[0].contents).toBe('before newline');
          expect(tokens[0].type).toBe('text');
          expect(tokens[1].contents).toBe('\n');
          expect(tokens[1].type).toBe('newline');
          expect(tokens[2].contents).toBe('after newline');
          return expect(tokens[2].type).toBe('text');
        }));
      });
      describe('groupByLines', function() {
        return it('should group tokens into lines', inject(function(groupByLines) {
          var lines, tokens;

          tokens = [];
          lines = groupByLines(tokens);
          expect(lines.length).toBe(1);
          tokens = [$text('text on line 1')];
          lines = groupByLines(tokens);
          expect(lines.length).toBe(1);
          expect(lines[0][0].contents).toBe(tokens[0].contents);
          tokens = [$text('text on line 1'), $newline(), $text('text on line 2')];
          lines = groupByLines(tokens);
          expect(lines.length).toBe(2);
          tokens = [$text('text on line 1'), $newline(), $newline(), $text('text on line 2'), $newline()];
          lines = groupByLines(tokens);
          return expect(lines.length).toBe(4);
        }));
      });
      describe('processLines', function() {
        return it('should add an openTags property to the line objects with the open tags', inject(function(processLines) {
          var lines;

          lines = [[$tag('h1'), $text('some text'), $tag('h2'), $tag('h2', 'close')]];
          return expect(processLines(lines)[0].openTags[0]).toBe('h1');
        }));
      });
      return describe('indent', function() {
        describe('indentLine', function() {
          it('returns 0 if the line starts with anything but a text token', inject(function(indentLine) {
            var line;

            line = [$token('tag', '<a tag>')];
            return expect(indentLine(line).indent).toBe(0);
          }));
          return it('return the line indent', inject(function(indentLine) {
            var indentedLine, line;

            line = [$text('  a 2 space indent')];
            indentedLine = indentLine(line);
            expect(indentedLine.indent).toBe(1);
            expect(indentedLine[0].contents).toBe('a 2 space indent');
            line = [$text('    ')];
            return expect(indentLine(line).indent).toBe(2);
          }));
        });
        describe('groupByIndent', function() {
          return it('should group tokens by indent level', inject(function(groupByIndent) {
            var aunt, dad, grandpa, lines, oldMaid, topLines;

            lines = [$line(0, $text('grandpa')), $line(1, $text('old maid')), $line(1, $text('dad')), $line(2, $text('only child')), $line(1, $text('aunt')), $line(2, $text('cousin 1')), $line(2, $text('cousin 2'))];
            topLines = groupByIndent(lines);
            expect(topLines.length).toBe(1);
            grandpa = topLines[0];
            expect(grandpa[0].contents).toBe('grandpa');
            expect(grandpa.children.length).toBe(3);
            oldMaid = grandpa.children[0];
            dad = grandpa.children[1];
            aunt = grandpa.children[2];
            expect(oldMaid[0].contents).toBe('old maid');
            expect(dad[0].contents).toBe('dad');
            expect(aunt[0].contents).toBe('aunt');
            expect(oldMaid.children).toBe(void 0);
            expect(dad.children.length).toBe(1);
            expect(dad.children[0][0].contents).toBe('only child');
            expect(aunt.children.length).toBe(2);
            expect(aunt.children[0][0].contents).toBe('cousin 1');
            return expect(aunt.children[1][0].contents).toBe('cousin 2');
          }));
        });
        describe('flatten', function() {
          describe('openTags', function() {});
          return it('should should find all the open tags on a line', inject(function(openTags) {
            var line;

            line = [$tag('h1')];
            expect(openTags(line)[0]).toBe('h1');
            line = [$tag('h1'), $tag('h2')];
            expect(_(openTags(line)).contains('h1')).toBe(true);
            expect(_(openTags(line)).contains('h2')).toBe(true);
            line = [$tag('h1'), $tag('h2'), $tag('h2', 'close')];
            expect(_(openTags(line)).contains('h1')).toBe(true);
            expect(_(openTags(line)).contains('h2')).toBe(false);
            line = [$tag('h1'), $tag('h2'), $tag('h1', 'close')];
            return expect(function() {
              return openTags(line);
            }).toThrow(new openTags.UnmatchedTagError('h2', 'h1'));
          }));
        });
        return describe('render', function() {
          it('should render a line with no children by appending closing tags to the line', inject(function(render) {
            var line;

            line = [$tag('h1'), $text('some text')];
            line.openTags = ['h1'];
            expect(render(line)).toBe('<h1>some text</h1>');
            line = [$tag('h1'), $text('after h1 before h2'), $tag('h2'), $text('after h2')];
            line.openTags = ['h1', 'h2'];
            return expect(render(line)).toBe("<h1>after h1 before h2<h2>after h2</h2></h1>");
          }));
          return it('should render a line with children by appending closing\
        tags after the child lines', inject(function(render) {
            var child1, child2, html, line;

            line = [$tag('body'), $tag('div')];
            line.indent = 0;
            line.openTags = ['body', 'div'];
            child1 = $line(1, [$tag('h1'), $text('AWESOME PAGE HEADER'), $tag('h1', 'close')]);
            child1.openTags = [];
            child2 = $line(1, [$tag('p'), $text('sweet paragraph text')]);
            child2.openTags = ['p'];
            line.children = [child1, child2];
            html = render(line);
            return expect(html).toBe("<body><div>\n  <h1>AWESOME PAGE HEADER</h1>\n  <p>sweet paragraph text</p>\n</div></body>");
          }));
        });
      });
    });
    return describe('compile', function() {
      return it('should be awesome', inject(function(compile) {
        var html;

        return html = compile("<body>\n  <div>\n    <h1>A HEADER\n    <p> Two lines of text\n      another two lines of text");
      }));
    });
  });

}).call(this);