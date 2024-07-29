import React from 'react';
import {TouchableOpacity, View, Text} from 'react-native';

const PickerText = (props: any) => (
  <TouchableOpacity onPress={props.onPress}>
    <View
      style={{
        width: '100%',
        height: 36,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
      }}>
      <Text>{props.children}</Text>
      <Text style={{textAlign: 'right', color: '#888', marginRight: 15}}>
        {props.extra}
      </Text>
    </View>
  </TouchableOpacity>
);

export default PickerText;
