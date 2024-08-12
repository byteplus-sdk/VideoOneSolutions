import {Checkbox, WhiteSpace, WingBlank} from '@ant-design/react-native';
import React from 'react';
import {useSnapshot} from 'valtio';
import {playerConfig} from '../../../../../store/pull/player';

const InfoSetting = () => {
  const {enableInfo, enableLogs} = useSnapshot(playerConfig);
  return (
    <WingBlank>
      <WhiteSpace />
      <Checkbox
        checked={enableInfo}
        onChange={e => {
          playerConfig.enableInfo = e.target.checked;
        }}>
        Info
      </Checkbox>
      <WhiteSpace />
      <Checkbox
        checked={enableLogs}
        onChange={e => {
          playerConfig.enableLogs = e.target.checked;
        }}>
        Callback
      </Checkbox>
      <WhiteSpace />
    </WingBlank>
  );
};

export default InfoSetting;
