# mdc_web_components

(Pseudo) Web components built on the mdc_web package.

This package aims to eventually be consistent with the [material-components-web-components](https://github.com/material-components/material-components-web-components) javascript library, but until it is released for consumption the [MDC component reference](https://material.io/develop/web/) is it's main source of truth. However, any additions found in the javascript library have been added.

## MDC, MWC

Material Design Components (MDCs) are the foundational layer that Material Web Components (MWCs) are built upon. The MDC layer describes a component's functionality and available styles, while the MWC layer packages those up into an easy to use web-component. For example, markup for a purely MDC button may look like

```html
<button class="mdc-button mdc-button--raised mdc-button--dense">
  <i class="material-icons mdc-button__icon" aria-hidden="true">favorite</i>
  Button
</button>
```

the MWC equivalent is much easier to read:

```html
<mwc-button raised dense icon="favorite">Button</mwc-button>
```

> It is better to set the button text using the `label` attribute, so a corresponding `aria-label` can be set under the hood.
>  ```html
>  <mwc-button raised dense icon="favorite" label="Button"></mwc-button>
>  ```

## Usage

See the [full example](./example/).

### Include the script

In your index.html, include this following script dependency just before the `main.dart.js` script.

```html
<!--
  This exposes the `mdc` global variable required by this package.
  For debugging purposes you can replace the ".min.js" extension with ".js".
-->
<script defer src="packages/mdc_web/material-components-web.min.js"></script>
<script defer src="main.dart.js"></script>
```

### Initialize the web components

```dart
  import 'package:mdc_web_components/mdc_web_components.dart';
  void main {
    initComponents();
  }
```

### Import styles

When the official MWC JS package is complete this will no longer be necessary, but the styles for MDC components must be included via NPM.

```sh
# From the project's `web` directory.
> npm install --save-dev material-components-web
```

```yaml
# In pubspec.yaml
dev_dependencies:
  sass_builder:
    # temporary work-around to include node_modules in the style search path.
    git: https://github.com/jifalops/sass_builder
```

In `styles.scss` (renamed from `styles.css`):

```scss
@import 'material-components-web/material-components-web';
```

## Documentation

Each class and notable members are documented. Class documentation includes links to corresponding (if available):

* [Design Guidelines](https://material.io/design/components/)
* [MDC Component Reference](https://material.io/develop/web/)
* [MDC Demo](https://material-components.github.io/material-components-web-catalog/#/)
* [MWC Demo](https://material-components.github.io/material-components-web-components/demos)
* [MDC Source Code](https://github.com/material-components/material-components-web/tree/master/packages)
* [MWC Source Code](https://github.com/material-components/material-components-web-components/blob/master/packages)
