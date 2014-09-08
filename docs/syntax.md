
# Syntax

All is controlled by line indicators: first visible characters in line. Indentation is only by tabs.
Beacause I would have to break some things. Which I really wont't. So it will not change in near future.


## Piped text `|`

Piped text is for adding simple not changed text. Each following line indented greater than the pipe is copied into result.

```
| This is text block.
	Text will be also in same text block.

| Text
        will have indetation
```

Result will be:

```
This is text block.
Text will be also in same text block.

Text
    will have indetation
```

Result will also have same indentation as input. But if turn on some optimizations (minifying) it will strip to one space.


## Control code `-`

Control code is line indicator for controling template at runtime (conditions, iterations, calling blocks in mixins, ...). You can write any code after this line indicator.

```
- if 'hello'.include? ?l
    | hello contains char l
- else
    | hello is weird
- end
```

Unfortunately you have to write `end`, `}` and all that stuff. In future this error will be removed, hopefully.

## Tag `<text>`

## Doctypes `doctype`

## Output
### Escaped `=`
### Unescaped `&=`

## Comments 
### Code comments `//`
### XML comments `//!`

## Mixins
### Definition `mixin`
### Call `+`
### Blocks `block`


