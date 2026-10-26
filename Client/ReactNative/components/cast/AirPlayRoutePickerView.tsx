// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import { requireNativeComponent, type ViewStyle } from 'react-native';

export type AirPlayRoutePickerViewProps = {
  style?: ViewStyle;
  tintColor?: string;
  activeTintColor?: string;
  prioritizesVideoDevices?: boolean;
  onWillPresentRoutes?: () => void;
  onDidEndPresentingRoutes?: () => void;
};

export default requireNativeComponent<AirPlayRoutePickerViewProps>(
  'AirPlayRoutePickerView',
);
