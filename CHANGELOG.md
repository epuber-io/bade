# CHANGELOG

## **0.3.11**

Released 2024-06-01

- Fix escaping tag attributes when in runtime the attribute is not string (_boolean_, _number_ or any other Ruby object)


## **0.3.10**

Released 2024-06-01

- Fix not escaping tag attributes (when using Bade's tag syntax: `div(class: '&"')` will break result XML/HTML)


## **0.3.9**

Released 2023-10-27

- Allow to use more versions of Psych


## **0.3.8**

Released 2023-10-26

- Fix dynamic values in require_relative (for example: `- require_relative "#{abs_path}/../abc`)


## **0.3.7**

Released 2023-10-15

- Fix unwanted print to console


## **0.3.6**

Released 2023-10-15

- Fix base path when using require_relative in Bade template files
- Fix crash when location of some module is `false` instead of `String` (not sure why is that)


## **0.3.5**

Released 2022-05-04

- Fix issues when using multiline Ruby code #35


## **0.3.4**

Released 2022-03-29

- Do not remove constants defined in files that are in `$LOADED_FEATURES`

## **0.3.3**

Released 2022-03-22

- Fix formatting error messages (correct is overriding `#to_s` instead of `#message`)


## **0.3.2**

Released 2022-03-22

- Improve error messages and locations
- Resolve infinite loop when requiring not existing library #19


## **0.3.1**

Released 2022-03-22

<details>
<summary>Added option to filter constants to remove when using GlobalsTracker</summary>

```ruby
Bade::Runtime::GlobalsTracker.new(constants_location_prefixes: ['/Users/xyz/Projects/abc'])
```

</details>


## **0.3.0**

Released 2022-03-21

<details>
<summary>Added support for optional positional parameters in mixin (#17)</summary>

[#17](https://github.com/epuber-io/bade/issues/17)

```
mixin some_mixin(param = 1)
```

</details>


<details>
<summary>Added support for required key-value parameters in mixin</summary>
Example:

```
mixin some_mixin(param:)
```
</details>


<details>
<summary>Backtrace of error from template (#7)</summary>

[#7](https://github.com/epuber-io/bade/issues/7)

When some error is raised, it will return position of the error. Given this template:

```
mixin m()
  a
    - raise StandardError

+m
```

It will produce following error:

```
Exception raised during execution of mixin `m`: StandardError
template backtrace:
  template.bade:3:in `+m'
  template.bade:5:in `<top>'
```
</details>



<details>
<summary>Added keyword yield for invoking default block in mixin (#4)</summary>

Previous solution:
```
mixin first
  p.first
    - default_block.call

+first Some text
```

New solution:
```
mixin first
  p.first
    yield

+first Some text
```

Which produces:

```html
<p class="first">Some text</p>
```
</details>

<br/>

### **Breaking changes:**

Dropped support for Ruby 2.4 and older.


## **0.2.5**

Released 2020-04-25

## **0.2.4**

Released 2018-09-05

## **0.2.3**

## **0.2.2**

## **0.2.1**

## **0.2.0**

## **0.1.4**

## **0.1.3**

## **0.1.2**

## **0.1.1**

## **0.1.0**
