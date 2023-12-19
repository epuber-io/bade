
# Syntax

All is controlled by line indicators: first visible characters in line.

**Indentation** is key, it controls nesting of result content. Indentation can be done with tabs or spaces. Do not mix them, not sure what will happen.


## Piped text `|`

Piped text is for adding simple not changed text. Each following line indented greater than the pipe is copied into result.

```
| This is text block.
    Text will be also in same text block.
```

Result will be:

```
This is text block.
Text will be also in same text block.
```

Result will also have same indentation as input.

### Interpolation

In piped text you can interpolate values as in Ruby strings.

Let's say that `value` is string `world`.

```
| Hello #{value}!
```

Result:

```
Hello world!
```

The keypart is `#{ variable or Ruby code }`.


## Control code `-`

Control code is line indicator for controling template at runtime (conditions, iterations, calling blocks in mixins, ...). You can write any code after this line indicator.

```
- if 'hello'.include?('l')
    | hello contains char l
- else
    | hello is weird
- end
```

Unfortunately you have to write `end`, `}` and all that stuff. In future this inconvenience will be improved, hopefully.

### Require

You can also require other Ruby files just like in normal Ruby scripts.

```
- require 'active_support'
- require_relative 'lib/calc'
```

### Custom functions

In control code you can define custom functions:

```
- def link(param)
-   %(<a href="#{param}">#{param}</a>)
- end
```

And you can use it in for example piped text like in following example:

```
| For more see #{link('https://abc.xyz')}
```

Which will translate into this:

```html
For more see <a href="https://abc.xyz">https://abc.xyz</a>
```


## Tag `<text>`

You can always write (X)HTML tags as in HTML file. But beware of lines that do not start with `<`.

```
<p>Lorem ipsum</p>
<div>
    <p>Lorem ipsum 2</p>
</div>
```

Will translate into the same text.

## Bade tag

When you want to write HTML tags fancier way, you can use Bade syntax:

```
div.wrapper
    p Lorem ipsum
    p#lorem2 Lorem ipsum 2
div.next_div
```

Will translate into this output:

```html
<div class="wrapper">
    <p>Lorem ipsum</p>
    <p id="lorem2">Lorem ipsum 2</p>
</div>
<div class="next_wrapper" />
```

As you can see from previous example you can specify class and ids using easier syntax: `tag.class` and `tag#id`. You can specify multiple classes, just add dot before next class name `tag.class.class2`. You can mix match classes and ID, but ID must be only single one and at the end (you can't write ID in the middle of classes).

Text after tag behaves like [piped text](#piped-text).

### Attributes

You can also add attributes to tags:

```
div(class: 'abc', aria-label: 'def')
```

Will translate to:

```html
<div class="abc" aria-label="def" />
```

### Nested tags

You can also nest tags on single line using `:` after tag. Like in following example:

```
p: strong Some bold text
```

This will translate to:

```html
<p><strong>Some bold text</strong></p>
```


## Output `=`

Bade can output dynamic values from variables or just calculated values. Be aware, it is unsafe by default, it will not escape HTML code when using output.

```
= 'hello'.gsub('l', 'k')
```

Will translate to this:

```html
hekko
```

You can also use variables from previous code to make it more dynamic:

```
- text = "Lorem" + " " + "ipsum"
= text
```

Will result into this:

```html
Lorem ipsum
```

### Safe HTML text `&=`

To make safe output you can add `&`, so Bade will escape whole text to make it play nicely with HTML.

```
&= "<span>Me & you!</span>"
```

Will translate to:

```html
&lt;span&gt;Me &amp; you!&lt;/span&gt;
```


## Comments `//`

To add single line comments just add `//` at beginning of the line. Comments will not be transferred into result text, it is source only.

```
// this is comment
| this is text
p this is paragraph
```

Will translate into this:

```html
this is text
<p>this is paragraph</p>
```

Bade supports only single line comments, so there is no way to comment whole block of lines.

### XML comments `//!`

If you want your comments to be converted into XML comments, at `//!` at the beginning of the line

```
//! this is xml comment
```

Will result into this

```html
<!-- this is xml comment -->
```

## Mixins

Mixins are powerfull tool to reuse complex structures easily and modify them later when needed. Mixins does support parameters.

### Definition `mixin`

The line has to start with word `mixin` followed by space and name of the mixin, rest is optional.

```
mixin header
    h1 Header

mixin header2(argument)
    h1= argument.upcase

mixin header3(arg1, key_arg: nil)
    div= arg1
    div#some_id Some text #{key_arg}
```


### Call `+`

To call mixin you just use plus symbol and name of mixin.

```
+header
+header2('Hello world')
+header3('Hi', key_arg: 'follows')
```

Will translate to this:

```html
<h1>Header</h1>
<h1>HELLO WORLD</h1>
<div>Hi</h1>
<div class="some_id">Some text follows</div>
```

#### Dynamic values

You can also call mixins with variables or dynamic values:

```
- text = 'abc'
+header2(text)
+header2("abc #{text}")
+header2("abc".gsub('a', 'd'))
```

Will translate to:

```html
<h1>ABC</h1>
<h1>ABC ABC</h1>
<h1>DBC</h1>
```

### Default block

Bade also allows to pass in block that is nested when calling the mixin. From mixin definition you can use it using `default_block` variable.

```
mixin first
    p.first_para
        - default_block.call

+first This is first paragraph.
+first
    | This is second paragraph.
```

As you can see in previous code, you have to call `call` method in order to place the block at the correct position.

Previous code will translate to this HTML:

```html
<p class="first_para">
    This is first paragraph.
</p>
```

### Blocks `block`

Blocks can be also named and there can be multiple of them.

In following example there are two blocks `text` and `author`.

```
mixin quote(&text, &author)
    div.quote
        div.quote_text
            - text.call
        div.quote_author
            - author.call

+quote
    block text
        p “Be yourself; everyone else is already taken.”
    block author
        | —Oscar Wilde
```

Will translate to this HTML:

```html
<div class="quote">
    <div class="quote_text">
        <p>“Be yourself; everyone else is already taken.”</p>
    </div>
    <div class="quote_author">
        —Oscar Wilde
    </div>
</div>
```


## Imports `import`

Bade also has a way to use other files so you don't have to repeat yourself.

Imagine following two files in same folder:

```
// file base.bade

mixin header
    h1 Chapter header
```

```
// file chapter_05.bade

import 'base.bade'

+header
```

The result will be:

```html
<h1>Chapter header</h1>
```

You can import other Bade files or even Ruby files.
