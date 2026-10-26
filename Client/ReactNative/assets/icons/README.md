# Interface icons

These vector paths follow the short drama icon shapes and states in the
[VideoOne design](https://www.figma.com/design/FOqxAGW2VrDD5QZMQ2hKpr/Byteplus-VideoOne-center?node-id=9618-19272)
and the Flutter reference assets under `vod_flutter_mini_drama/assets/minidrama/common`.
They are recreated vector resources, not Figma exports or embedded PNG images.

Use `components/ui/SvgIcon` for static icons. Its `color` prop takes precedence
over an existing `tintColor` style; dimensions, margins, and opacity are preserved.
The animated episode equalizer uses `PlayingIcon`. Photos, artwork, Lottie
animations, and native system route pickers keep their original rendering.

SVG files are transformed with the Expo entry point of
`react-native-svg-transformer` and rendered by the existing `react-native-svg`
dependency. Restart Metro after changing the transformer configuration.
