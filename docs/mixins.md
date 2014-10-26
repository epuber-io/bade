
# Mixins runtime

## Declaration part

There is global hash of mixins, now it is called `__mixins`. So to define mixin, we just create lambda, something like this:

```ruby

__mixins['mixin_name'] = lambda { |param1, param2, key_param1: 'value1', key_param2: 'value2'|

}

```


For support blocks, we use keyed params, so we don't have to check for existence and handles duplicit keys.

Example:

```ruby

__mixins['mixin_name'] = lambda { |__blocks, param1, key_param1: 'value1'|
	
}

```

Parameter `default_block` should be there always 


## Calling part

Calling is simple, we just pass in all parameters plus given blocks.

```ruby
__blocks = {}
__blocks['default_block'] = Bade::Runtime::Block.new('default_block') {

}
...
__mixins['mixin_name'].call(__blocks, 'param1_value', key_param1: 'value')
```


# Mixins syntax

## call

`+mixin_name(attribute1, named_attribute1 = value1)
	div
		| normal block content to mixin OR
	block chapter
		p content to named block`

## define

`mixin mixin_name(attribute1, named_attribute1 = default_value, &chapter)
	div.default
		- default_block.call // calling block, can be used .nil? for inspecting if was the block defined
	div.chapter_content
		- chapter.call`
