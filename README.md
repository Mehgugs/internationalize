## Internationalize

A derivative of [i18n.lua](https://github.com/kikito/i18n.lua) that supports multiple instances.


### Motivation

This module should function similarly to i18n.lua except this library
provides an object with methods instead of keeping its state globally.
The interpolation options are also simpler to use – as outlined below.

### Key differences

Interpolation is handled differently: this library only supports
the `%{var}` format, but allows a lua format specifier to appear after
the key i.e. `%{var #x}` or `%{var q}`.

Pluralization variables are deduced from the interpolation strings of
the plural table. You may optionally add `pl.<format specifier>` (or simply use the specifier `pl`)
to denote the key whose numeric value should be checked for plural behaviour.
If there is ambiguity this system always uses the key `count` instead.

Any structure which contains a leaf field `other` is considered a plural table
like i18n.


```lua
phone_msg = {
      one = "you have one new message.",
      other = "you have %{msgs} new messages."
      -- "msgs" is considered the plural var of the "phone_msg" variable.
}

phone_msg = {
      one = "%{subj} one new message.",
      other = "%{subj} %{msgs pl.d} new messages."
      -- "msgs" is considered the plural var still; formatted by %d
}

phone_msg = {
      one = "%{subj} one new message.",
      other = "%{subj} %{msgs pl} new messages."
      -- "msgs" same as above but format is just tostring.
}

phone_msg = {
      one = "%{subj} one new message.",
      other = "%{subj} %{count} new messages."
      -- "count" is considered the plural var
}

phone_msg = {
      one = "%{subj} one new message.",
      other = "%{subj} multiple new messages."
      -- "count" is considered the plural var still
}
```

Error checking is currently not fully implemented.

### Reference

#### *table (i18n)* `require"internationalize"(default_locale)`

Returns a new instance.

- *string (locale specifier)* `default_locale`

#### *string* `i18n:translate(variable, data)`

Performs translation of the `variable`. The locale used
is either `data.locale` or the configured instance's locale.

- *string* `variable` The variable to translate.
- *table* `data` The interpolation data. This may be a table of anything,
  however the key `locale` can be used to specify a specific locale.


#### *string* `i18n:translations_of(variable, data, ...)`

Performs translation of the `variable` for all locales provided.
This function is stricter about locale fallbacks; and will only consider
ancestor locales (for example fr will not use an en fallback).

- *string* `variable` The variable to translate.
- *table* `data` The interpolation data. This may be a table of anything,
  however the key `locale` can be used to specify a specific locale.
- *string (locale specifier)* `...` A vararg containing locale specifiers to use.

#### *string* `i18n:translations_from(variable, data, array)`

Performs translation of the `variable` for all locales provided.
This function is stricter about locale fallbacks; and will only consider
ancestor locales (for example fr will not use an en fallback).

- *string* `variable` The variable to translate.
- *table* `data` The interpolation data. This may be a table of anything,
  however the key `locale` can be used to specify a specific locale.
- *array (locale specifier)* `array` An array containing locale specifiers to use.

#### *nothing* `i18n:set(path, value)`

Sets a variable. Path should always be prefixed by a locale specifier parts
separated by a hyphen or dot, then finally the variable name. For example `en-GB.foo`, `fr.CA.foo` or `ar.foo`.

- *string* `path` The variable's path.
- *string* `value` The variable's value.

#### *nothing* `i18n:set_all(data)`

Sets a variable across multiple locales. The data should look like this:

```lua
{
    var = {
        en = "Like this",
        fr = "Comme ça"
    }
}

{
    var = {
        ['en.GB'] = "Like this innit",
        en = "Like this"
    }
}

{
    var = {
        en {
            GB = "Like this innit",
            US = "Like this"
        }
    }
}
```

- *table* `data`

#### *nothing* `i18n:load(data)`

Loads data from a table, however
the table paths are not inverted like `set_all`, the data should look like this:

```lua
{
    en = {
        var = "A %{variable}",
        another_var = {
            one = "An apple",
            other = "%{apples} apples."
        }
    },
    fr = ...
    ....
}
```

- *table* `data`

#### *nothing* `i18n:set_locale(l)`

Sets the default locale of the instance.

- *string (locale specifier)* `l`

#### *nothing* `i18n:set_fallback_locale(l)`

Sets the fallback locale of the instance.

- *string (locale specifier)* `l`




